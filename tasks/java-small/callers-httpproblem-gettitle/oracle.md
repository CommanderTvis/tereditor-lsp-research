# Oracle: methods that reach `HttpProblem#getTitle()` (quarkus-http-problem 3.38.2)

Derived without a language server, from the compiler's output: `mvn -o compile` of every module, then
`javap -c -p -s` of every class in `*/target/classes` (production code only). A small script reads the invoke
instructions into a call graph (owner, name, descriptor), resolves each call up the class hierarchy inside the project,
adds an edge to every overriding declaration for virtual and interface calls (class hierarchy analysis), adds the
method-handle targets of `invokedynamic` (method references and lambdas), and maps the synthetic `lambda$name$N` methods
to the method that contains them. The answer is the set of methods in the transitive reverse closure of `getTitle()`,
without `getTitle()` itself, written `Class#name`.

    mvn -B -o -DskipTests compile
    find . -path '*/target/classes/*.class' | xargs javap -c -p -s -constants > javap.txt
    callgraph.py javap.txt 'io.quarkiverse.httpproblem.HttpProblem#getTitle'     # 15 methods

Cross-checks by hand: the direct callers (HttpProblem#builder(HttpProblem), ProblemJsonRpcService#problemToMap,
JacksonProblemSerializer#serialize, JsonbProblemSerializer#serialize, ProblemLogger#serialize) are exactly the places
that fail to compile when the declaration is renamed (`mvn -o compile` after renaming the method in HttpProblem.java
reports runtime/.../HttpProblem.java:97, JacksonProblemSerializer.java:35-36, JsonbProblemSerializer.java:23-24,
ProblemLogger.java:45; ProblemJsonRpcService.java:68 lies in a module built after the failure). The text candidates
`grep -rn 'getTitle' --include=*.java` outside tests are all accounted for: ZalandoProblemMapper.java:36 calls
`getTitle()` on the Zalando `ThrowableProblem`, not on `HttpProblem`, and is correctly absent. The indirect callers
follow the text call sites of the direct ones: `PostProcessorsRegistry#applyPostProcessing` calls `ProblemPostProcessor#apply`
(implemented by `ProblemLogger`, `ProblemDefaultsProvider`, `MdcPropertiesInjector`, `CustomPostProcessor`), and it is
called by `ExceptionMapperBase#toResponse`, the two reactive security mappers' `handle` and `ProblemJsonRpcService#testProblem`
(through `problemToMap`); `HttpProblem.builder(problem)` is called by `MdcPropertiesInjector`, `ProblemDefaultsProvider`,
`CustomPostProcessor` and `ThrowingHttpProblemClientExceptionMapper#toThrowable`.

Judgement calls: calls through reflection (Jackson or JSON-B bean introspection, CDI, JAX-RS) are not calls in the code
and are not counted; the prompt says so ("calls between production methods"). Methods that nothing in the repository calls
(framework entry points such as `toResponse`, `handle`, `testProblem`) are the ends of the chains and are listed.
