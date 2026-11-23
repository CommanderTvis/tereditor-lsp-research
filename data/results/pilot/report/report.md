# Report: pilot

Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. Strata under 10 tasks show counts only.

Runs finished: 96; excluded (contamination or never reached the model): 0; analysed: 96; tasks: 12; total cost: $4.56.

## By model and arm

| model             | arm               |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |   mean_flaws |
|:------------------|:------------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|-------------:|
| claude-haiku-5-5  | baseline          |     12 |     0.833 |          0.0071 |            0.0069 |            26.2 |            7   |      0     |             0    |        3.17 |        4.83 |        0 |         1.12 |
| claude-haiku-5-5  | baseline-review   |     12 |     0.833 |          0.016  |            0.0144 |            39.2 |           10.5 |      0     |             0    |        5.17 |        6.33 |        0 |         0.25 |
| claude-haiku-5-5  | enforced          |      9 |     0.889 |          0.0115 |            0.0087 |            40.5 |           11   |      1     |             3.44 |        1.78 |        5    |        0 |         0.33 |
| claude-haiku-5-5  | intellij-enforced |      3 |     0.667 |          0.0131 |            0.0145 |           184.6 |           18   |      1     |            12    |        1.33 |        2.67 |        0 |         0    |
| claude-haiku-5-5  | intellij-optional |      3 |     0.667 |          0.0054 |            0.0052 |            28.5 |            6   |      0     |             0    |        3    |        2.67 |        0 |         0    |
| claude-haiku-5-5  | optional          |      9 |     0.778 |          0.0069 |            0.0071 |            27.6 |            7   |      0     |             0    |        2.89 |        5.11 |        0 |         0.5  |
| claude-sonnet-5-5 | baseline          |     12 |     0.917 |          0.0532 |            0.046  |            16.6 |            5   |      0     |             0    |        2.58 |        2.5  |        0 |         0.62 |
| claude-sonnet-5-5 | baseline-review   |     12 |     0.833 |          0.1276 |            0.1201 |            23.8 |            8   |      0     |             0    |        4    |        5.42 |        0 |         0.38 |
| claude-sonnet-5-5 | enforced          |      9 |     0.889 |          0.0886 |            0.0775 |            22.8 |            6   |      0.889 |             1.56 |        2    |        2.89 |        0 |         0.33 |
| claude-sonnet-5-5 | intellij-enforced |      3 |     0.667 |          0.1252 |            0.1072 |           123.9 |           14   |      1     |             6.67 |        3    |        3    |        0 |         0.5  |
| claude-sonnet-5-5 | intellij-optional |      3 |     0.667 |          0.0497 |            0.0489 |            20   |            5   |      0     |             0    |        2    |        3.33 |        0 |         0.5  |
| claude-sonnet-5-5 | optional          |      9 |     0.889 |          0.063  |            0.0432 |            13.7 |            4   |      0     |             0    |        2.78 |        3.11 |        0 |         0.5  |

## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; for cost, better = cheaper)

