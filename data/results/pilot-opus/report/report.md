# Report: pilot-opus

Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. Strata under 10 tasks show counts only.

Runs finished: 12; excluded (contamination or never reached the model): 0; analysed: 12; tasks: 3; total cost: $6.51.

## By model and arm

| model           | arm               |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |   mean_flaws |
|:----------------|:------------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|-------------:|
| claude-opus-5-5 | baseline          |      3 |     0.667 |          0.3508 |            0.2084 |            22.3 |              5 |      0     |             0    |        6.33 |        8    |        0 |          0   |
| claude-opus-5-5 | baseline-review   |      3 |     0.667 |          0.9377 |            0.4895 |            33.7 |              9 |      0     |             0    |        8    |       10.67 |        0 |          0   |
| claude-opus-5-5 | intellij-enforced |      3 |     0.667 |          0.5037 |            0.4023 |           160.1 |             12 |      1     |             4.33 |        4.67 |        6.67 |        0 |          0.5 |
| claude-opus-5-5 | intellij-optional |      3 |     0.667 |          0.3768 |            0.1546 |            22.3 |              5 |      0.333 |             0.33 |        5.33 |        8.67 |        0 |          0.5 |

## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; for cost, better = cheaper)

| stratum   | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| all       | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| all       | cost ratio        | baseline-review / baseline          |      2.751 |         |         |        0 |      0 |       3 |       3 |       3 |
| all       | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| all       | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| all       | cost ratio        | intellij-optional / baseline        |      1     |         |         |        1 |      0 |       2 |       3 |       3 |
| all       | flaws (mean diff) | intellij-optional - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| all       | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| all       | cost ratio        | intellij-enforced / baseline        |      1.728 |         |         |        0 |      0 |       3 |       3 |       3 |
| all       | flaws (mean diff) | intellij-enforced - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| all       | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| all       | cost ratio        | intellij-optional / baseline-review |      0.363 |         |         |        3 |      0 |       0 |       3 |       3 |
| all       | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| all       | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| all       | cost ratio        | intellij-enforced / baseline-review |      0.628 |         |         |        3 |      0 |       0 |       3 |       3 |
| all       | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |

## The same contrasts by stratum

### By model

| stratum               | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| model=claude-opus-5-5 | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-opus-5-5 | cost ratio        | baseline-review / baseline          |      2.751 |         |         |        0 |      0 |       3 |       3 |       3 |
| model=claude-opus-5-5 | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-opus-5-5 | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-opus-5-5 | cost ratio        | intellij-optional / baseline        |      1     |         |         |        1 |      0 |       2 |       3 |       3 |
| model=claude-opus-5-5 | flaws (mean diff) | intellij-optional - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| model=claude-opus-5-5 | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-opus-5-5 | cost ratio        | intellij-enforced / baseline        |      1.728 |         |         |        0 |      0 |       3 |       3 |       3 |
| model=claude-opus-5-5 | flaws (mean diff) | intellij-enforced - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| model=claude-opus-5-5 | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-opus-5-5 | cost ratio        | intellij-optional / baseline-review |      0.363 |         |         |        3 |      0 |       0 |       3 |       3 |
| model=claude-opus-5-5 | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| model=claude-opus-5-5 | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-opus-5-5 | cost ratio        | intellij-enforced / baseline-review |      0.628 |         |         |        3 |      0 |       0 |       3 |       3 |
| model=claude-opus-5-5 | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |


### By lang

| stratum   | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| lang=java | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| lang=java | cost ratio        | baseline-review / baseline          |      2.751 |         |         |        0 |      0 |       3 |       3 |       3 |
| lang=java | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| lang=java | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| lang=java | cost ratio        | intellij-optional / baseline        |      1     |         |         |        1 |      0 |       2 |       3 |       3 |
| lang=java | flaws (mean diff) | intellij-optional - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| lang=java | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| lang=java | cost ratio        | intellij-enforced / baseline        |      1.728 |         |         |        0 |      0 |       3 |       3 |       3 |
| lang=java | flaws (mean diff) | intellij-enforced - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| lang=java | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| lang=java | cost ratio        | intellij-optional / baseline-review |      0.363 |         |         |        3 |      0 |       0 |       3 |       3 |
| lang=java | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| lang=java | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| lang=java | cost ratio        | intellij-enforced / baseline-review |      0.628 |         |         |        3 |      0 |       0 |       3 |       3 |
| lang=java | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |


