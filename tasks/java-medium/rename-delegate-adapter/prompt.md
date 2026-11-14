Rename the public method `Gson.getDelegateAdapter` to `getNextAdapter` throughout the core `gson/` module, main code
and tests (the `extras/`, `metrics/` and `proto/` modules are out of scope for this change). Do not keep the old name as
a deprecated alias. Javadoc that refers to the method should follow the new name.
