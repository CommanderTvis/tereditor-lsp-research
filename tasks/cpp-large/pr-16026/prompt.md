# [BUG] HOTKEYS START rejects DURATION 0 documented by HOTKEYS HELP

`HOTKEYS HELP` documents zero duration as tracking until manually stopped:

```text
* DURATION duration
    Specifies tracking duration in seconds. 0 means tracking will continue until manually stopped. Default: 0
```

However, explicitly passing zero fails:

```text
127.0.0.1:6379> HOTKEYS START METRICS 2 CPU NET COUNT 1 DURATION 0
(error) ERR DURATION must be between 1 and 1000000
```

Omitting `DURATION` already provides the documented unlimited behavior.

Expected behavior: `DURATION 0` should behave like omitting the option, with tracking continuing until `HOTKEYS STOP`.

The restriction was introduced during [#14680](https://github.com/redis/redis/pull/14680). The accompanying comment explains the upper bound as overflow protection, but does not explain excluding zero. [#14785](https://github.com/redis/redis/pull/14785) subsequently added the HELP text above. The parser restriction remains in [Redis 8.10.2](https://github.com/redis/redis/blob/8.10.2/src/hotkeys.c#L355-L380).