| stratum   | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:----------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| all       | success (pp)      | baseline-review - baseline          |     -4.167 | -12.5   |    0    |        1 |     21 |       2 |      12 |      24 |
| all       | cost ratio        | baseline-review / baseline          |      2.48  |   2.247 |    2.77 |        0 |      0 |      24 |      12 |      24 |
| all       | flaws (mean diff) | baseline-review - baseline          |     -0.562 |         |         |        5 |     10 |       1 |       8 |      16 |
| all       | success (pp)      | optional - baseline                 |     -5.556 |         |         |        0 |     17 |       1 |       9 |      18 |
| all       | cost ratio        | optional / baseline                 |      1.082 |         |         |        8 |      0 |      10 |       9 |      18 |
| all       | flaws (mean diff) | optional - baseline                 |     -0.583 |         |         |        4 |      7 |       1 |       6 |      12 |
| all       | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |     18 |       0 |       9 |      18 |
| all       | cost ratio        | enforced / baseline                 |      1.731 |         |         |        1 |      0 |      17 |       9 |      18 |
| all       | flaws (mean diff) | enforced - baseline                 |     -0.75  |         |         |        5 |      6 |       1 |       6 |      12 |
| all       | success (pp)      | intellij-optional - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| all       | cost ratio        | intellij-optional / baseline        |      0.902 |         |         |        3 |      0 |       3 |       3 |       6 |
| all       | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| all       | success (pp)      | intellij-enforced - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| all       | cost ratio        | intellij-enforced / baseline        |      2.325 |         |         |        0 |      0 |       6 |       3 |       6 |
| all       | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| all       | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     18 |       0 |       9 |      18 |
| all       | cost ratio        | optional / baseline-review          |      0.443 |         |         |       17 |      0 |       1 |       9 |      18 |
| all       | flaws (mean diff) | optional - baseline-review          |      0.083 |         |         |        0 |     11 |       1 |       6 |      12 |
| all       | success (pp)      | enforced - baseline-review          |      5.556 |         |         |        1 |     17 |       0 |       9 |      18 |
| all       | cost ratio        | enforced / baseline-review          |      0.709 |         |         |       15 |      0 |       3 |       9 |      18 |
| all       | flaws (mean diff) | enforced - baseline-review          |     -0.083 |         |         |        2 |      9 |       1 |       6 |      12 |
| all       | success (pp)      | intellij-optional - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| all       | cost ratio        | intellij-optional / baseline-review |      0.347 |         |         |        6 |      0 |       0 |       3 |       6 |
| all       | flaws (mean diff) | intellij-optional - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| all       | success (pp)      | intellij-enforced - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| all       | cost ratio        | intellij-enforced / baseline-review |      0.894 |         |         |        4 |      0 |       2 |       3 |       6 |
| all       | flaws (mean diff) | intellij-enforced - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |

## The same contrasts by stratum

### By model

