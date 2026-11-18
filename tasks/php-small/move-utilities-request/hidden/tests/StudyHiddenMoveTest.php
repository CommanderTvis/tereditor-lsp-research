<?php

namespace Yajra\DataTables\Tests;

use Orchestra\Testbench\TestCase;
use Yajra\DataTables\DataTables;
use Yajra\DataTables\Request;

final class StudyHiddenMoveTest extends TestCase
{
    protected function getPackageProviders($app)
    {
        return [\Yajra\DataTables\DataTablesServiceProvider::class];
    }

    public function testTheRequestLivesInTheRootNamespaceOnly(): void
    {
        $this->assertTrue(class_exists(Request::class));
        $this->assertFalse(class_exists('Yajra\\DataTables\\Utilities\\' . 'Request'));
        $this->assertSame('Yajra\\DataTables\\Request', (new \ReflectionClass(Request::class))->getName());
    }

    public function testTheContainerResolvesTheMovedClass(): void
    {
        $this->assertInstanceOf(Request::class, app('datatables.request'));
        $this->assertSame(app('datatables.request'), app(Request::class));
        $this->assertInstanceOf(Request::class, app(DataTables::class)->getRequest());
    }
}
