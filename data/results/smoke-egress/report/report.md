# Report: smoke-egress

Runs finished: 3; excluded (contamination or never reached the model): 0; analysed: 3; tasks: 1; total cost: $0.03.

## Descriptive, by model and arm

| model            | arm             |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:-----------------|:----------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5 | baseline        |      1 |         0 |          0.0056 |            0.0056 |            22.9 |              4 |          0 |                0 |           2 |           3 |        0 |
| claude-haiku-5-5 | baseline-review |      1 |         0 |          0.0135 |            0.0135 |            31.4 |              7 |          0 |                0 |           3 |           5 |        0 |
| claude-haiku-5-5 | enforced        |      1 |         1 |          0.0083 |            0.0083 |            32.1 |              6 |          1 |                3 |           0 |           0 |        0 |

## Primary contrasts (task-clustered bootstrap 95% CI; paired sign-flip p; Holm over all primary contrasts)

| stratum   | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:----------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| all       | success (pp) | enforced - baseline |    100     | 100     | 100     |   1 |       1 |       1 |       1 |
| all       | cost ratio   | enforced / baseline |      1.478 |   1.478 |   1.478 |   1 |       1 |       1 |       1 |

## Mixed models

Mixed models not fitted: ValueError('operands could not be broadcast together with shapes (2,) (3,) (2,) ')

## Secondary contrasts (exploratory)

### By model (Benjamini-Hochberg within this family)

| stratum                | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:-----------------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| model=claude-haiku-5-5 | success (pp) | enforced - baseline |    100     | 100     | 100     |   1 |       1 |       1 |       1 |
| model=claude-haiku-5-5 | cost ratio   | enforced / baseline |      1.478 |   1.478 |   1.478 |   1 |       1 |       1 |       1 |


### By lang (Benjamini-Hochberg within this family)

| stratum     | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| lang=python | success (pp) | enforced - baseline |    100     | 100     | 100     |   1 |       1 |       1 |       1 |
| lang=python | cost ratio   | enforced / baseline |      1.478 |   1.478 |   1.478 |   1 |       1 |       1 |       1 |


### By size (Benjamini-Hochberg within this family)

| stratum    | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:-----------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| size=small | success (pp) | enforced - baseline |    100     | 100     | 100     |   1 |       1 |       1 |       1 |
| size=small | cost ratio   | enforced / baseline |      1.478 |   1.478 |   1.478 |   1 |       1 |       1 |       1 |


### By task_type (Benjamini-Hochberg within this family)

| stratum        | outcome      | contrast            |   estimate |   ci_lo |   ci_hi |   p |   tasks |   cells |   p_adj |
|:---------------|:-------------|:--------------------|-----------:|--------:|--------:|----:|--------:|--------:|--------:|
| task_type=refs | success (pp) | enforced - baseline |    100     | 100     | 100     |   1 |       1 |       1 |       1 |
| task_type=refs | cost ratio   | enforced / baseline |      1.478 |   1.478 |   1.478 |   1 |       1 |       1 |       1 |


## LSP operations used (all arms)

|                         |   calls |
|:------------------------|--------:|
| lsp_navigate:references |       3 |
