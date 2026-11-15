Move the translation loader contract `Illuminate\Contracts\Translation\Loader` one namespace up: it should become
`Illuminate\Contracts\Loader`, in `src/Illuminate/Contracts/Loader.php`. Update every reference in the framework and
its tests, including PHPDoc type references. Do not leave the old interface behind and do not add an alias for the old
name. Other classes and interfaces that are also called `Loader` or end in `Loader` are unrelated and stay where they
are. Updating the changelog or other documentation is optional.
