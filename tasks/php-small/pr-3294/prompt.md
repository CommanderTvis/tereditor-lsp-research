# Model with custom table including schema fails on search

Hi,

I have a model with a custom table definition: `protected $table =  'schemaname.tablename';`
When I define the columns I do not use any dotted notation: `{ bit_index: 2, data: 'columnname', name: 'columnname', title: 'Example', visible: true, searchable: true }`

When using Laravel 11 (and Datatables 11) this worked fine.
When using Laravel 12 (Datatables 12) I now run into an error when any column search is triggered:
```
Call to undefined method App\ModelName::schemaname()
```
i.e. the `schemaname` is being interpreted as a function/relationship against the model and attempting to be executed.

I have tracked this down to this commit: 01ec50db648618ff9bc555339f3700e8e8f5be54
`$column` becomes: `schemaname.tablename.columnname`.
It then attempts to use this as an `orWhereHas` relation and fails.
Prior to this the check for `isMorphRelation` also fails as `$isMorph = method_exists($model, $firstRelation) && $model->$firstRelation() instanceof MorphTo;` does not short circuit when `method_exists` returns `false` and again attempts to execute the relationship that doesn't exist.

This second issue is easier to fix with a rearrangement of the statements, however the first example is particularly troublesome and I have resorted to reverting this commit locally.

Can you suggest whether I am doing something wrong on my end or is this commit in fact not working as intended?
Maybe another guard on `method_exists` could be utilised to shortcut this iteration loop?


Note that we use the dotted notation for `schemaname.tablename` as we do joining on tables across schemas so we cannot use the `$connection` method.

Thanks for your time.
