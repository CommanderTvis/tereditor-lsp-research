<?php

namespace Yajra\DataTables\Tests\Integration;

use Illuminate\Foundation\Testing\DatabaseTransactions;
use PHPUnit\Framework\Attributes\Test;
use Yajra\DataTables\Contracts\Formatter;
use Yajra\DataTables\Tests\Models\User;
use Yajra\DataTables\Tests\TestCase;

class StudyHiddenSignatureTest extends TestCase
{
    use DatabaseTransactions;

    #[Test]
    public function the_formatter_receives_the_source_column_name_between_value_and_row()
    {
        $formatter = new class implements Formatter
        {
            public array $calls = [];

            public function format(mixed $value, string $column, $row): string
            {
                $this->calls[] = [$column, $value, is_object($row) || is_array($row)];

                return $column.'='.$value;
            }
        };

        $data = app('datatables')->eloquent(User::query()->whereKey(1))
            ->formatColumn(['name', 'email'], $formatter)
            ->toJson()
            ->getData(true)['data'][0];

        $this->assertSame([['name', 'Record-1', true], ['email', 'Email-1@example.com', true]], $formatter->calls);
        $this->assertSame('name=Record-1', $data['name_formatted']);
        $this->assertSame('email=Email-1@example.com', $data['email_formatted']);
    }
}
