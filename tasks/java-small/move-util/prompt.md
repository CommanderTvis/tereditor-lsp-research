Move the helper class `Util` (`src/main/java/com/squareup/javapoet/Util.java`) into a new package
`com.squareup.javapoet.internal`, as `src/main/java/com/squareup/javapoet/internal/Util.java`. Since the rest of
JavaPoet keeps using it from `com.squareup.javapoet`, the class and its static methods have to become public. Update
every use in the main code and the tests so that everything compiles and the tests pass, and do not leave a `Util`
class behind in `com.squareup.javapoet`. Nothing else about the class changes.
