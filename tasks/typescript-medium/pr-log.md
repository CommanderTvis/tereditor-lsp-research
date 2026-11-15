# Mined pull requests: typescript-medium (hono)

Candidates from `sh harness/gen/mine-prs.sh typescript-medium` (28 qualify, all in pr-candidates.jsonl in seeded
order), taken strictly in order. The 2022 base commits use Yarn 1 and jest with the miniflare environment:
dependencies come from the committed yarn.lock through `pnpm import` (same versions, no Yarn needed), and jest runs
on the grading toolchain's Node 22. `gold.patch` is the pull request's whole non-test change, including the
generated `deno_dist/` copies it committed; the tests exercise `src/` only.

| PR | Outcome | Reason |
| --- | --- | --- |
| 454 | see validate | |
| 531 | see validate | |
| 513 | see validate | |
