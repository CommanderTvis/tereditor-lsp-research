# Mined pull requests: php-small (league/container)

Candidates: `tasks/php-small/pr-candidates.jsonl`, from `harness/gen/mine-prs.sh` with one change (see below), in its
seeded order. Every pull request is taken or skipped in that order.

`harness/gen/mine-prs.sh` as committed keeps only pull requests whose base branch is today's default branch (`6.x`); every
pre-cutoff pull request of this repository targets `master`, `1.x`, `3.x`, `4.x` or `develop`, so it finds none. The
candidates were mined with a scratch copy whose base-branch filter also accepts `master`, `main`, `develop` and
release-line branches (`^(master|main|develop|[0-9]+\.(x|[0-9]+))$`), everything else unchanged: 4 pull requests
qualify.

| PR | Merged | Base | Issue | Outcome |
| --- | --- | --- | --- | --- |
| #11 | 2015-01-29 | 2fb01a4958 | #10 | skipped: needs PHP >=5.4 with PHPUnit 4.*; PHPUnit 4 does not run on PHP 8.4 (the grading toolchain) |
| #79 | 2015-09-07 | 4499edb99d | #78 | skipped: PHPUnit 4.* (as #11) |
| #152 | 2018-08-13 | f957996f2d | #151 | skipped: composer.json requires `php: ^7.0` and PHPUnit ^6.0; neither installs on PHP 8.4 |
| #164 | 2019-06-30 | fa38155fa3 | #157 | skipped: `php: ^7.0`, PHPUnit ^6.0 (as #152) |

Candidates ran out with 0 valid tasks. The 3 `pr` places are filled with synthetic tasks of the next types in the
rotation (docs/TASKS.md): `rename` and `rename-file` (refactorings after `signature`) and `refs` (navigation after
`inspect`); recorded in `projects/php-small/project.toml`.
