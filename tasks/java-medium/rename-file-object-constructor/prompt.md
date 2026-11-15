Rename the file `gson/src/main/java/com/google/gson/internal/ObjectConstructor.java` to `ObjectFactory.java` in the
same package, and the interface it declares to `ObjectFactory`, throughout the core `gson/` module, main code and tests
(the `extras/`, `metrics/` and `proto/` modules are out of scope). Do not keep the old name as an alias. Comments and
Javadoc that refer to the interface should follow the new name; other types whose names merely contain the old name
keep their names.
