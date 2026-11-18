Custom column formatters (classes implementing `Yajra\DataTables\Contracts\Formatter`) are handed the cell value and the row, but not the name of the column they are formatting, so a formatter shared by several columns cannot tell them apart. Change the signature of `format()` in the `Formatter` interface and in the classes that implement it to

    format(mixed $value, string $column, $row)

where `$column` is the name of the source column being formatted (for a column added as `name_formatted`, it is `name`). Update the place in the library that calls `format()` on a formatter and every implementation and caller in the tests. Other methods called `format` in the package or in its dependencies (such as `Carbon::format`) are unrelated and keep their signatures. Updating documentation files is optional.
