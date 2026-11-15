# Imports sometimes incorrect when inheriting nested type of same name

If you are generating a subclass of a class like this...

``` java
// Parent.java
class Parent {
  static class Optional {}
}

// Generated Child.java
class Child extends Parent {
  java.util.Optional<String> optionalString() {...}
}
```

...then it is not correct to import java.util.Optional and abbreviate to "Optional<String> optionalString()", because the inherited nested Optional takes precedence over the import statement. Since JavaWriter typically doesn't know anything about Parent in this case, there should be some way of telling it to fully-qualify a type even if it would otherwise be inclined to import it.

This is an actual case that occurs with AutoValue in code at Google. (AutoValue doesn't use JavaWriter and can't as long as this bug remains.)

