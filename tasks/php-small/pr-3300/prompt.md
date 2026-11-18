# global search fails when column name with relation has underscore

Global search failing because EagerLoads collection contains relation names in CamelCase, whereas the founction is passing in the actual table name from the column name. e.g.

column name =  child_table.name

Name in EagerLoad collection = childTable

compileQuerySearch in EloquentDataTable.php fails because it needs to convert relation name to camcel Case before calling isNotEagerLoaded:

suggest adding Str::camel call as follows:

```php
protected function compileQuerySearch($query, $columnName, $keyword, $boolean = 'or')
    {
        $parts    = explode('.', $columnName);
        $column   = array_pop($parts);
        $relation = Str::camel( implode('.', $parts) );    // Added convert to camelCase

        if ($this->isNotEagerLoaded( $relation )) {
            return parent::compileQuerySearch($query, $columnName, $keyword, $boolean);
        }

        $query->{$boolean . 'WhereHas'}($relation, function (Builder $query) use ($column, $keyword) {
            parent::compileQuerySearch($query, $column, $keyword, '');
        });
    }
```

Same issue could be fixed in resolveRelationColumn: 

```php
protected function resolveRelationColumn($column)
    {
        $parts      = explode('.', $column);
        $columnName = array_pop($parts);
        $relation   = Str::camel( implode('.', $parts) );   // Added convert to camelCase

        if ($this->isNotEagerLoaded($relation)) {
            return $column;
        }

        return $this->joinEagerLoadedColumn($relation, $columnName);
    }
```


