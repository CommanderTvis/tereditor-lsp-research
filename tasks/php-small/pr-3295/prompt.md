# Smart search add two %% to the end of the search value

### Summary of problem or feature request

if `smart` search is `true` and `starts_with` is `false` adds two `%` characters to the end of the search value. if we enable  `starts_with` to true still the search value has a `%` character in the beginning of the search value.

I think this is caused by the following
1. `setupKeyword` function [
https://github.com/yajra/laravel-datatables/blob/b1849508ca5dcabb6f375e45d9f00dbb94b79082/src/DataTableAbstract.php#L931] considers only smart search 
2. prepareKeyword function [https://github.com/yajra/laravel-datatables/blob/b1849508ca5dcabb6f375e45d9f00dbb94b79082/src/QueryDataTable.php#L481] consider both `smart` and `starts_with`

But both functions are called and this add two `%%` to end.

I assume `setupKeyword` function also should consider `starts_with` config option.

![image](https://github.com/yajra/laravel-datatables/assets/1304358/14a72a2d-9e73-4481-8d9d-c3c4cb0acae4)

Also what does `smart` search do, does is enable searching for `contains` in a string value?

### System details

- Operating System
- 8.1
- 6
- 9.11
