# Report: pilot

Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. Strata under 10 tasks show counts only.

Runs finished: 72; excluded (contamination or never reached the model): 0; analysed: 72; tasks: 8; total cost: $12.82.

## By model and arm

| model             | arm             |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:------------------|:----------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5  | baseline        |      8 |     0.75  |          0.0083 |            0.0052 |            28   |            9   |          0 |             0    |        5.12 |        4.88 |        0 |
| claude-haiku-5-5  | baseline-review |      8 |     0.75  |          0.0206 |            0.0106 |            32.5 |           10   |          0 |             0    |        6.5  |        7.5  |        0 |
| claude-haiku-5-5  | enforced        |      8 |     0.75  |          0.0118 |            0.0122 |            52.9 |           17   |          1 |             4.75 |        2.25 |        4.12 |        0 |
| claude-opus-5-5   | baseline        |      8 |     0.875 |          0.2642 |            0.131  |            27.1 |            8.5 |          0 |             0    |        6.38 |        8    |        0 |
| claude-opus-5-5   | baseline-review |      8 |     0.875 |          0.6108 |            0.3438 |            48.3 |           14   |          0 |             0    |        8.62 |        9.12 |        0 |
| claude-opus-5-5   | enforced        |      8 |     0.875 |          0.3528 |            0.3056 |            89.4 |           11.5 |          1 |             3.25 |        4.62 |        6.12 |        0 |
| claude-sonnet-5-5 | baseline        |      8 |     0.75  |          0.0584 |            0.0463 |            14.4 |            4.5 |          0 |             0    |        2.5  |        3.62 |        0 |
| claude-sonnet-5-5 | baseline-review |      8 |     0.75  |          0.1641 |            0.1206 |            24.2 |            8.5 |          0 |             0    |        4.88 |        6.38 |        0 |
| claude-sonnet-5-5 | enforced        |      8 |     0.75  |          0.1111 |            0.0966 |            51.4 |            8   |          1 |             2.88 |        2.62 |        3.25 |        0 |

## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; for cost, better = cheaper)

| stratum   | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| all       | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| all       | cost ratio   | baseline-review / baseline |      2.595 |         |         |        0 |      0 |      24 |       8 |      24 |
| all       | success (pp) | enforced - baseline        |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| all       | cost ratio   | enforced / baseline        |      2.013 |         |         |        2 |      0 |      22 |       8 |      24 |
| all       | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| all       | cost ratio   | enforced / baseline-review |      0.776 |         |         |       18 |      0 |       6 |       8 |      24 |

## The same contrasts by stratum

### By model

| stratum                 | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| model=claude-haiku-5-5  | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-haiku-5-5  | cost ratio   | baseline-review / baseline |      2.506 |         |         |        0 |      0 |       8 |       8 |       8 |
| model=claude-haiku-5-5  | success (pp) | enforced - baseline        |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-haiku-5-5  | cost ratio   | enforced / baseline        |      2.084 |         |         |        1 |      0 |       7 |       8 |       8 |
| model=claude-haiku-5-5  | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-haiku-5-5  | cost ratio   | enforced / baseline-review |      0.831 |         |         |        5 |      0 |       3 |       8 |       8 |
| model=claude-opus-5-5   | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-opus-5-5   | cost ratio   | baseline-review / baseline |      2.522 |         |         |        0 |      0 |       8 |       8 |       8 |
| model=claude-opus-5-5   | success (pp) | enforced - baseline        |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-opus-5-5   | cost ratio   | enforced / baseline        |      1.888 |         |         |        1 |      0 |       7 |       8 |       8 |
| model=claude-opus-5-5   | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-opus-5-5   | cost ratio   | enforced / baseline-review |      0.748 |         |         |        6 |      0 |       2 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-sonnet-5-5 | cost ratio   | baseline-review / baseline |      2.763 |         |         |        0 |      0 |       8 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp) | enforced - baseline        |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-sonnet-5-5 | cost ratio   | enforced / baseline        |      2.075 |         |         |        0 |      0 |       8 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-sonnet-5-5 | cost ratio   | enforced / baseline-review |      0.751 |         |         |        7 |      0 |       1 |       8 |       8 |


### By lang

| stratum         | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| lang=python     | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=python     | cost ratio   | baseline-review / baseline |      2.542 |         |         |        0 |      0 |      12 |       4 |      12 |
| lang=python     | success (pp) | enforced - baseline        |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=python     | cost ratio   | enforced / baseline        |      1.585 |         |         |        2 |      0 |      10 |       4 |      12 |
| lang=python     | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=python     | cost ratio   | enforced / baseline-review |      0.623 |         |         |       10 |      0 |       2 |       4 |      12 |
| lang=typescript | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=typescript | cost ratio   | baseline-review / baseline |      2.649 |         |         |        0 |      0 |      12 |       4 |      12 |
| lang=typescript | success (pp) | enforced - baseline        |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=typescript | cost ratio   | enforced / baseline        |      2.558 |         |         |        0 |      0 |      12 |       4 |      12 |
| lang=typescript | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| lang=typescript | cost ratio   | enforced / baseline-review |      0.966 |         |         |        8 |      0 |       4 |       4 |      12 |


