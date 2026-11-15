# Mined pull requests: php-medium (guzzle)

Candidates: `tasks/php-medium/pr-candidates.jsonl` (35), from `harness/gen/mine-prs.sh` with one change, in its seeded
order. The committed script keeps only pull requests whose base branch is today's default branch (`8.5`); every
pre-cutoff pull request targets `master` or `6.5`, so it finds none. A scratch copy whose base-branch filter also
accepts `master`, `main`, `develop` and release-line branches (`^(master|main|develop|[0-9]+\.(x|[0-9]+))$`),
everything else unchanged, found 35.

Gold patches and hidden tests come from the pull request's own diff (`gh pr diff`), split into its non-test and test
files and applied to `base_commit`: the merge commits are squash merges onto a branch that moved after the base, so
base-to-merge diffs would carry unrelated changes. Dependencies: `projects/php-medium/locks/` (one lock per commit,
resolved for PHP 8.4). Guzzle's test bootstrap starts a node.js test server, which the grading toolchain lacks; the
mined tasks' grade.sh run the pull request's test file with the autoloader as bootstrap.

| # | PR | Merged | Base | Issue | Outcome |
| --- | --- | --- | --- | --- | --- |
| 1 | #823 | 2014-09-12 | 9c4fbbf645 | #822 | skipped: PHPUnit ~4.0 (PHP 5 era); does not run on PHP 8.4 |
| 2 | #2242 | 2019-04-15 | c5da4c3128 | #2214 | skipped: PHPUnit at most ^7.0, which requires PHP 7; not installable on PHP 8.4 |
| 3 | #1611 | 2017-02-23 | 4d22214bbe | #1516 | skipped: PHPUnit ^4.0 |
| 4 | #443 | 2013-12-04 | 6e6b9c5424 | #442 | skipped: PHPUnit 3.7 |
| 5 | #1422 | 2016-03-09 | 55ab7c5edc | #1335 | skipped: PHPUnit ~4.0 |
| 6 | #106 | 2012-07-21 | 9f57a33055 | #105 | skipped: PHP >=5.3.2, no PHPUnit in composer.json (Guzzle 2 era) |
| 7 | #772 | 2014-08-18 | d088d32801 | #760 | skipped: PHPUnit ~4.0 |
| 8 | #2712 | 2020-09-30 | 7427d6f99d | #2740 | skipped: composer.json requires `php: ^7.2.5` (no PHP 8) |
| 9 | #2741 | 2020-09-30 | 4552f37ba6 | #2735 | skipped: `php: ^7.2.5` (as #2712) |
| 10 | #675 | 2014-05-19 | ca838eda19 | #674 | skipped: PHPUnit ~4.0 |
| 11 | #2845 | 2022-03-13 | c1fd316f0a | #1477 | taken: `pr-2845`, VALID |
| 12 | #810 | 2014-10-13 | afa6b096d9 | #804 | skipped: PHPUnit ~4.0 |
| 13 | #2348 | 2019-10-24 | 7fad7865dc | #2339 | skipped: PHPUnit at most ^7.0 (as #2242) |
| 14 | #2287 | 2019-10-23 | 2b1dfedd8d | #2248 | skipped: PHPUnit at most ^7.0 |
| 15 | #335 | 2013-06-02 | c40e073446 | #252 | skipped: PHPUnit 3.7 |
| 16 | #2850 | 2021-03-07 | 3a0543e4f5 | #2848 | skipped: its fail-to-pass tests (StreamHandlerTest, CurlFactoryTest proxy tests) send requests to guzzle's node.js test server (`Server::enqueue`, `Server::$url`); the grading toolchain has no node.js |
| 17 | #754 | 2014-08-02 | 119e11a750 | #710 | skipped: PHPUnit ~4.0 |
| 18 | #1509 | 2016-06-30 | 79c6fbef13 | #102 | skipped: PHPUnit ~4.0 |
| 19 | #2286 | 2019-12-07 | 1293c1b6c9 | #2285 | skipped: PHPUnit at most ^7.0 |
| 20 | #2866 | 2021-03-07 | 2793fe24bf | #2857 | taken: `pr-2866`, VALID |
| 21 | #457 | 2013-10-30 | 57e96c16fe | #453 | skipped: PHPUnit 3.7 |
| 22 | #93 | 2012-06-29 | ce60434f54 | #92 | skipped: PHP >=5.3.2, no PHPUnit in composer.json |
| 23 | #513 | 2014-01-03 | 9b42e065dc | #501 | skipped: PHPUnit 3.7 |
| 24 | #732 | 2014-07-14 | 49a14b2bbc | #730 | skipped: PHPUnit ~4.0 |
| 25 | #2916 | 2021-07-17 | 1d46cec19f | #2911 | taken: `pr-2916`, VALID (3 tests of ClientTest.php that need the node.js server are excluded from pass-to-pass) |

Stopped at 3 valid tasks; candidates 26 to 35 were not examined. Code lines at the base commits (scc 3.5.0): 8.8k to
9.1k, against 47.5k at the pin: guzzle 7 was a much smaller code base.
