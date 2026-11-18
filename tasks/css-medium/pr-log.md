# Mined pull requests: css-medium (carbon)

`sh harness/gen/mine-prs.sh css-medium`: 89 modern pull requests qualify (opened on or after 2026-07-01, merged, closing an
issue, tests plus Sass source); the first 40 in seeded order are in `pr-candidates.jsonl`, taken strictly in that order.
Carbon merges by squash, so the base commit of a task is the parent of the merge commit (the REST `base.sha` of the pull
request, from when it was opened, is stored as `rest_base_sha`); `gold.patch` is every non-test, non-e2e file the pull
request changed, hidden tests are the post-merge versions of the test files and snapshots it changed. Each candidate was run
in the grading sandbox with the repository's Jest 30 (`grade-setup.sh`: yarn install without install scripts, lerna build of
the packages the tests import): its test files applied to the base commit, then with its non-test change; a candidate needs at
least one test that fails at the base commit and passes with the reference change.

| Order | PR | Issue | Outcome |
| --- | --- | --- | --- |
| 1 | #23092 | Move new Tearsheet React component to core | task `pr-23092` (27 fail-to-pass, 0 pass-to-pass; `packages/react/src/components/Tearsheet/__tests__/Tearsheet-test.js`) |
| 2 | #23539 | Migrate `PageHeader` web component from ibm-products to `@carbon/web-components` | skipped: its changed tests cannot be run by the grading toolchain: web-components/src/components/page-header-deprecated/__tests__/__snapshots__/page-header-test.snap.js, web-components/src/components/page-header-deprecated/__tests__/page-header-test.js (web components tests need web-test-runner and a browser; the root Jest configuration ignores packages/web-components) |
| 3 | #22728 | Move Labs' DatePicker into Core as `Preview` | task `pr-22728` (41 fail-to-pass, 0 pass-to-pass; `react/src/__tests__/index-test.js, utilities/src/date-picker/primitives/__tests__/calendar-grid-test.js, utilities/src/date-picker/primitives/__tests__/calendar-labels-test.js, utilities/src/date-picker/primitives/__tests__/click-outside-handler-test.js, utilities/src/date-picker/primitives/__tests__/machine-focus-restoration-test.js`) |
| 4 | #22713 | Feature Flags: Notify consumers of available flags | task `pr-22713` (10 fail-to-pass, 13 pass-to-pass; `feature-flags/src/__tests__/feature-flags-test.js, react/src/components/FeatureFlags/__tests__/FeatureFlags-test.js`) |

Stopped at three accepted tasks. The tests of #23092 and #22728 add whole components or move code (large reference
patches: 1292 and 3471 added lines), so their tests fail at the base commit because the modules do not exist; that is the
registered selection rule, not a choice. #22728 also changes web components tests (not runnable here), which are not
part of its grading. The memorization probe is a measurement (`memprobe.txt` in each task).
