# Constraint inference: chained constraints can't revise a covariant binding

Follow-up from #1184 (which closes #1180).

#1184 infers extra type parameters on open behaviors and processors from their constraints, and closes them for scanned request types. One case is still not handled. A parameter can be inferred directly, and also through a chain of constraints on another inferred parameter. When those two routes give different types because of covariance, the first binding can be the wrong one. The behavior is then silently skipped for that request.

### Example (from the Codex review on #1184)

```csharp
public interface ICovariant<out T> { }
public interface IInvariant<T> { }

public class Base { }
public class Derived : Base { }
public class Holder : ICovariant<Base> { }

public class Request : IRequest<Unit>, ICovariant<Derived>, IInvariant<Holder> { }

public class ChainBehavior<TRequest, TResponse, TItem, THolder> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : ICovariant<TItem>, IInvariant<THolder>
    where THolder : ICovariant<TItem> { ... }
```

`TItem = Base, THolder = Holder` is valid. But the first pass binds `TItem = Derived` (from `TRequest : ICovariant<TItem>`) and `THolder = Holder`. All parameters are now bound, so inference stops. The constraint `THolder : ICovariant<TItem>` never gets to offer `Base` as a candidate. `MakeGenericType` rejects `TItem = Derived`, and the behavior isn't registered.

### Possible fix

In `ExpandBindingsFromConstraints` (`src/MediatR/Registration/ServiceRegistrar.cs`), don't stop when every parameter is bound. Keep collecting candidates from the constraints of newly bound parameters, including for parameters that are already bound, until nothing new is added. Then branch over the combinations. Add a regression test alongside the others in `test/MediatR.Tests/MicrosoftExtensionsDI/OpenGenericConstraintInferenceTests.cs`.

### Scope

This only affects behaviors with chained constraints combined with covariant marker interfaces. The case in #1180, nested responses, and the cases covered by #1184's tests already work.

