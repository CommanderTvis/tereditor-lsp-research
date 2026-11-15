# Mined pull requests: log

Candidates in the seeded order of `pr-candidates.jsonl`. The file was produced by a scratch copy of
`harness/gen/mine-prs.sh` whose only change accepts base branch `master` (or `main`) besides the repository's
current default branch: the default branch was renamed after the cutoff, so the unchanged script keeps
2 of 5 qualifying pull requests.

Every candidate is skipped for the same measured reason: the Gradle wrapper at its base commit cannot run on the
study's JDK 21, the only JDK in `grade-jvm` and in the server sandbox. Measured in the grading sandbox with scratch
projects using the newest wrapper among the candidates of each project (7.5.1: "Unsupported class file major version
65"; 6.8.2: "Could not compile settings file ... startup failed"); Gradle runs on Java 21 from 8.5 on, and the builds
of that time (Kotlin Gradle plugin 1.3 to 1.7) do not run on Gradle 8.5 or later. No candidate was set up, and none
was rewritten to a newer build.

| # | Pull request | Merged | Base commit | Gradle wrapper at base | Outcome |
| --- | --- | --- | --- | --- | --- |
| 1 | #2137 | 2020-10-23 | `10481b725681f39cfae7503d3fbe45accea0e4fb` | 6.6.1 | skipped: wrapper needs a JDK older than 21 |
| 2 | #2268 | 2020-12-29 | `f565c9c03afb3eceb8aa0acc987b6bbeb6f023b1` | 6.7.1 | skipped: wrapper needs a JDK older than 21 |
| 3 | #2453 | 2021-05-12 | `c2f4302b69b21bdbc434ad5806a33aa22675149d` | 6.8.2 | skipped: wrapper needs a JDK older than 21 |
| 4 | #2459 | 2021-05-14 | `fcbe555737d7e8a373ea83e7ef4fd94266157dc5` | 6.8.2 | skipped: wrapper needs a JDK older than 21 |
| 5 | #2131 | 2020-10-23 | `c01ab1a2cf3a867a118403b4f7044a79262501c7` | 6.6.1 | skipped: wrapper needs a JDK older than 21 |

Valid mined tasks: 0. The three `pr` places are filled with synthetic tasks of the next types in the rotation
(recorded in `projects/kotlin-large/project.toml`).
