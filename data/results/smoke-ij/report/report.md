# Report: smoke-ij

Runs finished: 6; excluded (contamination or never reached the model): 0; analysed: 6; tasks: 2; total cost: $0.05.

## Descriptive, by model and arm

| model            | arm               |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:-----------------|:------------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5 | baseline          |      2 |         1 |          0.0064 |            0.0064 |            19.5 |            6   |          0 |                0 |         4   |         3.5 |        0 |
| claude-haiku-5-5 | intellij-enforced |      2 |         1 |          0.0127 |            0.0127 |            91.3 |           19.5 |          1 |                5 |         1   |         6   |        0 |
| claude-haiku-5-5 | intellij-optional |      2 |         1 |          0.007  |            0.007  |            21.4 |            5.5 |          0 |                0 |         3.5 |         3.5 |        0 |

## Primary contrasts (task-clustered bootstrap 95% CI; paired sign-flip p; Holm over all primary contrasts)

| stratum   | outcome      | contrast                     |   estimate |   ci_lo |   ci_hi |      p |   tasks |   cells |   p_adj |
|:----------|:-------------|:-----------------------------|-----------:|--------:|--------:|-------:|--------:|--------:|--------:|
| all       | success (pp) | intellij-optional - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| all       | cost ratio   | intellij-optional / baseline |      1.094 |   1.07  |   1.118 | 0.5    |       2 |       2 |       1 |
| all       | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| all       | cost ratio   | intellij-enforced / baseline |      2.027 |   1.184 |   3.469 | 0.4958 |       2 |       2 |       1 |

## Mixed models

Mixed models not fitted: ValueError('endog values must be 0 and 1, and not all identical')

## Secondary contrasts (exploratory)

### By model (Benjamini-Hochberg within this family)

| stratum                | outcome      | contrast                     |   estimate |   ci_lo |   ci_hi |      p |   tasks |   cells |   p_adj |
|:-----------------------|:-------------|:-----------------------------|-----------:|--------:|--------:|-------:|--------:|--------:|--------:|
| model=claude-haiku-5-5 | success (pp) | intellij-optional - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| model=claude-haiku-5-5 | cost ratio   | intellij-optional / baseline |      1.094 |   1.07  |   1.118 | 0.5015 |       2 |       2 |       1 |
| model=claude-haiku-5-5 | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| model=claude-haiku-5-5 | cost ratio   | intellij-enforced / baseline |      2.027 |   1.184 |   3.469 | 0.503  |       2 |       2 |       1 |


### By lang (Benjamini-Hochberg within this family)

| stratum   | outcome      | contrast                     |   estimate |   ci_lo |   ci_hi |      p |   tasks |   cells |   p_adj |
|:----------|:-------------|:-----------------------------|-----------:|--------:|--------:|-------:|--------:|--------:|--------:|
| lang=java | success (pp) | intellij-optional - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| lang=java | cost ratio   | intellij-optional / baseline |      1.094 |   1.07  |   1.118 | 0.4956 |       2 |       2 |       1 |
| lang=java | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| lang=java | cost ratio   | intellij-enforced / baseline |      2.027 |   1.184 |   3.469 | 0.5048 |       2 |       2 |       1 |


### By size (Benjamini-Hochberg within this family)

| stratum    | outcome      | contrast                     |   estimate |   ci_lo |   ci_hi |      p |   tasks |   cells |   p_adj |
|:-----------|:-------------|:-----------------------------|-----------:|--------:|--------:|-------:|--------:|--------:|--------:|
| size=smoke | success (pp) | intellij-optional - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| size=smoke | cost ratio   | intellij-optional / baseline |      1.094 |   1.07  |   1.118 | 0.5051 |       2 |       2 |       1 |
| size=smoke | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     | 1      |       2 |       2 |       1 |
| size=smoke | cost ratio   | intellij-enforced / baseline |      2.027 |   1.184 |   3.469 | 0.4944 |       2 |       2 |       1 |


### By task_type (Benjamini-Hochberg within this family)

| stratum          | outcome      | contrast                     |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:-----------------|:-------------|:-----------------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| task_type=refs   | success (pp) | intellij-optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=refs   | cost ratio   | intellij-optional / baseline |      1.07  |   1.07  |   1.07  |   1 |       1 |       1 |       1 |
| task_type=refs   | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=refs   | cost ratio   | intellij-enforced / baseline |      1.184 |   1.184 |   1.184 |   1 |       1 |       1 |       1 |
| task_type=rename | success (pp) | intellij-optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=rename | cost ratio   | intellij-optional / baseline |      1.118 |   1.118 |   1.118 |   1 |       1 |       1 |       1 |
| task_type=rename | success (pp) | intellij-enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=rename | cost ratio   | intellij-enforced / baseline |      3.469 |   3.469 |   3.469 |   1 |       1 |       1 |       1 |


## LSP operations used (all arms)

|                         |   calls |
|:------------------------|--------:|
| lsp_navigate:references |       3 |
| lsp_rename:apply        |       3 |
| lsp_rename:preview      |       2 |
| lsp_diagnostics:        |       1 |
| lsp_navigate:definition |       1 |
