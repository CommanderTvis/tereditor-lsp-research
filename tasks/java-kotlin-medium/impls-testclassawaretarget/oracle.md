# Oracle: concrete implementations of `TestClassAwareTarget` (pact-jvm 4_7_7)

Derived without a language server, from the compiler's output: every module's main source set was compiled with Gradle
(`compileJava compileKotlin --continue`, JDK 21, 1110 classes), the class headers read with `javap -p -s`, and the
transitive subtypes of the interface computed from `extends` and `implements` clauses (script impls.py in the curation
notes); kept: classes that are not abstract, interfaces and nested, anonymous and companion classes excluded. Result: 6 classes
in 3 modules (provider/junit, provider/spring): HttpTarget and MessageTarget through BaseTarget, and four Spring targets
through them or BaseTarget. Cross-checked with `grep -rn 'BaseTarget\|HttpTarget\|MessageTarget'` over the production
sources: SpringBootHttpTarget extends HttpTarget, SpringAwareMessageTarget extends MessageTarget, BaseTarget is abstract.

Judgement calls: none.
