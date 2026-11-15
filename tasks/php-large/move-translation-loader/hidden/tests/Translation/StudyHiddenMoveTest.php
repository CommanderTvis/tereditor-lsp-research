<?php

namespace Illuminate\Tests\Translation;

use Illuminate\Contracts\Loader;
use Illuminate\Filesystem\Filesystem;
use Illuminate\Translation\ArrayLoader;
use Illuminate\Translation\FileLoader;
use Illuminate\Translation\Translator;
use PHPUnit\Framework\TestCase;

class StudyHiddenMoveTest extends TestCase
{
    public function testTheContractLivesOneNamespaceUpOnly()
    {
        $this->assertTrue(interface_exists(Loader::class));
        $this->assertFalse(interface_exists('Illuminate\\Contracts\\Translation\\'.'Loader'));
        $this->assertTrue(is_subclass_of(ArrayLoader::class, Loader::class));
        $this->assertTrue(is_subclass_of(FileLoader::class, Loader::class));
    }

    public function testTheTranslatorAcceptsAndReturnsTheMovedContract()
    {
        $loader = (new ArrayLoader)->addMessages('en', 'group', ['key' => 'value']);
        $translator = new Translator($loader, 'en');
        $this->assertSame('value', $translator->get('group.key'));
        $this->assertInstanceOf(Loader::class, $translator->getLoader());
        $type = (new \ReflectionMethod(Translator::class, '__construct'))->getParameters()[0]->getType();
        $this->assertSame(Loader::class, (string) $type);
        $this->assertInstanceOf(Loader::class, new FileLoader(new Filesystem, __DIR__));
    }
}
