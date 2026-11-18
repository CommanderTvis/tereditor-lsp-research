# Projects

One project per language and size class. Size is measured the same way for every language, so a "large" Python
project is comparable to a "large" Kotlin one.

## Size measure

Code lines in the project's main language: `scc` 3.5.0, blank and comment lines excluded, tests included,
`vendor/`, `third_party/`, `external/` and `node_modules/` skipped, at the pinned commit. Language groups:
C/C++ counts C, C++ and their headers; TypeScript counts `.ts` and `.d.ts`; Shell counts sh, bash and zsh;
CSS counts Sass/SCSS sources only (compiled `.css` in `dist/` is output, not source); mixed Java+Kotlin counts both
and requires each language to be at least 10% of the total.

Reproduce every number below with `sh harness/size/measure.sh > counts.jsonl` (container runtime only);
`harness/size/counts.jsonl` holds the measurement of all 98 candidates considered, chosen or not.

## Bands

Geometric bands, about 7x apart, the same for every language. Within a band the project closest to the target (in
ratio) was chosen among maintained projects with pull requests merged since 2026-07-01 that close issues (the source of the
mined tasks), whose build and tests can run in a container.

| Size | Band | Target |
| --- | --- | --- |
| small | 3k to 12k | 6k |
| medium | 25k to 80k | 45k |
| large | 140k to 450k | 250k |
| xlarge | 700k to 3M | 1.2M |

## Selection

Lines are thousands of code lines in the main language at the pin; projects without a release tag are pinned to a dated
commit (the full SHAs are in each `project.toml`). Per-project size deviations are in its `size_note`.

| Language | small | medium | large | xlarge |
| --- | --- | --- | --- | --- |
| Python | pydantic-extra-types v2.11.2: 10.3 | astroid v4.3.4: 52.3 | mypy v2.4.1: 216.6 | salt v3007.17: 1,121.9 |
| TypeScript | node-server v2.1.8: 7.9 | hono @f6fbaf0: 63.1 | typeorm 1.1.3: 233.1 | payload @ec35164: 855.9 |
| C# | MediatR v12.5.0: 7.6 | AutoMapper v16.3.0: 56.6 | jellyfin v12.4: 254.9 | efcore v11.0.0: 1,312.0 |
| PHP | laravel-datatables v13.3.1: 6.5 | scramble v0.13.55: 55.6 | framework v13.42.0: 369.0 | shopware v6.7.16.0: 1,102.4 |
| Kotlin | compose-lints 1.6.1: 13.4 | kotlinpoet 2.4.0: 32.8 | dataframe master-2026-11-17: 155.3 | — |
| Java | quarkus-http-problem 3.38.2: 7.0 | gson @fcd4169: 38.9 | jackson-databind jackson-databind-3.3.0: 220.7 | lucene releases/lucene/10.6.0: 979.9 |
| Java+Kotlin | — | pact-jvm 4_7_7: 63.4 | embabel-agent main-2026-11-17: 243.7 | gradle v9.9.1: 731.9 |
| C/C++ | md4c v0.6.0: 8.9 | fmt 12.2.1: 47.3 | redis 8.10.3: 260.7 | duckdb v2.0.0: 845.5 |
| Shell | bats-core v1.14.0: 4.5 | nvm v0.41.0: 19.3 | — | — |
| CSS/SCSS | tabler @tabler/core@1.7.5: 20.4 | carbon v11.120.0: 64.4 | — | — |
