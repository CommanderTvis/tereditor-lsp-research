# Oracle: swap the parameters of Planner.planToGoal

No navigation answer. Grading (grade.sh) is the build and tests (check.sh), a hidden test that checks the parameter order by reflection and a check of the declaration. The reference solution (gold.patch) is a scripted edit proven by `./study validate`: the compiler rejects every site that was missed, since the two parameters have different types. Trap: `planToGoalFrom` (the GOAP planners' protected hook) has a similar name and keeps its signature.