| stratum                 | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:------------------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| model=claude-haiku-5-5  | success (pp)      | baseline-review - baseline          |      0     | -25     |  25     |        1 |     10 |       1 |      12 |      12 |
| model=claude-haiku-5-5  | cost ratio        | baseline-review / baseline          |      2.52  |   2.159 |   2.999 |        0 |      0 |      12 |      12 |      12 |
| model=claude-haiku-5-5  | flaws (mean diff) | baseline-review - baseline          |     -0.875 |         |         |        3 |      5 |       0 |       8 |       8 |
| model=claude-haiku-5-5  | success (pp)      | optional - baseline                 |    -11.1   |         |         |        0 |      8 |       1 |       9 |       9 |
| model=claude-haiku-5-5  | cost ratio        | optional / baseline                 |      1.004 |         |         |        6 |      0 |       3 |       9 |       9 |
| model=claude-haiku-5-5  | flaws (mean diff) | optional - baseline                 |     -1     |         |         |        3 |      3 |       0 |       6 |       6 |
| model=claude-haiku-5-5  | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-haiku-5-5  | cost ratio        | enforced / baseline                 |      1.709 |         |         |        0 |      0 |       9 |       9 |       9 |
| model=claude-haiku-5-5  | flaws (mean diff) | enforced - baseline                 |     -1.167 |         |         |        4 |      2 |       0 |       6 |       6 |
| model=claude-haiku-5-5  | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-haiku-5-5  | cost ratio        | intellij-optional / baseline        |      0.816 |         |         |        2 |      0 |       1 |       3 |       3 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-haiku-5-5  | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-haiku-5-5  | cost ratio        | intellij-enforced / baseline        |      2.052 |         |         |        0 |      0 |       3 |       3 |       3 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-haiku-5-5  | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-haiku-5-5  | cost ratio        | optional / baseline-review          |      0.383 |         |         |        9 |      0 |       0 |       9 |       9 |
| model=claude-haiku-5-5  | flaws (mean diff) | optional - baseline-review          |      0.167 |         |         |        0 |      5 |       1 |       6 |       6 |
| model=claude-haiku-5-5  | success (pp)      | enforced - baseline-review          |     11.1   |         |         |        1 |      8 |       0 |       9 |       9 |
| model=claude-haiku-5-5  | cost ratio        | enforced / baseline-review          |      0.652 |         |         |        9 |      0 |       0 |       9 |       9 |
| model=claude-haiku-5-5  | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        1 |      4 |       1 |       6 |       6 |
| model=claude-haiku-5-5  | success (pp)      | intellij-optional - baseline-review |    -33.3   |         |         |        0 |      2 |       1 |       3 |       3 |
| model=claude-haiku-5-5  | cost ratio        | intellij-optional / baseline-review |      0.364 |         |         |        3 |      0 |       0 |       3 |       3 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-haiku-5-5  | success (pp)      | intellij-enforced - baseline-review |    -33.3   |         |         |        0 |      2 |       1 |       3 |       3 |
| model=claude-haiku-5-5  | cost ratio        | intellij-enforced / baseline-review |      0.915 |         |         |        2 |      0 |       1 |       3 |       3 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-enforced - baseline-review |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-sonnet-5-5 | success (pp)      | baseline-review - baseline          |     -8.333 | -25     |   0     |        0 |     11 |       1 |      12 |      12 |
| model=claude-sonnet-5-5 | cost ratio        | baseline-review / baseline          |      2.44  |   2.044 |   2.907 |        0 |      0 |      12 |      12 |      12 |
| model=claude-sonnet-5-5 | flaws (mean diff) | baseline-review - baseline          |     -0.25  |         |         |        2 |      5 |       1 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-sonnet-5-5 | cost ratio        | optional / baseline                 |      1.167 |         |         |        2 |      0 |       7 |       9 |       9 |
| model=claude-sonnet-5-5 | flaws (mean diff) | optional - baseline                 |     -0.167 |         |         |        1 |      4 |       1 |       6 |       6 |
| model=claude-sonnet-5-5 | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-sonnet-5-5 | cost ratio        | enforced / baseline                 |      1.753 |         |         |        1 |      0 |       8 |       9 |       9 |
| model=claude-sonnet-5-5 | flaws (mean diff) | enforced - baseline                 |     -0.333 |         |         |        1 |      4 |       1 |       6 |       6 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-optional - baseline        |    -33.3   |         |         |        0 |      2 |       1 |       3 |       3 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-optional / baseline        |      0.996 |         |         |        1 |      0 |       2 |       3 |       3 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-enforced - baseline        |    -33.3   |         |         |        0 |      2 |       1 |       3 |       3 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-enforced / baseline        |      2.634 |         |         |        0 |      0 |       3 |       3 |       3 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       2 |       2 |
| model=claude-sonnet-5-5 | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-sonnet-5-5 | cost ratio        | optional / baseline-review          |      0.513 |         |         |        8 |      0 |       1 |       9 |       9 |
| model=claude-sonnet-5-5 | flaws (mean diff) | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       6 |       6 |
| model=claude-sonnet-5-5 | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      9 |       0 |       9 |       9 |
| model=claude-sonnet-5-5 | cost ratio        | enforced / baseline-review          |      0.771 |         |         |        6 |      0 |       3 |       9 |       9 |
| model=claude-sonnet-5-5 | flaws (mean diff) | enforced - baseline-review          |     -0.167 |         |         |        1 |      5 |       0 |       6 |       6 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-optional / baseline-review |      0.33  |         |         |        3 |      0 |       0 |       3 |       3 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       3 |       3 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-enforced / baseline-review |      0.873 |         |         |        2 |      0 |       1 |       3 |       3 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       2 |       2 |


### By lang