### By size

| stratum    | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:-----------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| size=large | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| size=large | cost ratio        | baseline-review / baseline          |      2.751 |         |         |        0 |      0 |       3 |       3 |       3 |
| size=large | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| size=large | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| size=large | cost ratio        | intellij-optional / baseline        |      1     |         |         |        1 |      0 |       2 |       3 |       3 |
| size=large | flaws (mean diff) | intellij-optional - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| size=large | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| size=large | cost ratio        | intellij-enforced / baseline        |      1.728 |         |         |        0 |      0 |       3 |       3 |       3 |
| size=large | flaws (mean diff) | intellij-enforced - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| size=large | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| size=large | cost ratio        | intellij-optional / baseline-review |      0.363 |         |         |        3 |      0 |       0 |       3 |       3 |
| size=large | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| size=large | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| size=large | cost ratio        | intellij-enforced / baseline-review |      0.628 |         |         |        3 |      0 |       0 |       3 |       3 |
| size=large | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |


### By task_type

| stratum             | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:--------------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| task_type=pr        | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | cost ratio        | baseline-review / baseline          |      2.7   |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | cost ratio        | intellij-optional / baseline        |      1.155 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | flaws (mean diff) | intellij-optional - baseline        |      1     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | cost ratio        | intellij-enforced / baseline        |      1.226 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | flaws (mean diff) | intellij-enforced - baseline        |      1     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | cost ratio        | intellij-optional / baseline-review |      0.428 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=pr        | flaws (mean diff) | intellij-optional - baseline-review |      1     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=pr        | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=pr        | cost ratio        | intellij-enforced / baseline-review |      0.454 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=pr        | flaws (mean diff) | intellij-enforced - baseline-review |      1     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs      | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs      | cost ratio        | baseline-review / baseline          |      3.282 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs      | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs      | cost ratio        | intellij-optional / baseline        |      1.165 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs      | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs      | cost ratio        | intellij-enforced / baseline        |      2.181 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs      | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs      | cost ratio        | intellij-optional / baseline-review |      0.355 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=refs      | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs      | cost ratio        | intellij-enforced / baseline-review |      0.665 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=signature | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | cost ratio        | baseline-review / baseline          |      2.349 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=signature | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | cost ratio        | intellij-optional / baseline        |      0.742 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=signature | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | cost ratio        | intellij-enforced / baseline        |      1.931 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=signature | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | cost ratio        | intellij-optional / baseline-review |      0.316 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=signature | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=signature | cost ratio        | intellij-enforced / baseline-review |      0.822 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=signature | flaws (mean diff) | intellij-enforced - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |


### By probe_half

| stratum                                   | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------------------------------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| probe_half=probe score at or below median | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| probe_half=probe score at or below median | cost ratio        | baseline-review / baseline          |      2.751 |         |         |        0 |      0 |       3 |       3 |       3 |
| probe_half=probe score at or below median | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline        |      1     |         |         |        1 |      0 |       2 |       3 |       3 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline        |      1.728 |         |         |        0 |      0 |       3 |       3 |       3 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline        |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline-review |      0.363 |         |         |        3 |      0 |       0 |       3 |       3 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline-review |      0.628 |         |         |        3 |      0 |       0 |       3 |       3 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |


## LSP operations used (all arms)

|                               |   calls |
|:------------------------------|--------:|
| lsp_navigate:references       |       6 |
| lsp_diagnostics:              |       5 |
| lsp_navigate:workspaceSymbols |       2 |
| lsp_navigate:implementation   |       1 |
