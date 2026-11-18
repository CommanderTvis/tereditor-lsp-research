# A throwing worker event listener kills messenger:consume with exit 1: message stats and telemetry run outside Messenger's try/catch

### Shopware Version

trunk, verified at commit `42a1e11d`. Requires `symfony/messenger` 7.4 (pinned as `~7.4.12`).

### Affected area / extension

Platform(Default)

### Actual behaviour

A message **handler** that throws is safe — Messenger catches it and routes to retry or the failure transport. But a **worker event listener** that throws is not caught anywhere, and takes the whole `messenger:consume` process down with exit code 1.

Shopware registers listeners in exactly that unprotected window, and they perform database writes.

**Where the protection ends.** In `Symfony\Component\Messenger\Worker::handleMessage()`, the `try/catch` wraps only the bus dispatch:

```php
try {
    $e = null;
    $envelope = $this->bus->dispatch($envelope->with(new ReceivedStamp($transportName), new ConsumedByWorkerStamp(), new AckStamp($ack)));
} catch (\Throwable $e) {
}

// ...
$this->ack();   // OUTSIDE the catch
```

`Worker::run()` itself has no `try/catch` at all. So everything below propagates out of `run()`, out of `ConsumeMessagesCommand::execute()`, and becomes an uncaught exception that the Console Application renders as exit code 1:

- `WorkerMessageReceivedEvent` dispatch, at the top of `handleMessage()`
- `WorkerMessageHandledEvent` and `WorkerMessageFailedEvent` dispatches, and `$receiver->reject()`, inside `ack()`
- `WorkerStartedEvent`, `WorkerRunningEvent`, `WorkerStoppedEvent` in `run()`
- `$receiver->get()`, the transport fetch

**What Shopware puts there.** `MessageQueueStatsSubscriber` is tagged `kernel.event_subscriber` (`src/Core/Framework/DependencyInjection/message-queue.php:42-46`), so it runs on every CLI worker, not just the admin worker. Its `WorkerMessageHandledEvent` handler does two unguarded things (`src/Core/Framework/MessageQueue/Subscriber/MessageQueueStatsSubscriber.php:61-65`):

```php
public function onMessageHandled(WorkerMessageHandledEvent $event): void
{
    $this->handle($event->getEnvelope(), false);
    $this->statsService->registerMessage($event->getEnvelope());
}
```

1. `handle()` calls `IncrementGatewayRegistry::get(IncrementGatewayRegistry::MESSAGE_QUEUE_POOL)` (line 88), which **throws** `IncrementException::gatewayNotFound()` when no gateway is registered for that pool (`src/Core/Framework/Increment/IncrementGatewayRegistry.php:35`). Skipped only when feature flag `v6.8.0.0` is active.
2. `statsService->registerMessage()` reaches `MySQLStatsRepository::updateMessageStats()`, which performs an INSERT plus a DELETE (`src/Core/Framework/MessageQueue/Stats/MySQLStatsRepository.php:31-37`). No `try/catch`; guarded only by an `enabled` flag.

So a transient database failure — a failover, a connection reset, a `max_connections` spike, a deployment window — that occurs *after* a message was handled successfully will kill the worker, even though the message itself was processed fine and the work is done.

`MessageQueueTelemetrySubscriber` is registered the same way and sits in the same window.

**Contrast with the listener that gets it right.** `TelemetryFlushListener`, which also hooks `WorkerRunningEvent`, wraps each transport individually (`src/Core/Framework/Telemetry/Metrics/Subscriber/TelemetryFlushListener.php:49-61`):

```php
foreach ($this->transports as $transport) {
    try {
        $transport->flush();
    } catch (\Throwable $e) {
        $this->logger->warning(
            \sprintf('Failed to flush metric transport %s', $transport::class),
            ['exception' => $e]
        );
    }
}
```

That is the correct shape. Statistics and telemetry are observability; they should never be able to terminate the thing they observe.

### Expected behaviour

A failure in a statistics, metrics, or telemetry listener should be logged and swallowed, never fatal to the worker. Processing a message successfully and then failing to record a counter about it is not a reason to stop consuming the queue.

Concretely:

1. Wrap the side-effecting bodies of `MessageQueueStatsSubscriber::onMessageHandled()`, `onMessageFailed()` and `onMessageSent()` in `try/catch (\Throwable)` with a `warning` log, matching `TelemetryFlushListener`.
2. Do the same for `MessageQueueTelemetrySubscriber`.
3. Consider making `IncrementGatewayRegistry::get()` failures non-fatal at this call site specifically — a missing increment pool is a configuration state, not a per-message emergency, and it currently throws on *every* handled message.

Worth considering more broadly: any Shopware listener on a `Worker*` event is load-bearing for worker uptime in a way its author probably did not intend. A short note in the messenger documentation, or a base subscriber that isolates failures, would stop this recurring.

### How to reproduce

Two paths, both on a `messenger:consume` worker.

**A — missing increment pool (deterministic):**

1. Ensure feature flag `v6.8.0.0` is inactive.
2. Configure the environment so no incrementer is registered for the `message_queue` pool, so `IncrementGatewayRegistry::get()` finds no matching gateway.
3. Run `bin/console messenger:consume async -vv` and enqueue any message.
4. The message is handled, then `IncrementException::gatewayNotFound()` escapes and the command terminates. `echo $?` prints `1`.

**B — transient database failure (matches what we hit in production):**

1. Run `bin/console messenger:consume async -vv` with message stats enabled.
2. Enqueue a message and let the handler complete successfully.
3. Interrupt the database connection between the handler returning and `ack()` running — restart MySQL, drop the connection, or exhaust `max_connections`.
4. The worker dies with exit code 1 and a stack trace pointing into `MySQLStatsRepository`, not into the handler.

Path B is how this surfaced for us: an intermittently failing deployment where the worker container exited 1 during the deploy window. Nothing in the handler was at fault, and the exit code misattributed the failure to the deployment step. Because the exit is non-zero, container orchestrators treat it as a crash rather than a graceful stop — note that a genuine graceful stop (`messenger:stop-workers`, `--time-limit`, `--memory-limit`, SIGTERM) always exits `0`, since `ConsumeMessagesCommand::execute()` has a single `return 0` and `handleSignal()` returns `false` on every path. Exit 1 from a worker therefore always means an uncaught exception, which made this easy to mistake for a signal-handling problem.