| stratum         | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:----------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| lang=csharp     | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=csharp     | cost ratio        | baseline-review / baseline          |      2.305 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=csharp     | flaws (mean diff) | baseline-review - baseline          |     -1.5   |         |         |        3 |      1 |       0 |       2 |       4 |
| lang=csharp     | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=csharp     | cost ratio        | optional / baseline                 |      0.953 |         |         |        4 |      0 |       2 |       3 |       6 |
| lang=csharp     | flaws (mean diff) | optional - baseline                 |     -1.25  |         |         |        3 |      1 |       0 |       2 |       4 |
| lang=csharp     | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=csharp     | cost ratio        | enforced / baseline                 |      1.247 |         |         |        1 |      0 |       5 |       3 |       6 |
| lang=csharp     | flaws (mean diff) | enforced - baseline                 |     -1.5   |         |         |        3 |      1 |       0 |       2 |       4 |
| lang=csharp     | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=csharp     | cost ratio        | optional / baseline-review          |      0.413 |         |         |        6 |      0 |       0 |       3 |       6 |
| lang=csharp     | flaws (mean diff) | optional - baseline-review          |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| lang=csharp     | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=csharp     | cost ratio        | enforced / baseline-review          |      0.541 |         |         |        6 |      0 |       0 |       3 |       6 |
| lang=csharp     | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        1 |      2 |       1 |       2 |       4 |
| lang=java       | success (pp)      | baseline-review - baseline          |      0     |         |         |        1 |      4 |       1 |       3 |       6 |
| lang=java       | cost ratio        | baseline-review / baseline          |      2.601 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=java       | flaws (mean diff) | baseline-review - baseline          |     -0.25  |         |         |        1 |      3 |       0 |       2 |       4 |
| lang=java       | success (pp)      | intellij-optional - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=java       | cost ratio        | intellij-optional / baseline        |      0.902 |         |         |        3 |      0 |       3 |       3 |       6 |
| lang=java       | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=java       | success (pp)      | intellij-enforced - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=java       | cost ratio        | intellij-enforced / baseline        |      2.325 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=java       | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=java       | success (pp)      | intellij-optional - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=java       | cost ratio        | intellij-optional / baseline-review |      0.347 |         |         |        6 |      0 |       0 |       3 |       6 |
| lang=java       | flaws (mean diff) | intellij-optional - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| lang=java       | success (pp)      | intellij-enforced - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=java       | cost ratio        | intellij-enforced / baseline-review |      0.894 |         |         |        4 |      0 |       2 |       3 |       6 |
| lang=java       | flaws (mean diff) | intellij-enforced - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| lang=python     | success (pp)      | baseline-review - baseline          |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=python     | cost ratio        | baseline-review / baseline          |      2.689 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=python     | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=python     | success (pp)      | optional - baseline                 |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| lang=python     | cost ratio        | optional / baseline                 |      1.131 |         |         |        2 |      0 |       4 |       3 |       6 |
| lang=python     | flaws (mean diff) | optional - baseline                 |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=python     | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=python     | cost ratio        | enforced / baseline                 |      2.169 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=python     | flaws (mean diff) | enforced - baseline                 |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=python     | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=python     | cost ratio        | optional / baseline-review          |      0.421 |         |         |        5 |      0 |       1 |       3 |       6 |
| lang=python     | flaws (mean diff) | optional - baseline-review          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=python     | success (pp)      | enforced - baseline-review          |     16.7   |         |         |        1 |      5 |       0 |       3 |       6 |
| lang=python     | cost ratio        | enforced / baseline-review          |      0.807 |         |         |        4 |      0 |       2 |       3 |       6 |
| lang=python     | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=typescript | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=typescript | cost ratio        | baseline-review / baseline          |      2.346 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=typescript | flaws (mean diff) | baseline-review - baseline          |     -0.5   |         |         |        1 |      2 |       1 |       2 |       4 |
| lang=typescript | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=typescript | cost ratio        | optional / baseline                 |      1.176 |         |         |        2 |      0 |       4 |       3 |       6 |
| lang=typescript | flaws (mean diff) | optional - baseline                 |     -0.5   |         |         |        1 |      2 |       1 |       2 |       4 |
| lang=typescript | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=typescript | cost ratio        | enforced / baseline                 |      1.917 |         |         |        0 |      0 |       6 |       3 |       6 |
| lang=typescript | flaws (mean diff) | enforced - baseline                 |     -0.75  |         |         |        2 |      1 |       1 |       2 |       4 |
| lang=typescript | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=typescript | cost ratio        | optional / baseline-review          |      0.501 |         |         |        6 |      0 |       0 |       3 |       6 |
| lang=typescript | flaws (mean diff) | optional - baseline-review          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| lang=typescript | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| lang=typescript | cost ratio        | enforced / baseline-review          |      0.817 |         |         |        5 |      0 |       1 |       3 |       6 |
| lang=typescript | flaws (mean diff) | enforced - baseline-review          |     -0.25  |         |         |        1 |      3 |       0 |       2 |       4 |


