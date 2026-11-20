<?php

namespace Illuminate\Tests\Bus;

use Illuminate\Bus\Dispatcher;
use Illuminate\Container\Container;
use Illuminate\Contracts\Bus\Dispatcher as DispatcherContract;
use Illuminate\Support\Testing\Fakes\BusFake;
use PHPUnit\Framework\TestCase;
use ReflectionMethod;

class StudyHiddenDispatchNowTest extends TestCase
{
    public function testContractAndImplementationsDeclareContextBeforeHandler()
    {
        foreach ([DispatcherContract::class, Dispatcher::class, BusFake::class] as $class) {
            $names = array_map(fn ($p) => $p->getName(), (new ReflectionMethod($class, 'dispatchNow'))->getParameters());
            $this->assertSame(['command', 'context', 'handler'], $names, $class);
            $this->assertFalse((new ReflectionMethod($class, 'dispatchNow'))->getParameters()[1]->isOptional(), $class);
        }
    }

    public function testDispatchNowRunsHandlerWithContext()
    {
        $dispatcher = new Dispatcher(new Container);
        $result = $dispatcher->dispatchNow(new StudyHiddenCommand, ['k' => 'v'], fn ($command) => 'handled-'.get_class($command));
        $this->assertSame('handled-'.StudyHiddenCommand::class, $result);
    }

    public function testDispatchRunsCommandWithoutQueue()
    {
        $dispatcher = new Dispatcher(new Container);
        $this->assertSame('ran', $dispatcher->dispatch(new StudyHiddenCommand));
    }
}

class StudyHiddenCommand
{
    public function handle()
    {
        return 'ran';
    }
}
