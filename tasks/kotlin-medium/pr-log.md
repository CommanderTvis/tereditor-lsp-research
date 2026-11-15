# Mined pull requests: log

Candidates in the seeded order of `pr-candidates.jsonl`. The file was produced by a scratch copy of
`harness/gen/mine-prs.sh` whose only change accepts base branch `master` (or `main`) besides the repository's
current default branch: the default branch was renamed after the cutoff, so the unchanged script keeps
0 of 43 qualifying pull requests.

Every candidate is skipped for the same measured reason: the Gradle wrapper at its base commit cannot run on the
study's JDK 21, the only JDK in `grade-jvm` and in the server sandbox. Measured in the grading sandbox with scratch
projects using the newest wrapper among the candidates of each project (7.5.1: "Unsupported class file major version
65"; 6.8.2: "Could not compile settings file ... startup failed"); Gradle runs on Java 21 from 8.5 on, and the builds
of that time (Kotlin Gradle plugin 1.3 to 1.7) do not run on Gradle 8.5 or later. No candidate was set up, and none
was rewritten to a newer build.

| # | Pull request | Merged | Base commit | Gradle wrapper at base | Outcome |
| --- | --- | --- | --- | --- | --- |
| 1 | #994 | 2020-10-09 | `e45f479466929f04868e551e6a748bd3def3f8eb` | 6.6.1 | skipped: wrapper needs a JDK older than 21 |
| 2 | #1167 | 2021-10-15 | `b4d77c02bf8c024610c4b9c04205d94e65b40dee` | 7.2 | skipped: wrapper needs a JDK older than 21 |
| 3 | #1147 | 2021-09-15 | `1ace38a2666589ac9480f66b3fad8196994b97f0` | 7.2 | skipped: wrapper needs a JDK older than 21 |
| 4 | #788 | 2019-09-17 | `9ad05ac87e425f468f36c905d925ddf0a4fb2e2b` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 5 | #1032 | 2021-01-07 | `fc4dbca6e430550a1aad7955d938327003f931ca` | 6.6.1 | skipped: wrapper needs a JDK older than 21 |
| 6 | #754 | 2019-08-21 | `5191148441af1861174e550b891eb2da79627945` | 5.6 | skipped: wrapper needs a JDK older than 21 |
| 7 | #909 | 2020-05-06 | `2e7360f3a2908f245e1b1b06c9c2b5a205cd88c5` | 6.3 | skipped: wrapper needs a JDK older than 21 |
| 8 | #1321 | 2022-07-26 | `2a503bd14eb615569bcd781e40a4ad8fd7c17bd8` | 7.5 | skipped: wrapper needs a JDK older than 21 |
| 9 | #614 | 2019-02-06 | `0b172fc9a3af6b0090ececeac28d893442c29e81` | 5.1 | skipped: wrapper needs a JDK older than 21 |
| 10 | #1331 | 2022-07-25 | `aca6a5220be894bd30afc196e358c4dca4a5a4ee` | 7.5 | skipped: wrapper needs a JDK older than 21 |
| 11 | #862 | 2020-01-07 | `330c9b8562cdf3704a41278172ed02517ad1561b` | 6.0.1 | skipped: wrapper needs a JDK older than 21 |
| 12 | #1340 | 2022-08-08 | `56c48fdb554a9017088e71ee058030d85a368472` | 7.5.1 | skipped: wrapper needs a JDK older than 21 |
| 13 | #977 | 2020-09-21 | `69de1884ac036f91e56fe15c734835e1e657702c` | 6.5 | skipped: wrapper needs a JDK older than 21 |
| 14 | #1222 | 2022-03-01 | `9570abacd3e5424e325719121ab3b7bccb2032d5` | 7.4 | skipped: wrapper needs a JDK older than 21 |
| 15 | #1193 | 2021-11-30 | `c1e7fd5a95c8c5cc9e5d831efd3b5f0037f488df` | 7.3 | skipped: wrapper needs a JDK older than 21 |
| 16 | #626 | 2019-02-19 | `a6d8434090df19b4769dc10245a94571087a031d` | 5.2 | skipped: wrapper needs a JDK older than 21 |
| 17 | #781 | 2019-09-16 | `4442d037bf7723b715cf29509ad1c4b8c9d61c21` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 18 | #731 | 2019-07-28 | `9f5426c391d85699c427de15e8fb593b4aad267b` | 5.5 | skipped: wrapper needs a JDK older than 21 |
| 19 | #1342 | 2022-08-11 | `eef4d76ac7655ddd96a9f547bdeabc92837a5e8a` | 7.5.1 | skipped: wrapper needs a JDK older than 21 |
| 20 | #882 | 2020-03-03 | `dcaba043eac9baa6d57ccc8b770b498397fec662` | 6.2.1 | skipped: wrapper needs a JDK older than 21 |
| 21 | #1091 | 2021-06-21 | `5e9450f12de7fb9e5c3393caac82c8c029203a2f` | 7.0.2 | skipped: wrapper needs a JDK older than 21 |
| 22 | #668 | 2019-04-21 | `d20ed3efa2500c312e90ed8077c7238fc6af7a23` | 5.4 | skipped: wrapper needs a JDK older than 21 |
| 23 | #1179 | 2021-10-25 | `d544b45455d90547a17ca58622ddcdd0148d08fa` | 7.2 | skipped: wrapper needs a JDK older than 21 |
| 24 | #1355 | 2022-09-06 | `a6a9d0c96a773bda95d2ad0d238b6807116acf4a` | 7.5.1 | skipped: wrapper needs a JDK older than 21 |
| 25 | #739 | 2019-08-04 | `7cb6a7b1cb25384690658d2f95cb62e59b7ed8a7` | 5.5 | skipped: wrapper needs a JDK older than 21 |
| 26 | #794 | 2019-09-24 | `267906871c1b5c061de43773900e50ce308aaf58` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 27 | #748 | 2019-08-19 | `be6b3b065c69b6259f24f627ae4d6ad2e90bba03` | 5.6 | skipped: wrapper needs a JDK older than 21 |
| 28 | #798 | 2019-09-24 | `1ea84de5dc3aa9f22ddcf1c58013e0e570113a66` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 29 | #873 | 2020-01-17 | `54d78b20709cbed097597ac196dabba80a18eda9` | 6.0.1 | skipped: wrapper needs a JDK older than 21 |
| 30 | #1384 | 2022-10-18 | `a61a1be9727d4c5f6336b9ffe84f820bd7dba0a2` | 7.5.1 | skipped: wrapper needs a JDK older than 21 |
| 31 | #783 | 2019-09-16 | `4442d037bf7723b715cf29509ad1c4b8c9d61c21` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 32 | #815 | 2019-10-19 | `8671c572494ee15947ebb2bf7315884e0d803477` | 5.6.2 | skipped: wrapper needs a JDK older than 21 |
| 33 | #1140 | 2021-09-20 | `1cdad8acd73aa7e479e36b4015187cedca0541ff` | 7.2 | skipped: wrapper needs a JDK older than 21 |
| 34 | #1338 | 2022-08-08 | `d685eca08d6de064bdf16511be496bcd17e668ab` | 7.5 | skipped: wrapper needs a JDK older than 21 |
| 35 | #760 | 2019-08-23 | `6f65aa1e4cb89da6daf89ab30b2317bde5390289` | 5.6 | skipped: wrapper needs a JDK older than 21 |
| 36 | #690 | 2019-04-23 | `8cfc9dfaa4b2ab09aedc3dc3bd1da304a6dff07a` | 5.4 | skipped: wrapper needs a JDK older than 21 |
| 37 | #449 | 2019-08-24 | `9f5426c391d85699c427de15e8fb593b4aad267b` | 5.5 | skipped: wrapper needs a JDK older than 21 |
| 38 | #1235 | 2022-04-19 | `69f6bb4e2e3aff9502ffce1cc871b1a16c397ca8` | 7.4 | skipped: wrapper needs a JDK older than 21 |
| 39 | #859 | 2020-01-01 | `d556f2d5cf2d8b73c3010e9387df7142fd204849` | 6.0.1 | skipped: wrapper needs a JDK older than 21 |
| 40 | #1233 | 2022-04-18 | `cec7a96c47a3bf4748cd88b3295cd275125e98f7` | 7.4 | skipped: wrapper needs a JDK older than 21 |

Valid mined tasks: 0. The three `pr` places are filled with synthetic tasks of the next types in the rotation
(recorded in `projects/kotlin-medium/project.toml`).