### By size

| stratum     | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| size=medium | success (pp)      | baseline-review - baseline          |      0     |         |         |        1 |     10 |       1 |       6 |      12 |
| size=medium | cost ratio        | baseline-review / baseline          |      2.47  |         |         |        0 |      0 |      12 |       6 |      12 |
| size=medium | flaws (mean diff) | baseline-review - baseline          |     -0.375 |         |         |        2 |      5 |       1 |       4 |       8 |
| size=medium | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| size=medium | cost ratio        | optional / baseline                 |      1.176 |         |         |        2 |      0 |       4 |       3 |       6 |
| size=medium | flaws (mean diff) | optional - baseline                 |     -0.5   |         |         |        1 |      2 |       1 |       2 |       4 |
| size=medium | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| size=medium | cost ratio        | enforced / baseline                 |      1.917 |         |         |        0 |      0 |       6 |       3 |       6 |
| size=medium | flaws (mean diff) | enforced - baseline                 |     -0.75  |         |         |        2 |      1 |       1 |       2 |       4 |
| size=medium | success (pp)      | intellij-optional - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| size=medium | cost ratio        | intellij-optional / baseline        |      0.902 |         |         |        3 |      0 |       3 |       3 |       6 |
| size=medium | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| size=medium | success (pp)      | intellij-enforced - baseline        |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| size=medium | cost ratio        | intellij-enforced / baseline        |      2.325 |         |         |        0 |      0 |       6 |       3 |       6 |
| size=medium | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| size=medium | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| size=medium | cost ratio        | optional / baseline-review          |      0.501 |         |         |        6 |      0 |       0 |       3 |       6 |
| size=medium | flaws (mean diff) | optional - baseline-review          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| size=medium | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| size=medium | cost ratio        | enforced / baseline-review          |      0.817 |         |         |        5 |      0 |       1 |       3 |       6 |
| size=medium | flaws (mean diff) | enforced - baseline-review          |     -0.25  |         |         |        1 |      3 |       0 |       2 |       4 |
| size=medium | success (pp)      | intellij-optional - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| size=medium | cost ratio        | intellij-optional / baseline-review |      0.347 |         |         |        6 |      0 |       0 |       3 |       6 |
| size=medium | flaws (mean diff) | intellij-optional - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| size=medium | success (pp)      | intellij-enforced - baseline-review |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| size=medium | cost ratio        | intellij-enforced / baseline-review |      0.894 |         |         |        4 |      0 |       2 |       3 |       6 |
| size=medium | flaws (mean diff) | intellij-enforced - baseline-review |      0.25  |         |         |        0 |      3 |       1 |       2 |       4 |
| size=small  | success (pp)      | baseline-review - baseline          |     -8.333 |         |         |        0 |     11 |       1 |       6 |      12 |
| size=small  | cost ratio        | baseline-review / baseline          |      2.49  |         |         |        0 |      0 |      12 |       6 |      12 |
| size=small  | flaws (mean diff) | baseline-review - baseline          |     -0.75  |         |         |        3 |      5 |       0 |       4 |       8 |
| size=small  | success (pp)      | optional - baseline                 |     -8.333 |         |         |        0 |     11 |       1 |       6 |      12 |
| size=small  | cost ratio        | optional / baseline                 |      1.038 |         |         |        6 |      0 |       6 |       6 |      12 |
| size=small  | flaws (mean diff) | optional - baseline                 |     -0.625 |         |         |        3 |      5 |       0 |       4 |       8 |
| size=small  | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |     12 |       0 |       6 |      12 |
| size=small  | cost ratio        | enforced / baseline                 |      1.645 |         |         |        1 |      0 |      11 |       6 |      12 |
| size=small  | flaws (mean diff) | enforced - baseline                 |     -0.75  |         |         |        3 |      5 |       0 |       4 |       8 |
| size=small  | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     12 |       0 |       6 |      12 |
| size=small  | cost ratio        | optional / baseline-review          |      0.417 |         |         |       11 |      0 |       1 |       6 |      12 |
| size=small  | flaws (mean diff) | optional - baseline-review          |      0.125 |         |         |        0 |      7 |       1 |       4 |       8 |
| size=small  | success (pp)      | enforced - baseline-review          |      8.333 |         |         |        1 |     11 |       0 |       6 |      12 |
| size=small  | cost ratio        | enforced / baseline-review          |      0.661 |         |         |       10 |      0 |       2 |       6 |      12 |
| size=small  | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        1 |      6 |       1 |       4 |       8 |