### By size

| stratum     | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| size=large  | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| size=large  | cost ratio   | baseline-review / baseline |      2.632 |         |         |        0 |      0 |      12 |       4 |      12 |
| size=large  | success (pp) | enforced - baseline        |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| size=large  | cost ratio   | enforced / baseline        |      1.947 |         |         |        2 |      0 |      10 |       4 |      12 |
| size=large  | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| size=large  | cost ratio   | enforced / baseline-review |      0.74  |         |         |       10 |      0 |       2 |       4 |      12 |
| size=medium | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=medium | cost ratio   | baseline-review / baseline |      2.685 |         |         |        0 |      0 |       6 |       2 |       6 |
| size=medium | success (pp) | enforced - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=medium | cost ratio   | enforced / baseline        |      2.657 |         |         |        0 |      0 |       6 |       2 |       6 |
| size=medium | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=medium | cost ratio   | enforced / baseline-review |      0.989 |         |         |        3 |      0 |       3 |       2 |       6 |
| size=small  | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=small  | cost ratio   | baseline-review / baseline |      2.436 |         |         |        0 |      0 |       6 |       2 |       6 |
| size=small  | success (pp) | enforced - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=small  | cost ratio   | enforced / baseline        |      1.632 |         |         |        0 |      0 |       6 |       2 |       6 |
| size=small  | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| size=small  | cost ratio   | enforced / baseline-review |      0.67  |         |         |        5 |      0 |       1 |       2 |       6 |


### By task_type

| stratum          | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:-----------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| task_type=move   | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=move   | cost ratio   | baseline-review / baseline |      2.37  |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=move   | success (pp) | enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=move   | cost ratio   | enforced / baseline        |      2.126 |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=move   | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=move   | cost ratio   | enforced / baseline-review |      0.897 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=pr     | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| task_type=pr     | cost ratio   | baseline-review / baseline |      2.591 |         |         |        0 |      0 |      12 |       4 |      12 |
| task_type=pr     | success (pp) | enforced - baseline        |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| task_type=pr     | cost ratio   | enforced / baseline        |      1.518 |         |         |        2 |      0 |      10 |       4 |      12 |
| task_type=pr     | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     12 |       0 |       4 |      12 |
| task_type=pr     | cost ratio   | enforced / baseline-review |      0.586 |         |         |       11 |      0 |       1 |       4 |      12 |
| task_type=rename | success (pp) | baseline-review - baseline |      0     |         |         |        0 |      9 |       0 |       3 |       9 |
| task_type=rename | cost ratio   | baseline-review / baseline |      2.68  |         |         |        0 |      0 |       9 |       3 |       9 |
| task_type=rename | success (pp) | enforced - baseline        |      0     |         |         |        0 |      9 |       0 |       3 |       9 |
| task_type=rename | cost ratio   | enforced / baseline        |      2.882 |         |         |        0 |      0 |       9 |       3 |       9 |
| task_type=rename | success (pp) | enforced - baseline-review |      0     |         |         |        0 |      9 |       0 |       3 |       9 |
| task_type=rename | cost ratio   | enforced / baseline-review |      1.075 |         |         |        4 |      0 |       5 |       3 |       9 |


### By probe_half

| stratum                                   | outcome      | contrast                   |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------------------------------------|:-------------|:---------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| probe_half=probe score at or below median | success (pp) | baseline-review - baseline |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| probe_half=probe score at or below median | cost ratio   | baseline-review / baseline |      2.595 |         |         |        0 |      0 |      24 |       8 |      24 |
| probe_half=probe score at or below median | success (pp) | enforced - baseline        |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| probe_half=probe score at or below median | cost ratio   | enforced / baseline        |      2.013 |         |         |        2 |      0 |      22 |       8 |      24 |
| probe_half=probe score at or below median | success (pp) | enforced - baseline-review |      0     |         |         |        0 |     24 |       0 |       8 |      24 |
| probe_half=probe score at or below median | cost ratio   | enforced / baseline-review |      0.776 |         |         |       18 |      0 |       6 |       8 |      24 |


## LSP operations used (all arms)

|                               |   calls |
|:------------------------------|--------:|
| lsp_diagnostics:              |      49 |
| lsp_navigate:references       |       9 |
| lsp_rename:apply              |       7 |
| lsp_rename:                   |       6 |
| lsp_navigate:symbols          |       4 |
| lsp_navigate:symbolBody       |       4 |
| lsp_rename:preview            |       3 |
| lsp_navigate:workspaceSymbols |       2 |
| lsp_status:servers            |       2 |
| lsp_navigate:definition       |       1 |
