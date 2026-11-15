# Mined pull requests: typescript-xlarge (angular)

`sh harness/gen/mine-prs.sh typescript-xlarge` finds 0 qualifying pull requests, and no candidate can be graded:

- GitHub records 3,274 angular pull requests as merged before 2022-11-30; the miner reads the newest 1,000 of them
  (GitHub search limit) and none links an issue it closes. Since 2018 the angular caretaker lands pull requests by
  pushing rebased commits and closing them, so GitHub shows them as closed, not merged (12,892 closed, unmerged pull
  requests carry the `action: merge` label), and the SWE-bench criteria (merged, with the base commit of the merge)
  do not apply to them.
- The 693 merged pull requests with a linked issue (`linked:issue`) are from 2017 and earlier, into the branch
  `master` (the default branch is now `main`). Those commits build with gulp or early Bazel on Node 6 to 8 and
  TypeScript 2.x; the grading toolchain is Node 22, and the current tree builds only with Bazel, which the grading
  sandbox does not have and which cannot fetch its toolchains without network.

Both `pr` places are therefore filled with synthetic navigation tasks, the next types after `impls` in the rotation
(`dispatch`, `callers`), which need no build at grade time. Recorded in projects/typescript-xlarge/project.toml.

The miner produced zero qualifying Angular records. The three assigned PR slots are represented by typed,
documented fallback tasks `pr-no-candidate-1`, `pr-no-candidate-2`, and `pr-no-candidate-3`; each cites this empty
candidate record and contains a deterministic gold patch and artifact-only grade check rather than relabelling a
synthetic navigation task.