### By task_type

| stratum           | outcome           | contrast                            |   estimate | ci_lo   | ci_hi   |   better |   same |   worse |   tasks |   cells |
|:------------------|:------------------|:------------------------------------|-----------:|:--------|:--------|---------:|-------:|--------:|--------:|--------:|
| task_type=impls   | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=impls   | cost ratio        | baseline-review / baseline          |      1.946 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=impls   | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=impls   | cost ratio        | optional / baseline                 |      1.001 |         |         |        1 |      0 |       1 |       1 |       2 |
| task_type=impls   | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=impls   | cost ratio        | enforced / baseline                 |      1.045 |         |         |        1 |      0 |       1 |       1 |       2 |
| task_type=impls   | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=impls   | cost ratio        | optional / baseline-review          |      0.514 |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=impls   | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=impls   | cost ratio        | enforced / baseline-review          |      0.537 |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=inspect | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| task_type=inspect | cost ratio        | baseline-review / baseline          |      2.235 |         |         |        0 |      0 |       4 |       2 |       4 |
| task_type=inspect | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | optional / baseline                 |      1.308 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=inspect | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | enforced / baseline                 |      1.795 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=inspect | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | intellij-optional / baseline        |      1.164 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=inspect | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | intellij-enforced / baseline        |      2.534 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=inspect | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | optional / baseline-review          |      0.61  |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=inspect | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | enforced / baseline-review          |      0.837 |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=inspect | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | intellij-optional / baseline-review |      0.5   |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=inspect | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=inspect | cost ratio        | intellij-enforced / baseline-review |      1.088 |         |         |        1 |      0 |       1 |       1 |       2 |
| task_type=pr      | success (pp)      | baseline-review - baseline          |    -12.5   |         |         |        1 |      5 |       2 |       4 |       8 |
| task_type=pr      | cost ratio        | baseline-review / baseline          |      2.249 |         |         |        0 |      0 |       8 |       4 |       8 |
| task_type=pr      | flaws (mean diff) | baseline-review - baseline          |     -1     |         |         |        3 |      5 |       0 |       4 |       8 |
| task_type=pr      | success (pp)      | optional - baseline                 |    -16.7   |         |         |        0 |      5 |       1 |       3 |       6 |
| task_type=pr      | cost ratio        | optional / baseline                 |      1.04  |         |         |        3 |      0 |       3 |       3 |       6 |
| task_type=pr      | flaws (mean diff) | optional - baseline                 |     -1.167 |         |         |        3 |      3 |       0 |       3 |       6 |
| task_type=pr      | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| task_type=pr      | cost ratio        | enforced / baseline                 |      1.626 |         |         |        0 |      0 |       6 |       3 |       6 |
| task_type=pr      | flaws (mean diff) | enforced - baseline                 |     -1.333 |         |         |        3 |      3 |       0 |       3 |       6 |
| task_type=pr      | success (pp)      | intellij-optional - baseline        |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| task_type=pr      | cost ratio        | intellij-optional / baseline        |      0.766 |         |         |        1 |      0 |       1 |       1 |       2 |
| task_type=pr      | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=pr      | success (pp)      | intellij-enforced - baseline        |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| task_type=pr      | cost ratio        | intellij-enforced / baseline        |      1.554 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=pr      | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=pr      | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      6 |       0 |       3 |       6 |
| task_type=pr      | cost ratio        | optional / baseline-review          |      0.446 |         |         |        6 |      0 |       0 |       3 |       6 |
| task_type=pr      | flaws (mean diff) | optional - baseline-review          |      0.167 |         |         |        0 |      5 |       1 |       3 |       6 |
| task_type=pr      | success (pp)      | enforced - baseline-review          |     16.7   |         |         |        1 |      5 |       0 |       3 |       6 |
| task_type=pr      | cost ratio        | enforced / baseline-review          |      0.698 |         |         |        6 |      0 |       0 |       3 |       6 |
| task_type=pr      | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        1 |      4 |       1 |       3 |       6 |
| task_type=pr      | success (pp)      | intellij-optional - baseline-review |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| task_type=pr      | cost ratio        | intellij-optional / baseline-review |      0.379 |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=pr      | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=pr      | success (pp)      | intellij-enforced - baseline-review |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| task_type=pr      | cost ratio        | intellij-enforced / baseline-review |      0.77  |         |         |        2 |      0 |       0 |       1 |       2 |
| task_type=pr      | flaws (mean diff) | intellij-enforced - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | cost ratio        | baseline-review / baseline          |      2.787 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=refs    | success (pp)      | optional - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | cost ratio        | optional / baseline                 |      1.59  |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=refs    | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | cost ratio        | enforced / baseline                 |      2.864 |         |         |        0 |      0 |       2 |       1 |       2 |
| task_type=refs    | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | cost ratio        | optional / baseline-review          |      0.571 |         |         |        1 |      0 |       1 |       1 |       2 |
| task_type=refs    | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| task_type=refs    | cost ratio        | enforced / baseline-review          |      1.028 |         |         |        1 |      0 |       1 |       1 |       2 |


