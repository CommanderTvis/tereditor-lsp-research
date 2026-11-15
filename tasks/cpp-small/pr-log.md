# Mined pull requests: cpp-small (tinyxml2)

`sh harness/gen/mine-prs.sh cpp-small` keeps no pull request: the project's only test file is `xmltest.cpp`, which
none of the script's test-file patterns matches, so no pull request "adds or changes tests". `pr-candidates.jsonl` was
written by a copy of the script whose test pattern additionally accepts `(^|/)[a-z0-9]*test\.(c|cc|cpp)$` (otherwise
identical, same seed): 3 pull requests qualify, in seeded order 293, 333, 496.

| Candidate | Issue | Base commit | Outcome |
| --- | --- | --- | --- |
| 293 | 291 | 0f922e7c9af73d411646f7faddf909cc9c42ca0e | taken: `pr-293` |
| 333 | 332 | e5e5541af6c22abb6122e82d636c1f92d33d98c5 | taken: `pr-333` |
| 496 | 340 | cd47f8e0d3d7ced34d17c14224351d21cda1c8a9 | taken: `pr-496` |

Each task: `gold.patch` is the pull request's change to `tinyxml2.cpp`/`tinyxml2.h` (merge base to head),
`hidden/xmltest.cpp` its head's test program, `grade.sh` builds the library with that program and requires it to exit
0 with ", Fail 0" (all of its checks, the new ones being the fail-to-pass ones). Built with `c++ -std=gnu++11` directly,
since the CMake files of 2015 and 2016 differ from today's.
