Rich console timer is less than the duration in the build summary

### Current Behavior

The timer on the status bar of the rich console is started when the `Run build` build operation is started in the daemon. The duration in the build summary is measured from the start of the client JVM.

As a result, the time to start the client is not included in the timer value. When a new daemon is started, the time to start the daemon is not included either. Thus, the timer value is less than the duration in the build summary.

Example after `gradle --stop`, for a build with a task of 3 s:

```
time after client start   console
 1.0 s                    │···············│ 0% INITIALIZING [89ms]
 1.5 s                    │···············│ 0% CONFIGURING [589ms]
 1.9 s                    │···············│ 0% EXECUTING [989ms]
 4.0 s                    │···············│ 0% EXECUTING [3s]
 4.9 s                    BUILD SUCCESSFUL in 4s
```

The status bar is shown first at 1.0 s after the start of the client. At that time, the timer value is `[89ms]`. With an empty Gradle user home, the difference was 2.5 s.

When the daemon is already started, the difference is the time to start the client. The first frame is shown at 0.5 s after the start of the client, and the timer value is `[81ms]`.


### Expected Behavior

The timer value is the time since the start of the build, as for the build summary.

In the example above, the timer value of the first frame is `[1s]`. At the end of the build, the timer value is `[4s]`, and the duration in the build summary is `4s`.


### Context (optional)

The timer value and the duration in the build summary are both the duration of the build. With a new daemon, the two values are different by one second or more.

For a Build Scan, the start of the build is also the start of the client, as for the build summary.

In `BuildStatusRenderer`, the timer is started from the timestamp of the first build operation that is received. This TODO comment is in the code: `TODO - should use BuildRequestMetaData to determine the build start time`.

### Self-contained Reproducer Project

1. Create `settings.gradle.kts`:

   ```kotlin
   rootProject.name = "timer-check"
   ```

2. Create `build.gradle.kts`:

   ```kotlin
   tasks.register("slow") { doLast { Thread.sleep(3000) } }
   ```

3. Stop the Gradle daemons:

   ```
   gradle --stop
   ```

4. Run the build with the rich console:

   ```
   gradle --console=rich slow
   ```

5. Compare the timer value on the status bar with the duration in the build summary.

   The first timer value is less than 100 ms, but the command was started approximately 1 s before. The last timer value is approximately 1 s less than the duration in the build summary.

6. To see the time of each frame, stop the daemons again and record the build with asciinema:

   ```
   asciinema rec --command "gradle --console=rich slow" timer.cast
   ```


### Gradle version

9.8.1

### Build scan URL (optional)

_No response_

### Your Environment (optional)

_No response_