### By probe_half

| stratum                                   | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:------------------------------------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| probe_half=probe score above median       | success (pp)      | baseline-review - baseline          |      0     |         |         |        1 |      0 |       1 |       1 |       2 |
| probe_half=probe score above median       | cost ratio        | baseline-review / baseline          |      2.019 |         |         |        0 |      0 |       2 |       1 |       2 |
| probe_half=probe score above median       | flaws (mean diff) | baseline-review - baseline          |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score above median       | success (pp)      | intellij-optional - baseline        |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| probe_half=probe score above median       | cost ratio        | intellij-optional / baseline        |      0.766 |         |         |        1 |      0 |       1 |       1 |       2 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score above median       | success (pp)      | intellij-enforced - baseline        |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| probe_half=probe score above median       | cost ratio        | intellij-enforced / baseline        |      1.554 |         |         |        0 |      0 |       2 |       1 |       2 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score above median       | success (pp)      | intellij-optional - baseline-review |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| probe_half=probe score above median       | cost ratio        | intellij-optional / baseline-review |      0.379 |         |         |        2 |      0 |       0 |       1 |       2 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score above median       | success (pp)      | intellij-enforced - baseline-review |    -50     |         |         |        0 |      1 |       1 |       1 |       2 |
| probe_half=probe score above median       | cost ratio        | intellij-enforced / baseline-review |      0.77  |         |         |        2 |      0 |       0 |       1 |       2 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-enforced - baseline-review |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score at or below median | success (pp)      | baseline-review - baseline          |     -4.545 | -13.6   |   0     |        0 |     21 |       1 |      11 |      22 |
| probe_half=probe score at or below median | cost ratio        | baseline-review / baseline          |      2.527 |   2.285 |   2.805 |        0 |      0 |      22 |      11 |      22 |
| probe_half=probe score at or below median | flaws (mean diff) | baseline-review - baseline          |     -0.643 |         |         |        5 |      8 |       1 |       7 |      14 |
| probe_half=probe score at or below median | success (pp)      | optional - baseline                 |     -5.556 |         |         |        0 |     17 |       1 |       9 |      18 |
| probe_half=probe score at or below median | cost ratio        | optional / baseline                 |      1.082 |         |         |        8 |      0 |      10 |       9 |      18 |
| probe_half=probe score at or below median | flaws (mean diff) | optional - baseline                 |     -0.583 |         |         |        4 |      7 |       1 |       6 |      12 |
| probe_half=probe score at or below median | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |     18 |       0 |       9 |      18 |
| probe_half=probe score at or below median | cost ratio        | enforced / baseline                 |      1.731 |         |         |        1 |      0 |      17 |       9 |      18 |
| probe_half=probe score at or below median | flaws (mean diff) | enforced - baseline                 |     -0.75  |         |         |        5 |      6 |       1 |       6 |      12 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline        |      0.978 |         |         |        2 |      0 |       2 |       2 |       4 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline        |      2.844 |         |         |        0 |      0 |       4 |       2 |       4 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      2 |       0 |       1 |       2 |
| probe_half=probe score at or below median | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     18 |       0 |       9 |      18 |
| probe_half=probe score at or below median | cost ratio        | optional / baseline-review          |      0.443 |         |         |       17 |      0 |       1 |       9 |      18 |
| probe_half=probe score at or below median | flaws (mean diff) | optional - baseline-review          |      0.083 |         |         |        0 |     11 |       1 |       6 |      12 |
| probe_half=probe score at or below median | success (pp)      | enforced - baseline-review          |      5.556 |         |         |        1 |     17 |       0 |       9 |      18 |
| probe_half=probe score at or below median | cost ratio        | enforced / baseline-review          |      0.709 |         |         |       15 |      0 |       3 |       9 |      18 |
| probe_half=probe score at or below median | flaws (mean diff) | enforced - baseline-review          |     -0.083 |         |         |        2 |      9 |       1 |       6 |      12 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline-review |      0.332 |         |         |        4 |      0 |       0 |       2 |       4 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       1 |       2 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      4 |       0 |       2 |       4 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline-review |      0.963 |         |         |        2 |      0 |       2 |       2 |       4 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline-review |      0.5   |         |         |        0 |      1 |       1 |       1 |       2 |


## LSP adoption in the optional arm (observational)

| model             |   runs |   lsp_used |   success_when_used |   success_when_not |
|:------------------|-------:|-----------:|--------------------:|-------------------:|
| claude-haiku-5-5  |      9 |          0 |                 nan |              0.778 |
| claude-sonnet-5-5 |      9 |          0 |                 nan |              0.889 |

## LSP operations used (all arms)

|                               |   calls |
|:------------------------------|--------:|
| lsp_navigate:references       |      43 |
| lsp_diagnostics:              |      25 |
| lsp_navigate:symbolBody       |      10 |
| lsp_navigate:symbols          |       8 |
| lsp_navigate:workspaceSymbols |       4 |
| lsp_rename:preview            |       4 |
| lsp_navigate:implementation   |       3 |
| lsp_rename:apply              |       2 |
| lsp_rename:                   |       1 |
| lsp_status:                   |       1 |
