# Report: smoke-nix

Runs finished: 3; excluded (contamination or never reached the model): 0; analysed: 3; tasks: 1; total cost: $0.03.

## Descriptive, by model and arm

| model            | arm      |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:-----------------|:---------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5 | baseline |      1 |         1 |          0.0067 |            0.0067 |            24.7 |              5 |          0 |                0 |           3 |           3 |        0 |
| claude-haiku-5-5 | enforced |      1 |         1 |          0.0123 |            0.0123 |            43.7 |             11 |          1 |                5 |           0 |           3 |        0 |
| claude-haiku-5-5 | optional |      1 |         1 |          0.0064 |            0.0064 |            24.6 |              5 |          0 |                0 |           2 |           3 |        0 |

## Primary contrasts (task-clustered bootstrap 95% CI; paired sign-flip p; Holm over all primary contrasts)

| stratum   | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:----------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| all       | success (pp) | optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| all       | cost ratio   | optional / baseline |      0.959 |   0.959 |   0.959 |   1 |       1 |       1 |       1 |
| all       | success (pp) | enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| all       | cost ratio   | enforced / baseline |      1.832 |   1.832 |   1.832 |   1 |       1 |       1 |       1 |
| all       | success (pp) | enforced - optional |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| all       | cost ratio   | enforced / optional |      1.91  |   1.91  |   1.91  |   1 |       1 |       1 |       1 |

## Mixed models

Mixed models not fitted: ValueError('endog values must be 0 and 1, and not all identical')

## Secondary contrasts (exploratory)

### By model (Benjamini-Hochberg within this family)

| stratum                | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:-----------------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| model=claude-haiku-5-5 | success (pp) | optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | optional / baseline |      0.959 |   0.959 |   0.959 |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | enforced / baseline |      1.832 |   1.832 |   1.832 |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | success (pp) | enforced - optional |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | enforced / optional |      1.91  |   1.91  |   1.91  |   1 |       1 |       1 |       1 |


### By lang (Benjamini-Hochberg within this family)

| stratum     | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| lang=python | success (pp) | optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| lang=python | cost ratio   | optional / baseline |      0.959 |   0.959 |   0.959 |   1 |       1 |       1 |       1 |
| lang=python | success (pp) | enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| lang=python | cost ratio   | enforced / baseline |      1.832 |   1.832 |   1.832 |   1 |       1 |       1 |       1 |
| lang=python | success (pp) | enforced - optional |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| lang=python | cost ratio   | enforced / optional |      1.91  |   1.91  |   1.91  |   1 |       1 |       1 |       1 |


### By size (Benjamini-Hochberg within this family)

| stratum    | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:-----------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| size=small | success (pp) | optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| size=small | cost ratio   | optional / baseline |      0.959 |   0.959 |   0.959 |   1 |       1 |       1 |       1 |
| size=small | success (pp) | enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| size=small | cost ratio   | enforced / baseline |      1.832 |   1.832 |   1.832 |   1 |       1 |       1 |       1 |
| size=small | success (pp) | enforced - optional |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| size=small | cost ratio   | enforced / optional |      1.91  |   1.91  |   1.91  |   1 |       1 |       1 |       1 |


### By task_type (Benjamini-Hochberg within this family)

| stratum        | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:---------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| task_type=refs | success (pp) | optional - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | optional / baseline |      0.959 |   0.959 |   0.959 |   1 |       1 |       1 |       1 |
| task_type=refs | success (pp) | enforced - baseline |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | enforced / baseline |      1.832 |   1.832 |   1.832 |   1 |       1 |       1 |       1 |
| task_type=refs | success (pp) | enforced - optional |      0     |   0     |   0     |   1 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | enforced / optional |      1.91  |   1.91  |   1.91  |   1 |       1 |       1 |       1 |


## LSP adoption in the optional arm (observational)

| model            |   runs |   lsp_used |   success_when_used |   success_when_not |
|:-----------------|-------:|-----------:|--------------------:|-------------------:|
| claude-haiku-5-5 |      1 |          0 |                 nan |                  1 |

## LSP operations used (all arms)

|                               |   calls |
|:------------------------------|--------:|
| lsp_navigate:references       |       3 |
| lsp_navigate:symbols          |       1 |
| lsp_navigate:workspaceSymbols |       1 |
