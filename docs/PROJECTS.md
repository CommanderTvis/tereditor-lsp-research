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
ratio) was chosen among well-known, maintained projects whose build and tests can run in a container.

| Size | Band | Target |
| --- | --- | --- |
| small | 3k to 12k | 6k |
| medium | 25k to 80k | 45k |
| large | 140k to 450k | 250k |
| xlarge | 700k to 3M | 1.2M |

## Selection

Lines are thousands of code lines in the main language at the pin.

| Language | small | medium | large | xlarge |
| --- | --- | --- | --- | --- |
| Python | toolz 1.2.0: 5.8 | rich 15.0.0: 45.0 | mypy 2.4.1: 216.6 | salt 3007.17: 1,121.9 |
| TypeScript | superstruct 2.0.2: 4.6 | hono 4.13.18: 63.1 | typeorm 1.1.3: 233.1 | angular 22.2.6: 775.6 |
| C# | MediatR @8a64581: 7.6 | AutoMapper 16.3.0: 56.6 | jellyfin 12.4: 254.9 | aspnetcore 10.0.15: 1,138.6 |
| PHP | league/container 5.2.0: 3.8 | guzzle 8.3.1: 47.5 | laravel/framework 13.42.0: 369.0 | drupal 11.4.12: 985.0 |
| Kotlin | kotlin-result 2.3.1: 8.5 | kotlinpoet 2.4.0: 32.8 | ktor 3.6.1: 211.3 | JetBrains/kotlin 2.4.21: 2,533.7 |
| Java | javapoet 1.13.0: 9.6 | gson 2.15.0: 38.9 | jackson-databind 3.3.0: 220.7 | lucene 10.6.0: 979.9 |
| Java+Kotlin | none found | moshi 1.15.0: 26.6 (69% Java) | dagger 2.60.1: 142.4 (88% Java) | gradle 9.9.1: 731.9 (77% Java) |
| C/C++ | tinyxml2 11.0.0: 5.8 | fmt 12.2.1: 47.3 | redis 8.10.3: 260.7 | postgres REL_18_7: 1,082.2 |
| Shell | bats-core 1.14.0: 4.5 | acme.sh 3.1.6: 52.7 | none exists | none exists |
| CSS/SCSS | primer/css 22.3.0: 5.6 | carbon 11.120.0: 64.4 | none exists | none exists |

Every chosen size is inside its band. Medians across languages: small 5.8k, medium 47k, large 227k, xlarge 1.03M.

## Gaps and judgement calls

- Shell and CSS have no credible project above about 100k source lines (the largest found: acme.sh 53k,
  bash-completion and Bash-it under 20k; Carbon 64k of Sass, Bulma 14k, Bootstrap 10k). Their large and xlarge
  cells are empty, and the analysis treats size as nested in language, so the gap does not bias the other cells.
- Mixed Java+Kotlin small: no well-known project of 3k to 12k lines with both languages above 10% was found. Empty.
- Mixed Java+Kotlin large: dagger is 12% Kotlin, the most balanced large candidate (corda is 94% Kotlin,
  intellij-plugins 92% Java, openrewrite 99% Java). Its 142k is just inside the band.
- Mixed xlarge: gradle (732k) rather than intellij-community (9.0M, about 4x the top of the band and likely
  too large to import in a container).
- Kotlin: kotlin-result and ktor are Kotlin Multiplatform builds; no pure-JVM Kotlin project of comparable fame
  falls in those bands (kotlinx-knit 2.6k and kotlin-retry 1.5k are below small; clikt 14.5k and the
  compiler server 16k are above it and multiplatform or app-like; dokka 108k and Exposed 124k are below large).
  Their import time is measured by the probe and reported.
- xlarge TypeScript: angular (776k) rather than VS Code (4.2M, above the band). C/C++: postgres (1.08M C) rather
  than LLVM (10.1M) or the Linux kernel. Python: salt (1.12M) rather than Home Assistant (3.4M).
- Large Python: mypy (217k) is closest to the target; django (433k) and scikit-learn (333k, a compiled
  extension build) were in band but further from it. mypy's code is fully type-annotated, which favours a type-aware
  server; that is a property of the project, recorded here.
- Two pins predate the latest release because tasks were written against them: MediatR at 8a64581 (7.6k; the
  14.3.0 release has 10.7k) and toolz at 451af60 (the 1.2.0 release commit).

## Considered and not chosen

Python: attrs, more-itertools, httpx, requests, flask (byte survey only), click 22.3, ansible 195.3,
scikit-learn 333.4, django 432.7, Home Assistant 3,360.0. TypeScript: ky 29.1, zod 83.5, trpc and date-fns (bytes
only), nest 175.2, excalidraw 113.4, prisma 189.7, VS Code 4,234.0. C#: Scrutor 3.7, MediatR 14.3.0 10.7,
FluentValidation 16.5, Polly 72.6, ILSpy 292.3, Orleans 576.8. PHP: flysystem 13.6, monolog 19.5, composer 99.5,
phpunit 147.9, Magento 1,938.5. Kotlin: koin 25.7, sqldelight 53.1, ktlint 73.9, detekt 96.5, Exposed 124.4,
dokka 108.4, kotest 158.3, clikt 14.5. Java: jsoup 47.9, commons-lang 113.3, spring-framework 855.9.
Java+Kotlin: retrofit 29.3 (4% Kotlin), xodus 88.6, ksp 44.7 (97% Kotlin), intellij-community 8,969.5.
C/C++: cJSON 10.3, jq 22.3, libuv 79.7, curl 210.9, git 325.8, php-src 1,642.3, qemu 1,799.4, godot 1,212.7,
LLVM 10,145.7. Shell: asdf 0.8, neofetch 8.9, nvm 19.3, Bash-it 16.8. CSS: Bootstrap 9.6 (Sass), Bulma 14.0 (Sass).
