Old text is left at the end of the status bar in the console

### Current Behavior

Sometimes, output is written above the status bar, and more worker lines are added in the same update of the console.
Then the end of an old worker line can be left after the status bar.
The status bar is drawn again lower, on the row of an old worker line.
When this old line is longer than the status bar, its end is not erased.
This end is left until the area of the status bar and the worker lines is moved again.

Example with three tasks with long names, in parallel.
One line is written by `prepareTheEnvironmentOfTheParallelTasks`, and three tasks that depend on it are started when it is complete:

```
time after client start   console
 1.5 s                    │···············│ 0% EXECUTING [1s]
                          > :downloadTheDependenciesOfTheParallelTasks
                          > :generateTheSourcesOfTheParallelTasks
                          > :prepareTheEnvironmentOfTheParallelTasks
 2.5 s
                          > Task :prepareTheEnvironmentOfTheParallelTasks
                          Environment ready
                          │██▏············│ 14% EXECUTING [2s]lTasks
                          > :downloadTheDependenciesOfTheParallelTasks
                          > :generateTheSourcesOfTheParallelTasks
                          > :work1
                          > :work2
                          > :work3
 6.5 s
                          > Task :prepareTheEnvironmentOfTheParallelTasks
                          Environment ready
                          │██▏············│ 14% EXECUTING [6s]lTasks
                          > :downloadTheDependenciesOfTheParallelTasks
                          > :generateTheSourcesOfTheParallelTasks
                          > :work1
                          > :work2
                          > :work3
```

The text that is left depends on the order of the worker lines, for example `lTasks`, `lelTasks` or `sks`.
The same is seen with the prompt at the bottom of the terminal, and in a terminal with free rows below the prompt.

On master, the fingerprint check of the configuration cache is shown on a worker line since #39541.
Thus, the same is seen on each configuration cache hit with a slow fingerprint check.
`Reusing configuration cache.` is written on the row of the status bar, and the tasks are started in the same update:

```
Reusing configuration cache.
│···············│ 0% EXECUTING [3s]erprint
> :work1
> :work2
> :work3
```

### Expected Behavior

When a line is drawn on another row than before, the end of the row is erased:

```
> Task :prepareTheEnvironmentOfTheParallelTasks
Environment ready
│██▏············│ 14% EXECUTING [2s]
> :downloadTheDependenciesOfTheParallelTasks
> :generateTheSourcesOfTheParallelTasks
> :work1
> :work2
> :work3
```

### Context (optional)

The status bar and the worker lines are drawn in `MultiLineBuildProgressArea.redraw()`.
In an update, the area is moved down by the rows of new output, and rows are added for new worker lines.
Each line is compared with the old text of the line that is lower by the sum of these two numbers of rows.
The end of the row is erased if this old text was longer.
But the old text under a line is the text of the line that is lower by the rows of new output only.
Thus, when worker lines are added in the same update, the wrong lines are compared.

This comparison was added with the first version of the rich console, in 2017.

### Self-contained Reproducer Project

1. Create `settings.gradle.kts`:

   ```kotlin
   rootProject.name = "leftover"
   ```

2. Create `gradle.properties`, to run the tasks of the project in parallel:

   ```
   org.gradle.configuration-cache=true
   ```

3. Create `build.gradle.kts`:

   ```kotlin
   val prepare = tasks.register("prepareTheEnvironmentOfTheParallelTasks") {
       doLast {
           Thread.sleep(2000)
           println("Environment ready")
       }
   }

   val download = tasks.register("downloadTheDependenciesOfTheParallelTasks") {
       doLast { Thread.sleep(7000) }
   }

   val generate = tasks.register("generateTheSourcesOfTheParallelTasks") {
       doLast { Thread.sleep(7000) }
   }

   val work = (1..3).map { i ->
       tasks.register("work$i") {
           dependsOn(prepare)
           doLast { Thread.sleep(5000) }
       }
   }

   tasks.register("all") {
       dependsOn(work, download, generate)
   }
   ```

4. Run the build with the rich console, in a terminal of 80 columns:

   ```
   gradle all
   ```

   After `Environment ready`, the end of a worker line is shown at the end of the status bar until the build is complete.

### Gradle version

9.8.1

### Build scan URL (optional)

_No response_

### Your Environment (optional)

_No response_

