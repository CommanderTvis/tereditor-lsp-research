The planner interface `com.embabel.plan.Planner` (`embabel-agent-api/src/main/kotlin/com/embabel/plan/Planner.kt`) declares

```kotlin
fun planToGoal(
    actions: Collection<Action>,
    goal: Goal,
): P?
```

Change its signature so that the goal comes first: `planToGoal(goal: Goal, actions: Collection<Action>)`. Update everything that implements, overrides or calls it, in main code and tests: the implementations, the default method of the interface that calls it, the validator, and the test call sites. The similarly named `planToGoalFrom` of the GOAP planners is a different method and keeps its signature.

The project must still build and the existing tests must pass.
