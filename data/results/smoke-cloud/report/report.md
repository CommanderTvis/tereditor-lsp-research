# Report: smoke-cloud

Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. Strata under 10 tasks show counts only.

Runs finished: 4; excluded (contamination or never reached the model): 0; analysed: 4; tasks: 1; total cost: $0.01.

## By model and arm

| model            | arm             |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:-----------------|:----------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5 | baseline        |      1 |         1 |          0.0032 |            0.0032 |            24.9 |              3 |          0 |                0 |           1 |           0 |        0 |
| claude-haiku-5-5 | baseline-review |      1 |         1 |          0.0045 |            0.0045 |            19.6 |              6 |          0 |                0 |           2 |           2 |        0 |
| claude-haiku-5-5 | enforced        |      1 |         0 |          0.0052 |            0.0052 |            39.4 |              4 |          1 |                1 |           0 |           0 |        0 |
| claude-haiku-5-5 | optional        |      1 |         1 |          0.0019 |            0.0019 |            10.6 |              3 |          0 |                0 |           1 |           0 |        0 |

## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; for cost, better = cheaper)

| stratum   | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| all       | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| all       | cost ratio   | baseline-review / baseline |      1.429 |         |         |        0 |      0 |       1 |       1 |       1 |
| all       | success (pp) | optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| all       | cost ratio   | optional / baseline        |      0.61  |         |         |        1 |      0 |       0 |       1 |       1 |
| all       | success (pp) | enforced - baseline        |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| all       | cost ratio   | enforced / baseline        |      1.645 |         |         |        0 |      0 |       1 |       1 |       1 |
| all       | success (pp) | optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| all       | cost ratio   | optional / baseline-review |      0.427 |         |         |        1 |      0 |       0 |       1 |       1 |
| all       | success (pp) | enforced - baseline-review |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| all       | cost ratio   | enforced / baseline-review |      1.151 |         |         |        0 |      0 |       1 |       1 |       1 |

## The same contrasts by stratum

### By model

| stratum                | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:-----------------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| model=claude-haiku-5-5 | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | baseline-review / baseline |      1.429 |         |         |        0 |      0 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | optional / baseline        |      0.61  |         |         |        1 |      0 |       0 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | enforced - baseline        |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | enforced / baseline        |      1.645 |         |         |        0 |      0 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | optional / baseline-review |      0.427 |         |         |        1 |      0 |       0 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | enforced - baseline-review |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | enforced / baseline-review |      1.151 |         |         |        0 |      0 |       1 |       1 |       1 |


### By lang

| stratum     | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| lang=python | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| lang=python | cost ratio   | baseline-review / baseline |      1.429 |         |         |        0 |      0 |       1 |       1 |       1 |
| lang=python | success (pp) | optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| lang=python | cost ratio   | optional / baseline        |      0.61  |         |         |        1 |      0 |       0 |       1 |       1 |
| lang=python | success (pp) | enforced - baseline        |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| lang=python | cost ratio   | enforced / baseline        |      1.645 |         |         |        0 |      0 |       1 |       1 |       1 |
| lang=python | success (pp) | optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| lang=python | cost ratio   | optional / baseline-review |      0.427 |         |         |        1 |      0 |       0 |       1 |       1 |
| lang=python | success (pp) | enforced - baseline-review |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| lang=python | cost ratio   | enforced / baseline-review |      1.151 |         |         |        0 |      0 |       1 |       1 |       1 |


### By size

| stratum    | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:-----------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| size=small | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| size=small | cost ratio   | baseline-review / baseline |      1.429 |         |         |        0 |      0 |       1 |       1 |       1 |
| size=small | success (pp) | optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| size=small | cost ratio   | optional / baseline        |      0.61  |         |         |        1 |      0 |       0 |       1 |       1 |
| size=small | success (pp) | enforced - baseline        |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| size=small | cost ratio   | enforced / baseline        |      1.645 |         |         |        0 |      0 |       1 |       1 |       1 |
| size=small | success (pp) | optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| size=small | cost ratio   | optional / baseline-review |      0.427 |         |         |        1 |      0 |       0 |       1 |       1 |
| size=small | success (pp) | enforced - baseline-review |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| size=small | cost ratio   | enforced / baseline-review |      1.151 |         |         |        0 |      0 |       1 |       1 |       1 |


### By task_type

| stratum        | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:---------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| task_type=refs | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs | cost ratio   | baseline-review / baseline |      1.429 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs | success (pp) | optional - baseline        |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs | cost ratio   | optional / baseline        |      0.61  |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=refs | success (pp) | enforced - baseline        |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | enforced / baseline        |      1.645 |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs | success (pp) | optional - baseline-review |      0     |         |         |        0 |      1 |       0 |       1 |       1 |
| task_type=refs | cost ratio   | optional / baseline-review |      0.427 |         |         |        1 |      0 |       0 |       1 |       1 |
| task_type=refs | success (pp) | enforced - baseline-review |   -100     |         |         |        0 |      0 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | enforced / baseline-review |      1.151 |         |         |        0 |      0 |       1 |       1 |       1 |


## LSP adoption in the optional arm (observational)

| model            |   runs |   lsp_used |   success_when_used |   success_when_not |
|:-----------------|-------:|-----------:|--------------------:|-------------------:|
| claude-haiku-5-5 |      1 |          0 |                 nan |                  1 |

## LSP operations used (all arms)

|                         |   calls |
|:------------------------|--------:|
| lsp_navigate:references |       1 |
