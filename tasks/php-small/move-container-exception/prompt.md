Move the exception class `ContainerException` out of the `League\Container\Exception` namespace into the package's root
namespace: it should become `League\Container\ContainerException`, in `src/ContainerException.php`, following the
package's PSR-4 layout. Update every reference in the library and the tests. Do not leave the old class behind and do
not add an alias for the old name. `NotFoundException` stays where it is. Updating documentation files is optional.
