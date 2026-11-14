# Report: rename-check

Runs finished: 1; excluded (contamination or never reached the model): 0; analysed: 1; tasks: 1; total cost: $0.01.

## Descriptive, by model and arm

| model            | arm      |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |
|:-----------------|:---------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|
| claude-haiku-5-5 | enforced |      1 |         1 |           0.008 |             0.008 |              33 |              6 |          1 |                3 |           0 |           1 |        0 |

## Primary contrasts (task-clustered bootstrap 95% CI; paired sign-flip p; Holm over all primary contrasts)

_no data_

## Mixed models

Mixed models not fitted: ValueError('endog values must be 0 and 1, and not all identical')

## Secondary contrasts (exploratory)

### By model (Benjamini-Hochberg within this family)

_no data_


### By lang (Benjamini-Hochberg within this family)

_no data_


### By size (Benjamini-Hochberg within this family)

_no data_


### By task_type (Benjamini-Hochberg within this family)

_no data_


## LSP operations used (all arms)

|                         |   calls |
|:------------------------|--------:|
| lsp_navigate:references |       2 |
| lsp_navigate:symbols    |       1 |
