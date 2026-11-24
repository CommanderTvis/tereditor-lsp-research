# Report: main

Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. Strata under 10 tasks show counts only.

Runs finished: 2232; excluded (contamination or never reached the model): 0; analysed: 2232; tasks: 87; total cost: $243.02.

## By model and arm

| model             | arm               |   runs |   success |   mean_cost_usd |   median_cost_usd |   median_wall_s |   median_turns |   lsp_used |   mean_lsp_calls |   mean_grep |   mean_read |   capped |   mean_flaws |
|:------------------|:------------------|-------:|----------:|----------------:|------------------:|----------------:|---------------:|-----------:|-----------------:|------------:|------------:|---------:|-------------:|
| claude-haiku-5-5  | baseline          |    261 |     0.709 |          0.0098 |            0.0065 |            24.2 |            8   |      0     |             0    |        4.83 |        5.59 |        0 |         0.14 |
| claude-haiku-5-5  | baseline-review   |    261 |     0.736 |          0.0243 |            0.015  |            36.4 |           12   |      0     |             0    |        6.1  |        7.51 |        0 |         0.09 |
| claude-haiku-5-5  | enforced          |    225 |     0.662 |          0.0171 |            0.0114 |            46.3 |           13   |      0.929 |             5.24 |        2.56 |        5.45 |        0 |         0.18 |
| claude-haiku-5-5  | intellij-enforced |     72 |     0.639 |          0.0216 |            0.0158 |           152.3 |           19.5 |      1     |             9.42 |        2.56 |        5.31 |        0 |         0.31 |
| claude-haiku-5-5  | intellij-optional |     72 |     0.667 |          0.0115 |            0.0077 |            32.5 |            9.5 |      0.028 |             0.07 |        5.56 |        6    |        0 |         0.17 |
| claude-haiku-5-5  | optional          |    225 |     0.738 |          0.0111 |            0.0068 |            23.6 |            8   |      0     |             0    |        4.77 |        5.9  |        0 |         0.17 |
| claude-opus-5-5   | baseline          |     87 |     0.782 |          0.2698 |            0.1799 |            28.7 |            7   |      0     |             0    |        6.25 |        6.74 |        0 |         0.12 |
| claude-opus-5-5   | baseline-review   |     87 |     0.759 |          0.5984 |            0.4086 |            45   |           11   |      0     |             0    |        7.4  |        8.39 |        0 |         0.14 |
| claude-opus-5-5   | enforced          |     75 |     0.787 |          0.3378 |            0.2438 |            42.6 |           11   |      0.893 |             2.43 |        5.13 |        5.97 |        0 |         0.31 |
| claude-opus-5-5   | intellij-enforced |     24 |     0.708 |          0.4345 |            0.3346 |           111.5 |           14   |      0.958 |             3.54 |        5.79 |        6.29 |        0 |         0.19 |
| claude-opus-5-5   | intellij-optional |     24 |     0.708 |          0.3638 |            0.2137 |            38   |            8.5 |      0.042 |             0.04 |        7.25 |        8.21 |        0 |         0.12 |
| claude-opus-5-5   | optional          |     75 |     0.787 |          0.2619 |            0.1825 |            28.4 |            8   |      0.16  |             0.23 |        5.53 |        6.29 |        0 |         0.1  |
| claude-sonnet-5-5 | baseline          |    174 |     0.73  |          0.0828 |            0.0591 |            17.6 |            5   |      0     |             0    |        3.92 |        4.44 |        0 |         0.27 |
| claude-sonnet-5-5 | baseline-review   |    174 |     0.724 |          0.1703 |            0.1324 |            26.3 |            8   |      0     |             0    |        4.91 |        5.77 |        0 |         0.2  |
| claude-sonnet-5-5 | enforced          |    150 |     0.72  |          0.1188 |            0.0932 |            28.5 |            8   |      0.86  |             2.47 |        2.72 |        3.77 |        0 |         0.29 |
| claude-sonnet-5-5 | intellij-enforced |     48 |     0.688 |          0.1504 |            0.1325 |           143.4 |           11.5 |      0.979 |             5.02 |        3.12 |        3.35 |        0 |         0.28 |
| claude-sonnet-5-5 | intellij-optional |     48 |     0.625 |          0.0999 |            0.0642 |            20.3 |            6   |      0     |             0    |        4.62 |        4.71 |        0 |         0.28 |
| claude-sonnet-5-5 | optional          |    150 |     0.713 |          0.0788 |            0.0562 |            16.6 |            5   |      0     |             0    |        3.74 |        4.28 |        0 |         0.21 |

## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; for cost, better = cheaper)

| stratum   | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:----------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| all       | success (pp)      | baseline-review - baseline          |     -0.064 |  -2.427 |   2.299 |       16 |    233 |      12 |      87 |     261 |
| all       | cost ratio        | baseline-review / baseline          |      2.34  |   2.24  |   2.449 |        3 |      0 |     258 |      87 |     261 |
| all       | flaws (mean diff) | baseline-review - baseline          |     -0.036 |  -0.101 |   0.021 |       32 |    114 |      22 |      56 |     168 |
| all       | success (pp)      | optional - baseline                 |      0.296 |  -2.15  |   2.963 |       14 |    199 |      12 |      75 |     225 |
| all       | cost ratio        | optional / baseline                 |      1.02  |   0.978 |   1.06  |       87 |      0 |     138 |      75 |     225 |
| all       | flaws (mean diff) | optional - baseline                 |     -0.031 |  -0.099 |   0.034 |       23 |    103 |      17 |      48 |     143 |
| all       | success (pp)      | enforced - baseline                 |     -2     |  -5.185 |   1.037 |       13 |    188 |      24 |      75 |     225 |
| all       | cost ratio        | enforced / baseline                 |      1.57  |   1.449 |   1.702 |       32 |      0 |     193 |      75 |     225 |
| all       | flaws (mean diff) | enforced - baseline                 |      0.063 |  -0.019 |   0.149 |       21 |     92 |      29 |      48 |     142 |
| all       | success (pp)      | intellij-optional - baseline        |      0     |  -3.472 |   3.478 |        6 |     61 |       5 |      24 |      72 |
| all       | cost ratio        | intellij-optional / baseline        |      1.011 |   0.96  |   1.061 |       29 |      0 |      43 |      24 |      72 |
| all       | flaws (mean diff) | intellij-optional - baseline        |      0.052 |  -0.003 |   0.111 |        5 |     34 |       9 |      16 |      48 |
| all       | success (pp)      | intellij-enforced - baseline        |      1.157 |  -5.787 |   7.87  |        7 |     59 |       6 |      24 |      72 |
| all       | cost ratio        | intellij-enforced / baseline        |      1.664 |   1.443 |   1.904 |       11 |      0 |      61 |      24 |      72 |
| all       | flaws (mean diff) | intellij-enforced - baseline        |      0.122 |   0.007 |   0.25  |        3 |     34 |      11 |      16 |      48 |
| all       | success (pp)      | optional - baseline-review          |     -0.074 |  -2.889 |   3.037 |        7 |    207 |      11 |      75 |     225 |
| all       | cost ratio        | optional / baseline-review          |      0.439 |   0.424 |   0.455 |      224 |      0 |       1 |      75 |     225 |
| all       | flaws (mean diff) | optional - baseline-review          |      0.017 |  -0.03  |   0.066 |       16 |    108 |      19 |      48 |     143 |
| all       | success (pp)      | enforced - baseline-review          |     -2.37  |  -5.185 |   0.444 |        8 |    194 |      23 |      75 |     225 |
| all       | cost ratio        | enforced / baseline-review          |      0.676 |   0.634 |   0.723 |      188 |      0 |      37 |      75 |     225 |
| all       | flaws (mean diff) | enforced - baseline-review          |      0.113 |   0.032 |   0.199 |       16 |     95 |      31 |      48 |     142 |
| all       | success (pp)      | intellij-optional - baseline-review |     -0.231 |  -3.935 |   3.704 |        4 |     64 |       4 |      24 |      72 |
| all       | cost ratio        | intellij-optional / baseline-review |      0.429 |   0.403 |   0.454 |       72 |      0 |       0 |      24 |      72 |
| all       | flaws (mean diff) | intellij-optional - baseline-review |     -0.024 |  -0.101 |   0.045 |        6 |     33 |       9 |      16 |      48 |
| all       | success (pp)      | intellij-enforced - baseline-review |      0.926 |  -6.713 |   9.722 |        7 |     57 |       8 |      24 |      72 |
| all       | cost ratio        | intellij-enforced / baseline-review |      0.706 |   0.625 |   0.805 |       57 |      0 |      15 |      24 |      72 |
| all       | flaws (mean diff) | intellij-enforced - baseline-review |      0.045 |  -0.108 |   0.208 |        7 |     30 |      11 |      16 |      48 |
| all       | success (pp)      | intellij-optional - optional        |     -3.241 | -10.2   |   0.926 |        2 |     30 |       4 |      12 |      36 |
| all       | cost ratio        | intellij-optional / optional        |      0.976 |   0.917 |   1.026 |       12 |      0 |      24 |      12 |      36 |
| all       | flaws (mean diff) | intellij-optional - optional        |     -0.062 |         |         |        5 |     16 |       3 |       8 |      24 |
| all       | success (pp)      | intellij-enforced - enforced        |     -2.778 |  -9.259 |   2.778 |        2 |     31 |       3 |      12 |      36 |
| all       | cost ratio        | intellij-enforced / enforced        |      1.104 |   0.951 |   1.277 |       13 |      0 |      23 |      12 |      36 |
| all       | flaws (mean diff) | intellij-enforced - enforced        |     -0.083 |         |         |        5 |     15 |       4 |       8 |      24 |

## The same contrasts by stratum

### By model

| stratum                 | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:------------------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| model=claude-haiku-5-5  | success (pp)      | baseline-review - baseline          |      2.682 |  -0.383 |   5.747 |       11 |     73 |       3 |      87 |      87 |
| model=claude-haiku-5-5  | cost ratio        | baseline-review / baseline          |      2.423 |   2.309 |   2.556 |        0 |      0 |      87 |      87 |      87 |
| model=claude-haiku-5-5  | flaws (mean diff) | baseline-review - baseline          |     -0.054 |  -0.131 |   0.012 |       13 |     34 |       9 |      56 |      56 |
| model=claude-haiku-5-5  | success (pp)      | optional - baseline                 |      3.556 |   0     |   7.556 |        9 |     63 |       3 |      75 |      75 |
| model=claude-haiku-5-5  | cost ratio        | optional / baseline                 |      1.058 |   1.004 |   1.114 |       26 |      0 |      49 |      75 |      75 |
| model=claude-haiku-5-5  | flaws (mean diff) | optional - baseline                 |      0.021 |  -0.057 |   0.106 |        8 |     31 |       8 |      47 |      47 |
| model=claude-haiku-5-5  | success (pp)      | enforced - baseline                 |     -4     |  -8     |   0     |        6 |     54 |      15 |      75 |      75 |
| model=claude-haiku-5-5  | cost ratio        | enforced / baseline                 |      1.714 |   1.528 |   1.916 |        9 |      0 |      66 |      75 |      75 |
| model=claude-haiku-5-5  | flaws (mean diff) | enforced - baseline                 |      0.021 |  -0.085 |   0.121 |        7 |     30 |      10 |      47 |      47 |
| model=claude-haiku-5-5  | success (pp)      | intellij-optional - baseline        |      0     |  -8.333 |   6.944 |        3 |     19 |       2 |      24 |      24 |
| model=claude-haiku-5-5  | cost ratio        | intellij-optional / baseline        |      1.03  |   0.962 |   1.096 |        8 |      0 |      16 |      24 |      24 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-optional - baseline        |      0.062 |  -0.042 |   0.167 |        2 |      9 |       5 |      16 |      16 |
| model=claude-haiku-5-5  | success (pp)      | intellij-enforced - baseline        |     -2.778 | -12.5   |   5.556 |        3 |     17 |       4 |      24 |      24 |
| model=claude-haiku-5-5  | cost ratio        | intellij-enforced / baseline        |      1.904 |   1.544 |   2.386 |        2 |      0 |      22 |      24 |      24 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-enforced - baseline        |      0.208 |   0.021 |   0.417 |        1 |     10 |       5 |      16 |      16 |
| model=claude-haiku-5-5  | success (pp)      | optional - baseline-review          |     -0.889 |  -4     |   2.667 |        2 |     67 |       6 |      75 |      75 |
| model=claude-haiku-5-5  | cost ratio        | optional / baseline-review          |      0.44  |   0.419 |   0.462 |       75 |      0 |       0 |      75 |      75 |
| model=claude-haiku-5-5  | flaws (mean diff) | optional - baseline-review          |      0.085 |   0.007 |   0.184 |        3 |     35 |       9 |      47 |      47 |
| model=claude-haiku-5-5  | success (pp)      | enforced - baseline-review          |     -8.444 | -12.4   |  -4.444 |        1 |     58 |      16 |      75 |      75 |
| model=claude-haiku-5-5  | cost ratio        | enforced / baseline-review          |      0.713 |   0.638 |   0.798 |       55 |      0 |      20 |      75 |      75 |
| model=claude-haiku-5-5  | flaws (mean diff) | enforced - baseline-review          |      0.085 |   0.007 |   0.17  |        5 |     31 |      11 |      47 |      47 |
| model=claude-haiku-5-5  | success (pp)      | intellij-optional - baseline-review |      1.389 |  -5.556 |   8.333 |        3 |     20 |       1 |      24 |      24 |
| model=claude-haiku-5-5  | cost ratio        | intellij-optional / baseline-review |      0.414 |   0.378 |   0.454 |       24 |      0 |       0 |      24 |      24 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-optional - baseline-review |      0.083 |   0.021 |   0.167 |        0 |     12 |       4 |      16 |      16 |
| model=claude-haiku-5-5  | success (pp)      | intellij-enforced - baseline-review |     -1.389 | -13.9   |  11.1   |        4 |     14 |       6 |      24 |      24 |
| model=claude-haiku-5-5  | cost ratio        | intellij-enforced / baseline-review |      0.765 |   0.634 |   0.955 |       17 |      0 |       7 |      24 |      24 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-enforced - baseline-review |      0.229 |   0     |   0.521 |        3 |      6 |       7 |      16 |      16 |
| model=claude-haiku-5-5  | success (pp)      | intellij-optional - optional        |     -5.556 | -19.4   |   5.556 |        1 |      9 |       2 |      12 |      12 |
| model=claude-haiku-5-5  | cost ratio        | intellij-optional / optional        |      0.951 |   0.814 |   1.054 |        4 |      0 |       8 |      12 |      12 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-optional - optional        |     -0.25  |         |         |        3 |      5 |       0 |       8 |       8 |
| model=claude-haiku-5-5  | success (pp)      | intellij-enforced - enforced        |     -0     | -11.1   |  11.1   |        2 |      8 |       2 |      12 |      12 |
| model=claude-haiku-5-5  | cost ratio        | intellij-enforced / enforced        |      1.234 |   0.891 |   1.761 |        3 |      0 |       9 |      12 |      12 |
| model=claude-haiku-5-5  | flaws (mean diff) | intellij-enforced - enforced        |      0.125 |         |         |        2 |      3 |       3 |       8 |       8 |
| model=claude-opus-5-5   | success (pp)      | baseline-review - baseline          |     -2.299 |  -6.897 |   2.299 |        1 |     83 |       3 |      87 |      87 |
| model=claude-opus-5-5   | cost ratio        | baseline-review / baseline          |      2.29  |   2.136 |   2.438 |        1 |      0 |      86 |      87 |      87 |
| model=claude-opus-5-5   | flaws (mean diff) | baseline-review - baseline          |      0.018 |  -0.125 |   0.196 |        5 |     46 |       5 |      56 |      56 |
| model=claude-opus-5-5   | success (pp)      | optional - baseline                 |      0     |  -5.333 |   5.333 |        2 |     71 |       2 |      75 |      75 |
| model=claude-opus-5-5   | cost ratio        | optional / baseline                 |      0.998 |   0.938 |   1.059 |       34 |      0 |      41 |      75 |      75 |
| model=claude-opus-5-5   | flaws (mean diff) | optional - baseline                 |     -0.042 |  -0.208 |   0.125 |        6 |     38 |       4 |      48 |      48 |
| model=claude-opus-5-5   | success (pp)      | enforced - baseline                 |      0     |  -6.667 |   6.667 |        3 |     69 |       3 |      75 |      75 |
| model=claude-opus-5-5   | cost ratio        | enforced / baseline                 |      1.368 |   1.263 |   1.493 |       17 |      0 |      58 |      75 |      75 |
| model=claude-opus-5-5   | flaws (mean diff) | enforced - baseline                 |      0.167 |  -0.042 |   0.396 |        4 |     34 |      10 |      48 |      48 |
| model=claude-opus-5-5   | success (pp)      | intellij-optional - baseline        |      0     | -12.5   |  12.5   |        1 |     22 |       1 |      24 |      24 |
| model=claude-opus-5-5   | cost ratio        | intellij-optional / baseline        |      0.949 |   0.852 |   1.056 |       15 |      0 |       9 |      24 |      24 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-optional - baseline        |      0.125 |   0     |   0.375 |        0 |     15 |       1 |      16 |      16 |
| model=claude-opus-5-5   | success (pp)      | intellij-enforced - baseline        |      0     | -16.7   |  16.7   |        2 |     20 |       2 |      24 |      24 |
| model=claude-opus-5-5   | cost ratio        | intellij-enforced / baseline        |      1.346 |   1.155 |   1.585 |        7 |      0 |      17 |      24 |      24 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-enforced - baseline        |      0.188 |   0     |   0.375 |        0 |     13 |       3 |      16 |      16 |
| model=claude-opus-5-5   | success (pp)      | optional - baseline-review          |      2.667 |  -2.667 |   8     |        3 |     71 |       1 |      75 |      75 |
| model=claude-opus-5-5   | cost ratio        | optional / baseline-review          |      0.439 |   0.408 |   0.471 |       74 |      0 |       1 |      75 |      75 |
| model=claude-opus-5-5   | flaws (mean diff) | optional - baseline-review          |     -0.042 |  -0.146 |   0.042 |        4 |     42 |       2 |      48 |      48 |
| model=claude-opus-5-5   | success (pp)      | enforced - baseline-review          |      2.667 |  -2.667 |   8     |        3 |     71 |       1 |      75 |      75 |
| model=claude-opus-5-5   | cost ratio        | enforced / baseline-review          |      0.602 |   0.556 |   0.654 |       68 |      0 |       7 |      75 |      75 |
| model=claude-opus-5-5   | flaws (mean diff) | enforced - baseline-review          |      0.167 |   0     |   0.354 |        4 |     34 |      10 |      48 |      48 |
| model=claude-opus-5-5   | success (pp)      | intellij-optional - baseline-review |      4.167 |   0     |  12.5   |        1 |     23 |       0 |      24 |      24 |
| model=claude-opus-5-5   | cost ratio        | intellij-optional / baseline-review |      0.432 |   0.387 |   0.476 |       24 |      0 |       0 |      24 |      24 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-optional - baseline-review |     -0.188 |  -0.375 |   0     |        3 |     13 |       0 |      16 |      16 |
| model=claude-opus-5-5   | success (pp)      | intellij-enforced - baseline-review |      4.167 |  -8.333 |  16.7   |        2 |     21 |       1 |      24 |      24 |
| model=claude-opus-5-5   | cost ratio        | intellij-enforced / baseline-review |      0.613 |   0.521 |   0.733 |       19 |      0 |       5 |      24 |      24 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-enforced - baseline-review |     -0.125 |  -0.438 |   0.125 |        2 |     13 |       1 |      16 |      16 |
| model=claude-opus-5-5   | success (pp)      | intellij-optional - optional        |      0     |   0     |   0     |        0 |     12 |       0 |      12 |      12 |
| model=claude-opus-5-5   | cost ratio        | intellij-optional / optional        |      0.97  |   0.863 |   1.067 |        4 |      0 |       8 |      12 |      12 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-optional - optional        |      0     |         |         |        0 |      8 |       0 |       8 |       8 |
| model=claude-opus-5-5   | success (pp)      | intellij-enforced - enforced        |     -8.333 | -25     |   0     |        0 |     11 |       1 |      12 |      12 |
| model=claude-opus-5-5   | cost ratio        | intellij-enforced / enforced        |      1.011 |   0.793 |   1.262 |        6 |      0 |       6 |      12 |      12 |
| model=claude-opus-5-5   | flaws (mean diff) | intellij-enforced - enforced        |     -0.25  |         |         |        2 |      5 |       1 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp)      | baseline-review - baseline          |     -0.575 |  -5.747 |   4.598 |        4 |     77 |       6 |      87 |      87 |
| model=claude-sonnet-5-5 | cost ratio        | baseline-review / baseline          |      2.309 |   2.156 |   2.46  |        2 |      0 |      85 |      87 |      87 |
| model=claude-sonnet-5-5 | flaws (mean diff) | baseline-review - baseline          |     -0.071 |  -0.196 |   0.054 |       14 |     34 |       8 |      56 |      56 |
| model=claude-sonnet-5-5 | success (pp)      | optional - baseline                 |     -2.667 |  -8     |   2.667 |        3 |     65 |       7 |      75 |      75 |
| model=claude-sonnet-5-5 | cost ratio        | optional / baseline                 |      1.004 |   0.927 |   1.076 |       27 |      0 |      48 |      75 |      75 |
| model=claude-sonnet-5-5 | flaws (mean diff) | optional - baseline                 |     -0.073 |  -0.198 |   0.042 |        9 |     34 |       5 |      48 |      48 |
| model=claude-sonnet-5-5 | success (pp)      | enforced - baseline                 |     -2     |  -7.333 |   4     |        4 |     65 |       6 |      75 |      75 |
| model=claude-sonnet-5-5 | cost ratio        | enforced / baseline                 |      1.649 |   1.477 |   1.829 |        6 |      0 |      69 |      75 |      75 |
| model=claude-sonnet-5-5 | flaws (mean diff) | enforced - baseline                 |      0     |  -0.138 |   0.138 |       10 |     28 |       9 |      47 |      47 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-optional - baseline        |      0     | -12.5   |  12.5   |        2 |     20 |       2 |      24 |      24 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-optional / baseline        |      1.058 |   0.975 |   1.14  |        6 |      0 |      18 |      24 |      24 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-optional - baseline        |     -0.031 |  -0.219 |   0.156 |        3 |     10 |       3 |      16 |      16 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-enforced - baseline        |      6.25  |   0     |  16.7   |        2 |     22 |       0 |      24 |      24 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-enforced / baseline        |      1.8   |   1.514 |   2.084 |        2 |      0 |      22 |      24 |      24 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-enforced - baseline        |     -0.031 |  -0.281 |   0.188 |        2 |     11 |       3 |      16 |      16 |
| model=claude-sonnet-5-5 | success (pp)      | optional - baseline-review          |     -2     |  -6.017 |   1.333 |        2 |     69 |       4 |      75 |      75 |
| model=claude-sonnet-5-5 | cost ratio        | optional / baseline-review          |      0.439 |   0.416 |   0.461 |       75 |      0 |       0 |      75 |      75 |
| model=claude-sonnet-5-5 | flaws (mean diff) | optional - baseline-review          |      0.01  |  -0.104 |   0.125 |        9 |     31 |       8 |      48 |      48 |
| model=claude-sonnet-5-5 | success (pp)      | enforced - baseline-review          |     -1.333 |  -5.333 |   2.667 |        4 |     65 |       6 |      75 |      75 |
| model=claude-sonnet-5-5 | cost ratio        | enforced / baseline-review          |      0.721 |   0.676 |   0.771 |       65 |      0 |      10 |      75 |      75 |
| model=claude-sonnet-5-5 | flaws (mean diff) | enforced - baseline-review          |      0.085 |  -0.043 |   0.213 |        7 |     30 |      10 |      47 |      47 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-optional - baseline-review |     -6.25  | -14.6   |   0     |        0 |     21 |       3 |      24 |      24 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-optional / baseline-review |      0.441 |   0.402 |   0.483 |       24 |      0 |       0 |      24 |      24 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-optional - baseline-review |      0.031 |  -0.188 |   0.219 |        3 |      8 |       5 |      16 |      16 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-enforced - baseline-review |      0     |  -6.25  |   6.25  |        1 |     22 |       1 |      24 |      24 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-enforced / baseline-review |      0.751 |   0.658 |   0.859 |       21 |      0 |       3 |      24 |      24 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-enforced - baseline-review |      0.031 |  -0.188 |   0.219 |        2 |     11 |       3 |      16 |      16 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-optional - optional        |     -4.167 | -16.7   |   8.333 |        1 |      9 |       2 |      12 |      12 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-optional / optional        |      1.008 |   0.889 |   1.14  |        4 |      0 |       8 |      12 |      12 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-optional - optional        |      0.062 |         |         |        2 |      3 |       3 |       8 |       8 |
| model=claude-sonnet-5-5 | success (pp)      | intellij-enforced - enforced        |      0     |   0     |   0     |        0 |     12 |       0 |      12 |      12 |
| model=claude-sonnet-5-5 | cost ratio        | intellij-enforced / enforced        |      1.08  |   0.93  |   1.256 |        4 |      0 |       8 |      12 |      12 |
| model=claude-sonnet-5-5 | flaws (mean diff) | intellij-enforced - enforced        |     -0.125 |         |         |        1 |      7 |       0 |       8 |       8 |


### By lang

| stratum          | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:-----------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| lang=cpp         | success (pp)      | baseline-review - baseline          |      1.389 |  -6.481 |   8.333 |        4 |     31 |       1 |      12 |      36 |
| lang=cpp         | cost ratio        | baseline-review / baseline          |      2.173 |   1.834 |   2.455 |        3 |      0 |      33 |      12 |      36 |
| lang=cpp         | flaws (mean diff) | baseline-review - baseline          |     -0.056 |         |         |        5 |     13 |       3 |       7 |      21 |
| lang=cpp         | success (pp)      | optional - baseline                 |      1.389 |  -6.481 |   8.796 |        4 |     31 |       1 |      12 |      36 |
| lang=cpp         | cost ratio        | optional / baseline                 |      0.984 |   0.824 |   1.117 |       10 |      0 |      26 |      12 |      36 |
| lang=cpp         | flaws (mean diff) | optional - baseline                 |     -0.025 |         |         |        4 |     14 |       2 |       7 |      20 |
| lang=cpp         | success (pp)      | enforced - baseline                 |     -0.926 |  -9.259 |   7.87  |        4 |     28 |       4 |      12 |      36 |
| lang=cpp         | cost ratio        | enforced / baseline                 |      1.462 |   1.116 |   1.853 |        7 |      0 |      29 |      12 |      36 |
| lang=cpp         | flaws (mean diff) | enforced - baseline                 |     -0.018 |         |         |        4 |     11 |       4 |       7 |      19 |
| lang=cpp         | success (pp)      | optional - baseline-review          |      0     |   0     |   0     |        0 |     36 |       0 |      12 |      36 |
| lang=cpp         | cost ratio        | optional / baseline-review          |      0.453 |   0.423 |   0.485 |       36 |      0 |       0 |      12 |      36 |
| lang=cpp         | flaws (mean diff) | optional - baseline-review          |      0.033 |         |         |        4 |     12 |       4 |       7 |      20 |
| lang=cpp         | success (pp)      | enforced - baseline-review          |     -2.315 |  -7.407 |   2.778 |        1 |     32 |       3 |      12 |      36 |
| lang=cpp         | cost ratio        | enforced / baseline-review          |      0.673 |   0.557 |   0.807 |       31 |      0 |       5 |      12 |      36 |
| lang=cpp         | flaws (mean diff) | enforced - baseline-review          |      0.044 |         |         |        3 |     13 |       3 |       7 |      19 |
| lang=csharp      | success (pp)      | baseline-review - baseline          |     -2.778 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=csharp      | cost ratio        | baseline-review / baseline          |      2.221 |         |         |        0 |      0 |      18 |       6 |      18 |
| lang=csharp      | flaws (mean diff) | baseline-review - baseline          |     -0.125 |         |         |        3 |      8 |       1 |       4 |      12 |
| lang=csharp      | success (pp)      | optional - baseline                 |     -2.778 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=csharp      | cost ratio        | optional / baseline                 |      1.058 |         |         |        6 |      0 |      12 |       6 |      18 |
| lang=csharp      | flaws (mean diff) | optional - baseline                 |     -0.069 |         |         |        2 |     10 |       0 |       4 |      12 |
| lang=csharp      | success (pp)      | enforced - baseline                 |     -5.556 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=csharp      | cost ratio        | enforced / baseline                 |      1.515 |         |         |        2 |      0 |      16 |       6 |      18 |
| lang=csharp      | flaws (mean diff) | enforced - baseline                 |      0.333 |         |         |        1 |      8 |       3 |       4 |      12 |
| lang=csharp      | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     18 |       0 |       6 |      18 |
| lang=csharp      | cost ratio        | optional / baseline-review          |      0.476 |         |         |       17 |      0 |       1 |       6 |      18 |
| lang=csharp      | flaws (mean diff) | optional - baseline-review          |      0.056 |         |         |        1 |     10 |       1 |       4 |      12 |
| lang=csharp      | success (pp)      | enforced - baseline-review          |     -2.778 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=csharp      | cost ratio        | enforced / baseline-review          |      0.682 |         |         |       16 |      0 |       2 |       6 |      18 |
| lang=csharp      | flaws (mean diff) | enforced - baseline-review          |      0.458 |         |         |        0 |      7 |       5 |       4 |      12 |
| lang=css         | success (pp)      | baseline-review - baseline          |     -0.926 |         |         |        2 |     14 |       2 |       6 |      18 |
| lang=css         | cost ratio        | baseline-review / baseline          |      2.387 |         |         |        0 |      0 |      18 |       6 |      18 |
| lang=css         | flaws (mean diff) | baseline-review - baseline          |      0.028 |         |         |        3 |      5 |       4 |       4 |      12 |
| lang=css         | success (pp)      | optional - baseline                 |     -5.556 |         |         |        0 |     16 |       2 |       6 |      18 |
| lang=css         | cost ratio        | optional / baseline                 |      0.974 |         |         |        8 |      0 |      10 |       6 |      18 |
| lang=css         | flaws (mean diff) | optional - baseline                 |      0.042 |         |         |        1 |      8 |       3 |       4 |      12 |
| lang=css         | success (pp)      | enforced - baseline                 |     -4.63  |         |         |        1 |     14 |       3 |       6 |      18 |
| lang=css         | cost ratio        | enforced / baseline                 |      1.197 |         |         |        4 |      0 |      14 |       6 |      18 |
| lang=css         | flaws (mean diff) | enforced - baseline                 |      0.139 |         |         |        2 |      6 |       4 |       4 |      12 |
| lang=css         | success (pp)      | optional - baseline-review          |     -4.63  |         |         |        1 |     14 |       3 |       6 |      18 |
| lang=css         | cost ratio        | optional / baseline-review          |      0.408 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=css         | flaws (mean diff) | optional - baseline-review          |      0.014 |         |         |        2 |      7 |       3 |       4 |      12 |
| lang=css         | success (pp)      | enforced - baseline-review          |     -3.704 |         |         |        1 |     14 |       3 |       6 |      18 |
| lang=css         | cost ratio        | enforced / baseline-review          |      0.501 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=css         | flaws (mean diff) | enforced - baseline-review          |      0.111 |         |         |        4 |      5 |       3 |       4 |      12 |
| lang=java        | success (pp)      | baseline-review - baseline          |     -2.778 |  -7.407 |   0.926 |        1 |     32 |       3 |      12 |      36 |
| lang=java        | cost ratio        | baseline-review / baseline          |      2.46  |   2.233 |   2.771 |        0 |      0 |      36 |      12 |      36 |
| lang=java        | flaws (mean diff) | baseline-review - baseline          |      0.042 |         |         |        3 |     17 |       4 |       8 |      24 |
| lang=java        | success (pp)      | intellij-optional - baseline        |     -0.926 |  -5.556 |   2.778 |        1 |     34 |       1 |      12 |      36 |
| lang=java        | cost ratio        | intellij-optional / baseline        |      1.044 |   0.981 |   1.111 |       14 |      0 |      22 |      12 |      36 |
| lang=java        | flaws (mean diff) | intellij-optional - baseline        |      0.007 |         |         |        3 |     17 |       4 |       8 |      24 |
| lang=java        | success (pp)      | intellij-enforced - baseline        |      2.778 |  -4.63  |  12     |        3 |     32 |       1 |      12 |      36 |
| lang=java        | cost ratio        | intellij-enforced / baseline        |      1.655 |   1.368 |   1.994 |        6 |      0 |      30 |      12 |      36 |
| lang=java        | flaws (mean diff) | intellij-enforced - baseline        |      0.09  |         |         |        1 |     20 |       3 |       8 |      24 |
| lang=java        | success (pp)      | intellij-optional - baseline-review |      1.852 |   0     |   4.63  |        2 |     34 |       0 |      12 |      36 |
| lang=java        | cost ratio        | intellij-optional / baseline-review |      0.425 |   0.386 |   0.465 |       36 |      0 |       0 |      12 |      36 |
| lang=java        | flaws (mean diff) | intellij-optional - baseline-review |     -0.035 |         |         |        3 |     18 |       3 |       8 |      24 |
| lang=java        | success (pp)      | intellij-enforced - baseline-review |      5.556 |  -3.704 |  18.5   |        5 |     29 |       2 |      12 |      36 |
| lang=java        | cost ratio        | intellij-enforced / baseline-review |      0.673 |   0.571 |   0.803 |       29 |      0 |       7 |      12 |      36 |
| lang=java        | flaws (mean diff) | intellij-enforced - baseline-review |      0.049 |         |         |        4 |     16 |       4 |       8 |      24 |
| lang=java-kotlin | success (pp)      | baseline-review - baseline          |      7.407 |         |         |        2 |     16 |       0 |       6 |      18 |
| lang=java-kotlin | cost ratio        | baseline-review / baseline          |      2.113 |         |         |        0 |      0 |      18 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | baseline-review - baseline          |      0.028 |         |         |        3 |      8 |       1 |       4 |      12 |
| lang=java-kotlin | success (pp)      | optional - baseline                 |      5.556 |         |         |        1 |     17 |       0 |       6 |      18 |
| lang=java-kotlin | cost ratio        | optional / baseline                 |      0.958 |         |         |       11 |      0 |       7 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | optional - baseline                 |      0.194 |         |         |        1 |      7 |       4 |       4 |      12 |
| lang=java-kotlin | success (pp)      | enforced - baseline                 |      3.704 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | enforced / baseline                 |      1.516 |         |         |        6 |      0 |      12 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | enforced - baseline                 |      0.306 |         |         |        2 |      6 |       4 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-optional - baseline        |      4.63  |         |         |        2 |     16 |       0 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-optional / baseline        |      0.914 |         |         |        9 |      0 |       9 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-optional - baseline        |      0.097 |         |         |        2 |      8 |       2 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-enforced - baseline        |      3.704 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-enforced / baseline        |      1.561 |         |         |        4 |      0 |      14 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-enforced - baseline        |      0.056 |         |         |        2 |      7 |       3 |       4 |      12 |
| lang=java-kotlin | success (pp)      | optional - baseline-review          |     -1.852 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | optional / baseline-review          |      0.454 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | optional - baseline-review          |      0.167 |         |         |        1 |      8 |       3 |       4 |      12 |
| lang=java-kotlin | success (pp)      | enforced - baseline-review          |     -3.704 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | enforced / baseline-review          |      0.717 |         |         |       13 |      0 |       5 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | enforced - baseline-review          |      0.278 |         |         |        0 |      8 |       4 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-optional - baseline-review |     -2.778 |         |         |        0 |     17 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-optional / baseline-review |      0.432 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-optional - baseline-review |      0.069 |         |         |        1 |      7 |       4 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-enforced - baseline-review |     -3.704 |         |         |        0 |     16 |       2 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-enforced / baseline-review |      0.739 |         |         |       13 |      0 |       5 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-enforced - baseline-review |      0.028 |         |         |        1 |      7 |       4 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-optional - optional        |     -0.926 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-optional / optional        |      0.954 |         |         |        8 |      0 |      10 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-optional - optional        |     -0.097 |         |         |        3 |      7 |       2 |       4 |      12 |
| lang=java-kotlin | success (pp)      | intellij-enforced - enforced        |     -0     |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=java-kotlin | cost ratio        | intellij-enforced / enforced        |      1.03  |         |         |        8 |      0 |      10 |       6 |      18 |
| lang=java-kotlin | flaws (mean diff) | intellij-enforced - enforced        |     -0.25  |         |         |        4 |      6 |       2 |       4 |      12 |
| lang=kotlin      | success (pp)      | baseline-review - baseline          |     -0.926 |         |         |        2 |     14 |       2 |       6 |      18 |
| lang=kotlin      | cost ratio        | baseline-review / baseline          |      2.41  |         |         |        0 |      0 |      18 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | baseline-review - baseline          |      0.194 |         |         |        1 |      8 |       3 |       4 |      12 |
| lang=kotlin      | success (pp)      | optional - baseline                 |      2.778 |         |         |        3 |     12 |       3 |       6 |      18 |
| lang=kotlin      | cost ratio        | optional / baseline                 |      1.049 |         |         |        6 |      0 |      12 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | optional - baseline                 |      0.125 |         |         |        1 |      8 |       3 |       4 |      12 |
| lang=kotlin      | success (pp)      | enforced - baseline                 |      0.926 |         |         |        2 |     14 |       2 |       6 |      18 |
| lang=kotlin      | cost ratio        | enforced / baseline                 |      1.516 |         |         |        1 |      0 |      17 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | enforced - baseline                 |      0.167 |         |         |        0 |      7 |       5 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-optional - baseline        |     -2.778 |         |         |        3 |     11 |       4 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-optional / baseline        |      1.048 |         |         |        6 |      0 |      12 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-optional - baseline        |      0.097 |         |         |        0 |      9 |       3 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-enforced - baseline        |     -4.63  |         |         |        3 |     11 |       4 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-enforced / baseline        |      1.795 |         |         |        1 |      0 |      17 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-enforced - baseline        |      0.25  |         |         |        0 |      7 |       5 |       4 |      12 |
| lang=kotlin      | success (pp)      | optional - baseline-review          |      3.704 |         |         |        2 |     13 |       3 |       6 |      18 |
| lang=kotlin      | cost ratio        | optional / baseline-review          |      0.435 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | optional - baseline-review          |     -0.069 |         |         |        2 |      9 |       1 |       4 |      12 |
| lang=kotlin      | success (pp)      | enforced - baseline-review          |      1.852 |         |         |        2 |     13 |       3 |       6 |      18 |
| lang=kotlin      | cost ratio        | enforced / baseline-review          |      0.629 |         |         |       15 |      0 |       3 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | enforced - baseline-review          |     -0.028 |         |         |        2 |      7 |       3 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-optional - baseline-review |     -1.852 |         |         |        2 |     13 |       3 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-optional / baseline-review |      0.435 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-optional - baseline-review |     -0.097 |         |         |        2 |      8 |       2 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-enforced - baseline-review |     -3.704 |         |         |        2 |     12 |       4 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-enforced / baseline-review |      0.745 |         |         |       15 |      0 |       3 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-enforced - baseline-review |      0.056 |         |         |        2 |      7 |       3 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-optional - optional        |     -5.556 |         |         |        1 |     14 |       3 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-optional / optional        |      0.999 |         |         |        4 |      0 |      14 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-optional - optional        |     -0.028 |         |         |        2 |      9 |       1 |       4 |      12 |
| lang=kotlin      | success (pp)      | intellij-enforced - enforced        |     -5.556 |         |         |        1 |     15 |       2 |       6 |      18 |
| lang=kotlin      | cost ratio        | intellij-enforced / enforced        |      1.185 |         |         |        5 |      0 |      13 |       6 |      18 |
| lang=kotlin      | flaws (mean diff) | intellij-enforced - enforced        |      0.083 |         |         |        1 |      9 |       2 |       4 |      12 |
| lang=php         | success (pp)      | baseline-review - baseline          |      1.852 |   0     |   4.63  |        2 |     34 |       0 |      12 |      36 |
| lang=php         | cost ratio        | baseline-review / baseline          |      2.241 |   2.054 |   2.452 |        0 |      0 |      36 |      12 |      36 |
| lang=php         | flaws (mean diff) | baseline-review - baseline          |     -0.222 |         |         |        7 |     14 |       0 |       7 |      21 |
| lang=php         | success (pp)      | optional - baseline                 |      0.926 |  -1.852 |   3.727 |        2 |     33 |       1 |      12 |      36 |
| lang=php         | cost ratio        | optional / baseline                 |      0.996 |   0.9   |   1.082 |       14 |      0 |      22 |      12 |      36 |
| lang=php         | flaws (mean diff) | optional - baseline                 |     -0.151 |         |         |        5 |     16 |       0 |       7 |      21 |
| lang=php         | success (pp)      | enforced - baseline                 |     -1.852 |  -5.556 |   1.852 |        2 |     31 |       3 |      12 |      36 |
| lang=php         | cost ratio        | enforced / baseline                 |      1.657 |   1.359 |   2.066 |        4 |      0 |      32 |      12 |      36 |
| lang=php         | flaws (mean diff) | enforced - baseline                 |     -0.024 |         |         |        4 |     14 |       3 |       7 |      21 |
| lang=php         | success (pp)      | optional - baseline-review          |     -0.926 |  -2.778 |   0     |        0 |     35 |       1 |      12 |      36 |
| lang=php         | cost ratio        | optional / baseline-review          |      0.444 |   0.412 |   0.483 |       36 |      0 |       0 |      12 |      36 |
| lang=php         | flaws (mean diff) | optional - baseline-review          |      0.071 |         |         |        0 |     19 |       2 |       7 |      21 |
| lang=php         | success (pp)      | enforced - baseline-review          |     -3.704 |  -7.87  |   0     |        0 |     33 |       3 |      12 |      36 |
| lang=php         | cost ratio        | enforced / baseline-review          |      0.74  |   0.632 |   0.871 |       28 |      0 |       8 |      12 |      36 |
| lang=php         | flaws (mean diff) | enforced - baseline-review          |      0.198 |         |         |        0 |     16 |       5 |       7 |      21 |
| lang=python      | success (pp)      | baseline-review - baseline          |     -1.852 |  -9.722 |   4.167 |        2 |     32 |       2 |      12 |      36 |
| lang=python      | cost ratio        | baseline-review / baseline          |      2.681 |   2.29  |   3.217 |        0 |      0 |      36 |      12 |      36 |
| lang=python      | flaws (mean diff) | baseline-review - baseline          |     -0.049 |         |         |        4 |     16 |       4 |       8 |      24 |
| lang=python      | success (pp)      | optional - baseline                 |     -4.167 |  -8.333 |  -0.926 |        2 |     30 |       4 |      12 |      36 |
| lang=python      | cost ratio        | optional / baseline                 |      1.067 |   0.996 |   1.15  |       13 |      0 |      23 |      12 |      36 |
| lang=python      | flaws (mean diff) | optional - baseline                 |     -0.139 |         |         |        6 |     15 |       3 |       8 |      24 |
| lang=python      | success (pp)      | enforced - baseline                 |     -7.87  | -19     |   0     |        1 |     28 |       7 |      12 |      36 |
| lang=python      | cost ratio        | enforced / baseline                 |      2.067 |   1.821 |   2.355 |        1 |      0 |      35 |      12 |      36 |
| lang=python      | flaws (mean diff) | enforced - baseline                 |     -0.049 |         |         |        5 |     15 |       4 |       8 |      24 |
| lang=python      | success (pp)      | optional - baseline-review          |     -2.315 |  -7.407 |   2.778 |        2 |     31 |       3 |      12 |      36 |
| lang=python      | cost ratio        | optional / baseline-review          |      0.398 |   0.354 |   0.446 |       36 |      0 |       0 |      12 |      36 |
| lang=python      | flaws (mean diff) | optional - baseline-review          |     -0.09  |         |         |        4 |     18 |       2 |       8 |      24 |
| lang=python      | success (pp)      | enforced - baseline-review          |     -6.019 | -12     |   0     |        1 |     29 |       6 |      12 |      36 |
| lang=python      | cost ratio        | enforced / baseline-review          |      0.771 |   0.685 |   0.872 |       26 |      0 |      10 |      12 |      36 |
| lang=python      | flaws (mean diff) | enforced - baseline-review          |     -0     |         |         |        4 |     15 |       5 |       8 |      24 |
| lang=shell       | success (pp)      | baseline-review - baseline          |      0     |         |         |        0 |     18 |       0 |       6 |      18 |
| lang=shell       | cost ratio        | baseline-review / baseline          |      2.281 |         |         |        0 |      0 |      18 |       6 |      18 |
| lang=shell       | flaws (mean diff) | baseline-review - baseline          |      0.028 |         |         |        0 |     11 |       1 |       4 |      12 |
| lang=shell       | success (pp)      | optional - baseline                 |      5.556 |         |         |        1 |     17 |       0 |       6 |      18 |
| lang=shell       | cost ratio        | optional / baseline                 |      1.017 |         |         |       10 |      0 |       8 |       6 |      18 |
| lang=shell       | flaws (mean diff) | optional - baseline                 |      0.111 |         |         |        0 |     10 |       2 |       4 |      12 |
| lang=shell       | success (pp)      | enforced - baseline                 |      3.704 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=shell       | cost ratio        | enforced / baseline                 |      1.394 |         |         |        4 |      0 |      14 |       6 |      18 |
| lang=shell       | flaws (mean diff) | enforced - baseline                 |      0.139 |         |         |        0 |     10 |       2 |       4 |      12 |
| lang=shell       | success (pp)      | optional - baseline-review          |      5.556 |         |         |        1 |     17 |       0 |       6 |      18 |
| lang=shell       | cost ratio        | optional / baseline-review          |      0.446 |         |         |       18 |      0 |       0 |       6 |      18 |
| lang=shell       | flaws (mean diff) | optional - baseline-review          |      0.083 |         |         |        0 |     11 |       1 |       4 |      12 |
| lang=shell       | success (pp)      | enforced - baseline-review          |      3.704 |         |         |        1 |     16 |       1 |       6 |      18 |
| lang=shell       | cost ratio        | enforced / baseline-review          |      0.611 |         |         |       17 |      0 |       1 |       6 |      18 |
| lang=shell       | flaws (mean diff) | enforced - baseline-review          |      0.111 |         |         |        1 |      9 |       2 |       4 |      12 |
| lang=typescript  | success (pp)      | baseline-review - baseline          |     -0.617 |         |         |        1 |     25 |       1 |       9 |      27 |
| lang=typescript  | cost ratio        | baseline-review / baseline          |      2.327 |         |         |        0 |      0 |      27 |       9 |      27 |
| lang=typescript  | flaws (mean diff) | baseline-review - baseline          |     -0.102 |         |         |        3 |     14 |       1 |       6 |      18 |
| lang=typescript  | success (pp)      | optional - baseline                 |      1.235 |         |         |        1 |     26 |       0 |       9 |      27 |
| lang=typescript  | cost ratio        | optional / baseline                 |      1.072 |         |         |        9 |      0 |      18 |       9 |      27 |
| lang=typescript  | flaws (mean diff) | optional - baseline                 |     -0.13  |         |         |        3 |     15 |       0 |       6 |      18 |
| lang=typescript  | success (pp)      | enforced - baseline                 |     -1.235 |         |         |        1 |     24 |       2 |       9 |      27 |
| lang=typescript  | cost ratio        | enforced / baseline                 |      1.546 |         |         |        3 |      0 |      24 |       9 |      27 |
| lang=typescript  | flaws (mean diff) | enforced - baseline                 |     -0.111 |         |         |        3 |     15 |       0 |       6 |      18 |
| lang=typescript  | success (pp)      | optional - baseline-review          |      1.852 |         |         |        1 |     26 |       0 |       9 |      27 |
| lang=typescript  | cost ratio        | optional / baseline-review          |      0.461 |         |         |       27 |      0 |       0 |       9 |      27 |
| lang=typescript  | flaws (mean diff) | optional - baseline-review          |     -0.028 |         |         |        2 |     14 |       2 |       6 |      18 |
| lang=typescript  | success (pp)      | enforced - baseline-review          |     -0.617 |         |         |        1 |     24 |       2 |       9 |      27 |
| lang=typescript  | cost ratio        | enforced / baseline-review          |      0.664 |         |         |       24 |      0 |       3 |       9 |      27 |
| lang=typescript  | flaws (mean diff) | enforced - baseline-review          |     -0.009 |         |         |        2 |     15 |       1 |       6 |      18 |


### By size

| stratum     | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| size=large  | success (pp)      | baseline-review - baseline          |     -3.086 |  -8.032 |   0     |        1 |     50 |       3 |      18 |      54 |
| size=large  | cost ratio        | baseline-review / baseline          |      2.33  |   2.083 |   2.664 |        2 |      0 |      52 |      18 |      54 |
| size=large  | flaws (mean diff) | baseline-review - baseline          |     -0.056 |  -0.162 |   0.046 |       10 |     23 |       3 |      12 |      36 |
| size=large  | success (pp)      | optional - baseline                 |     -2.222 |  -5.926 |   0     |        1 |     42 |       2 |      15 |      45 |
| size=large  | cost ratio        | optional / baseline                 |      1.059 |   1.008 |   1.121 |       16 |      0 |      29 |      15 |      45 |
| size=large  | flaws (mean diff) | optional - baseline                 |      0.033 |  -0.122 |   0.189 |        7 |     16 |       7 |      10 |      30 |
| size=large  | success (pp)      | enforced - baseline                 |     -5.556 | -14.4   |   0     |        0 |     40 |       5 |      15 |      45 |
| size=large  | cost ratio        | enforced / baseline                 |      1.553 |   1.27  |   1.919 |        9 |      0 |      36 |      15 |      45 |
| size=large  | flaws (mean diff) | enforced - baseline                 |      0.05  |  -0.083 |   0.194 |        6 |     19 |       5 |      10 |      30 |
| size=large  | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |     18 |       0 |       6 |      18 |
| size=large  | cost ratio        | intellij-optional / baseline        |      0.947 |         |         |       10 |      0 |       8 |       6 |      18 |
| size=large  | flaws (mean diff) | intellij-optional - baseline        |      0.014 |         |         |        3 |      8 |       1 |       4 |      12 |
| size=large  | success (pp)      | intellij-enforced - baseline        |     -1.852 |         |         |        0 |     17 |       1 |       6 |      18 |
| size=large  | cost ratio        | intellij-enforced / baseline        |      1.767 |         |         |        3 |      0 |      15 |       6 |      18 |
| size=large  | flaws (mean diff) | intellij-enforced - baseline        |     -0.028 |         |         |        3 |      7 |       2 |       4 |      12 |
| size=large  | success (pp)      | optional - baseline-review          |      1.481 |  -1.481 |   4.815 |        2 |     42 |       1 |      15 |      45 |
| size=large  | cost ratio        | optional / baseline-review          |      0.452 |   0.408 |   0.499 |       45 |      0 |       0 |      15 |      45 |
| size=large  | flaws (mean diff) | optional - baseline-review          |      0.072 |  -0.056 |   0.2   |        5 |     17 |       8 |      10 |      30 |
| size=large  | success (pp)      | enforced - baseline-review          |     -1.852 |  -5.926 |   2.222 |        1 |     41 |       3 |      15 |      45 |
| size=large  | cost ratio        | enforced / baseline-review          |      0.663 |   0.575 |   0.773 |       39 |      0 |       6 |      15 |      45 |
| size=large  | flaws (mean diff) | enforced - baseline-review          |      0.089 |  -0.033 |   0.222 |        5 |     18 |       7 |      10 |      30 |
| size=large  | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |     18 |       0 |       6 |      18 |
| size=large  | cost ratio        | intellij-optional / baseline-review |      0.439 |         |         |       18 |      0 |       0 |       6 |      18 |
| size=large  | flaws (mean diff) | intellij-optional - baseline-review |      0.056 |         |         |        1 |      7 |       4 |       4 |      12 |
| size=large  | success (pp)      | intellij-enforced - baseline-review |     -1.852 |         |         |        0 |     17 |       1 |       6 |      18 |
| size=large  | cost ratio        | intellij-enforced / baseline-review |      0.82  |         |         |       11 |      0 |       7 |       6 |      18 |
| size=large  | flaws (mean diff) | intellij-enforced - baseline-review |      0.014 |         |         |        1 |      7 |       4 |       4 |      12 |
| size=large  | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      9 |       0 |       3 |       9 |
| size=large  | cost ratio        | intellij-optional / optional        |      0.915 |         |         |        4 |      0 |       5 |       3 |       9 |
| size=large  | flaws (mean diff) | intellij-optional - optional        |     -0.278 |         |         |        3 |      2 |       1 |       2 |       6 |
| size=large  | success (pp)      | intellij-enforced - enforced        |     -3.704 |         |         |        0 |      8 |       1 |       3 |       9 |
| size=large  | cost ratio        | intellij-enforced / enforced        |      1.17  |         |         |        3 |      0 |       6 |       3 |       9 |
| size=large  | flaws (mean diff) | intellij-enforced - enforced        |     -0.278 |         |         |        2 |      2 |       2 |       2 |       6 |
| size=medium | success (pp)      | baseline-review - baseline          |      1.296 |  -4.259 |   6.667 |        8 |     78 |       4 |      30 |      90 |
| size=medium | cost ratio        | baseline-review / baseline          |      2.3   |   2.116 |   2.496 |        1 |      0 |      89 |      30 |      90 |
| size=medium | flaws (mean diff) | baseline-review - baseline          |      0.003 |  -0.092 |   0.094 |        7 |     44 |       9 |      20 |      60 |
| size=medium | success (pp)      | optional - baseline                 |      2.881 |  -2.469 |   9.053 |        8 |     68 |       5 |      27 |      81 |
| size=medium | cost ratio        | optional / baseline                 |      1.033 |   0.942 |   1.11  |       28 |      0 |      53 |      27 |      81 |
| size=medium | flaws (mean diff) | optional - baseline                 |     -0.003 |  -0.096 |   0.096 |        5 |     42 |       6 |      18 |      53 |
| size=medium | success (pp)      | enforced - baseline                 |      1.646 |  -4.115 |   7.407 |        8 |     65 |       8 |      27 |      81 |
| size=medium | cost ratio        | enforced / baseline                 |      1.579 |   1.353 |   1.832 |       11 |      0 |      70 |      27 |      81 |
| size=medium | flaws (mean diff) | enforced - baseline                 |      0.08  |  -0.048 |   0.21  |        5 |     36 |      11 |      18 |      52 |
| size=medium | success (pp)      | intellij-optional - baseline        |      5.556 |         |         |        5 |     21 |       1 |       9 |      27 |
| size=medium | cost ratio        | intellij-optional / baseline        |      1.046 |         |         |        8 |      0 |      19 |       9 |      27 |
| size=medium | flaws (mean diff) | intellij-optional - baseline        |      0.093 |         |         |        0 |     14 |       4 |       6 |      18 |
| size=medium | success (pp)      | intellij-enforced - baseline        |      3.704 |         |         |        2 |     23 |       2 |       9 |      27 |
| size=medium | cost ratio        | intellij-enforced / baseline        |      1.784 |         |         |        4 |      0 |      23 |       9 |      27 |
| size=medium | flaws (mean diff) | intellij-enforced - baseline        |      0.13  |         |         |        0 |     14 |       4 |       6 |      18 |
| size=medium | success (pp)      | optional - baseline-review          |      1.852 |  -4.733 |   9.465 |        5 |     72 |       4 |      27 |      81 |
| size=medium | cost ratio        | optional / baseline-review          |      0.457 |   0.438 |   0.479 |       80 |      0 |       1 |      27 |      81 |
| size=medium | flaws (mean diff) | optional - baseline-review          |      0.009 |  -0.052 |   0.069 |        4 |     44 |       5 |      18 |      53 |
| size=medium | success (pp)      | enforced - baseline-review          |      0.617 |  -4.938 |   7.202 |        6 |     67 |       8 |      27 |      81 |
| size=medium | cost ratio        | enforced / baseline-review          |      0.699 |   0.622 |   0.79  |       65 |      0 |      16 |      27 |      81 |
| size=medium | flaws (mean diff) | enforced - baseline-review          |      0.093 |   0.025 |   0.17  |        4 |     40 |       8 |      18 |      52 |
| size=medium | success (pp)      | intellij-optional - baseline-review |      1.235 |         |         |        2 |     23 |       2 |       9 |      27 |
| size=medium | cost ratio        | intellij-optional / baseline-review |      0.434 |         |         |       27 |      0 |       0 |       9 |      27 |
| size=medium | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        2 |     13 |       3 |       6 |      18 |
| size=medium | success (pp)      | intellij-enforced - baseline-review |     -0.617 |         |         |        2 |     21 |       4 |       9 |      27 |
| size=medium | cost ratio        | intellij-enforced / baseline-review |      0.741 |         |         |       22 |      0 |       5 |       9 |      27 |
| size=medium | flaws (mean diff) | intellij-enforced - baseline-review |      0.037 |         |         |        3 |     12 |       3 |       6 |      18 |
| size=medium | success (pp)      | intellij-optional - optional        |     -7.407 |         |         |        1 |     14 |       3 |       6 |      18 |
| size=medium | cost ratio        | intellij-optional / optional        |      1.003 |         |         |        6 |      0 |      12 |       6 |      18 |
| size=medium | flaws (mean diff) | intellij-optional - optional        |      0.083 |         |         |        0 |     10 |       2 |       4 |      12 |
| size=medium | success (pp)      | intellij-enforced - enforced        |     -0     |         |         |        1 |     16 |       1 |       6 |      18 |
| size=medium | cost ratio        | intellij-enforced / enforced        |      1.145 |         |         |        7 |      0 |      11 |       6 |      18 |
| size=medium | flaws (mean diff) | intellij-enforced - enforced        |     -0.056 |         |         |        3 |      8 |       1 |       4 |      12 |
| size=small  | success (pp)      | baseline-review - baseline          |      0.206 |  -1.235 |   1.646 |        4 |     74 |       3 |      27 |      81 |
| size=small  | cost ratio        | baseline-review / baseline          |      2.374 |   2.27  |   2.484 |        0 |      0 |      81 |      27 |      81 |
| size=small  | flaws (mean diff) | baseline-review - baseline          |     -0.043 |  -0.16  |   0.065 |       10 |     37 |       7 |      18 |      54 |
| size=small  | success (pp)      | optional - baseline                 |     -2.546 |  -5.33  |   0     |        2 |     65 |       5 |      24 |      72 |
| size=small  | cost ratio        | optional / baseline                 |      1.002 |   0.949 |   1.062 |       30 |      0 |      42 |      24 |      72 |
| size=small  | flaws (mean diff) | optional - baseline                 |     -0.038 |  -0.132 |   0.073 |        7 |     38 |       3 |      16 |      48 |
| size=small  | success (pp)      | enforced - baseline                 |     -4.63  |  -9.491 |  -1.157 |        3 |     60 |       9 |      24 |      72 |
| size=small  | cost ratio        | enforced / baseline                 |      1.558 |   1.384 |   1.742 |        7 |      0 |      65 |      24 |      72 |
| size=small  | flaws (mean diff) | enforced - baseline                 |      0.139 |   0.007 |   0.312 |        6 |     30 |      12 |      16 |      48 |
| size=small  | success (pp)      | intellij-optional - baseline        |     -4.63  |         |         |        1 |     14 |       3 |       6 |      18 |
| size=small  | cost ratio        | intellij-optional / baseline        |      1.024 |         |         |        6 |      0 |      12 |       6 |      18 |
| size=small  | flaws (mean diff) | intellij-optional - baseline        |      0.083 |         |         |        1 |      7 |       4 |       4 |      12 |
| size=small  | success (pp)      | intellij-enforced - baseline        |     -6.481 |         |         |        3 |     12 |       3 |       6 |      18 |
| size=small  | cost ratio        | intellij-enforced / baseline        |      1.512 |         |         |        2 |      0 |      16 |       6 |      18 |
| size=small  | flaws (mean diff) | intellij-enforced - baseline        |      0.125 |         |         |        0 |      9 |       3 |       4 |      12 |
| size=small  | success (pp)      | optional - baseline-review          |     -3.241 |  -6.25  |  -0.926 |        0 |     66 |       6 |      24 |      72 |
| size=small  | cost ratio        | optional / baseline-review          |      0.424 |   0.397 |   0.45  |       72 |      0 |       0 |      24 |      72 |
| size=small  | flaws (mean diff) | optional - baseline-review          |      0.017 |  -0.049 |   0.083 |        5 |     38 |       5 |      16 |      48 |
| size=small  | success (pp)      | enforced - baseline-review          |     -5.324 |  -9.722 |  -1.389 |        1 |     61 |      10 |      24 |      72 |
| size=small  | cost ratio        | enforced / baseline-review          |      0.66  |   0.594 |   0.732 |       62 |      0 |      10 |      24 |      72 |
| size=small  | flaws (mean diff) | enforced - baseline-review          |      0.194 |   0.017 |   0.424 |        5 |     29 |      14 |      16 |      48 |
| size=small  | success (pp)      | intellij-optional - baseline-review |     -4.63  |         |         |        1 |     15 |       2 |       6 |      18 |
| size=small  | cost ratio        | intellij-optional / baseline-review |      0.414 |         |         |       18 |      0 |       0 |       6 |      18 |
| size=small  | flaws (mean diff) | intellij-optional - baseline-review |     -0.069 |         |         |        2 |      8 |       2 |       4 |      12 |
| size=small  | success (pp)      | intellij-enforced - baseline-review |     -6.481 |         |         |        2 |     13 |       3 |       6 |      18 |
| size=small  | cost ratio        | intellij-enforced / baseline-review |      0.611 |         |         |       16 |      0 |       2 |       6 |      18 |
| size=small  | flaws (mean diff) | intellij-enforced - baseline-review |     -0.028 |         |         |        2 |      8 |       2 |       4 |      12 |
| size=small  | success (pp)      | intellij-optional - optional        |      1.852 |         |         |        1 |      7 |       1 |       3 |       9 |
| size=small  | cost ratio        | intellij-optional / optional        |      0.987 |         |         |        2 |      0 |       7 |       3 |       9 |
| size=small  | flaws (mean diff) | intellij-optional - optional        |     -0.139 |         |         |        2 |      4 |       0 |       2 |       6 |
| size=small  | success (pp)      | intellij-enforced - enforced        |     -7.407 |         |         |        1 |      7 |       1 |       3 |       9 |
| size=small  | cost ratio        | intellij-enforced / enforced        |      0.97  |         |         |        3 |      0 |       6 |       3 |       9 |
| size=small  | flaws (mean diff) | intellij-enforced - enforced        |      0.056 |         |         |        0 |      5 |       1 |       2 |       6 |
| size=xlarge | success (pp)      | baseline-review - baseline          |      0.463 |  -5.556 |   6.944 |        3 |     31 |       2 |      12 |      36 |
| size=xlarge | cost ratio        | baseline-review / baseline          |      2.38  |   2.167 |   2.69  |        0 |      0 |      36 |      12 |      36 |
| size=xlarge | flaws (mean diff) | baseline-review - baseline          |     -0.102 |         |         |        5 |     10 |       3 |       6 |      18 |
| size=xlarge | success (pp)      | optional - baseline                 |      4.321 |         |         |        3 |     24 |       0 |       9 |      27 |
| size=xlarge | cost ratio        | optional / baseline                 |      0.967 |         |         |       13 |      0 |      14 |       9 |      27 |
| size=xlarge | flaws (mean diff) | optional - baseline                 |     -0.292 |         |         |        4 |      7 |       1 |       4 |      12 |
| size=xlarge | success (pp)      | enforced - baseline                 |      0     |         |         |        2 |     23 |       2 |       9 |      27 |
| size=xlarge | cost ratio        | enforced / baseline                 |      1.6   |         |         |        5 |      0 |      22 |       9 |      27 |
| size=xlarge | flaws (mean diff) | enforced - baseline                 |     -0.278 |         |         |        4 |      7 |       1 |       4 |      12 |
| size=xlarge | success (pp)      | intellij-optional - baseline        |     -7.407 |         |         |        0 |      8 |       1 |       3 |       9 |
| size=xlarge | cost ratio        | intellij-optional / baseline        |      1.015 |         |         |        5 |      0 |       4 |       3 |       9 |
| size=xlarge | flaws (mean diff) | intellij-optional - baseline        |     -0.056 |         |         |        1 |      5 |       0 |       2 |       6 |
| size=xlarge | success (pp)      | intellij-enforced - baseline        |     14.8   |         |         |        2 |      7 |       0 |       3 |       9 |
| size=xlarge | cost ratio        | intellij-enforced / baseline        |      1.453 |         |         |        2 |      0 |       7 |       3 |       9 |
| size=xlarge | flaws (mean diff) | intellij-enforced - baseline        |      0.389 |         |         |        0 |      4 |       2 |       2 |       6 |
| size=xlarge | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     27 |       0 |       9 |      27 |
| size=xlarge | cost ratio        | optional / baseline-review          |      0.407 |         |         |       27 |      0 |       0 |       9 |      27 |
| size=xlarge | flaws (mean diff) | optional - baseline-review          |     -0.083 |         |         |        2 |      9 |       1 |       4 |      12 |
| size=xlarge | success (pp)      | enforced - baseline-review          |     -4.321 |         |         |        0 |     25 |       2 |       9 |      27 |
| size=xlarge | cost ratio        | enforced / baseline-review          |      0.674 |         |         |       22 |      0 |       5 |       9 |      27 |
| size=xlarge | flaws (mean diff) | enforced - baseline-review          |     -0.069 |         |         |        2 |      8 |       2 |       4 |      12 |
| size=xlarge | success (pp)      | intellij-optional - baseline-review |      3.704 |         |         |        1 |      8 |       0 |       3 |       9 |
| size=xlarge | cost ratio        | intellij-optional / baseline-review |      0.424 |         |         |        9 |      0 |       0 |       3 |       9 |
| size=xlarge | flaws (mean diff) | intellij-optional - baseline-review |     -0.167 |         |         |        1 |      5 |       0 |       2 |       6 |
| size=xlarge | success (pp)      | intellij-enforced - baseline-review |     25.9   |         |         |        3 |      6 |       0 |       3 |       9 |
| size=xlarge | cost ratio        | intellij-enforced / baseline-review |      0.606 |         |         |        8 |      0 |       1 |       3 |       9 |
| size=xlarge | flaws (mean diff) | intellij-enforced - baseline-review |      0.278 |         |         |        1 |      3 |       2 |       2 |       6 |


### By task_type

| stratum               | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:----------------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| task_type=callers     | success (pp)      | baseline-review - baseline          |      6.667 |         |         |        2 |     12 |       1 |       5 |      15 |
| task_type=callers     | cost ratio        | baseline-review / baseline          |      2.128 |         |         |        0 |      0 |      15 |       5 |      15 |
| task_type=callers     | success (pp)      | optional - baseline                 |     -1.389 |         |         |        1 |     10 |       1 |       4 |      12 |
| task_type=callers     | cost ratio        | optional / baseline                 |      1.019 |         |         |        6 |      0 |       6 |       4 |      12 |
| task_type=callers     | success (pp)      | enforced - baseline                 |      6.944 |         |         |        2 |      9 |       1 |       4 |      12 |
| task_type=callers     | cost ratio        | enforced / baseline                 |      1.813 |         |         |        1 |      0 |      11 |       4 |      12 |
| task_type=callers     | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=callers     | cost ratio        | intellij-optional / baseline        |      1.017 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=callers     | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=callers     | cost ratio        | intellij-enforced / baseline        |      0.831 |         |         |        2 |      0 |       1 |       1 |       3 |
| task_type=callers     | success (pp)      | optional - baseline-review          |    -12.5   |         |         |        0 |     10 |       2 |       4 |      12 |
| task_type=callers     | cost ratio        | optional / baseline-review          |      0.482 |         |         |       12 |      0 |       0 |       4 |      12 |
| task_type=callers     | success (pp)      | enforced - baseline-review          |     -4.167 |         |         |        0 |     11 |       1 |       4 |      12 |
| task_type=callers     | cost ratio        | enforced / baseline-review          |      0.858 |         |         |        8 |      0 |       4 |       4 |      12 |
| task_type=callers     | success (pp)      | intellij-optional - baseline-review |     11.1   |         |         |        1 |      2 |       0 |       1 |       3 |
| task_type=callers     | cost ratio        | intellij-optional / baseline-review |      0.464 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=callers     | success (pp)      | intellij-enforced - baseline-review |     11.1   |         |         |        1 |      2 |       0 |       1 |       3 |
| task_type=callers     | cost ratio        | intellij-enforced / baseline-review |      0.379 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=dispatch    | success (pp)      | baseline-review - baseline          |     -6.481 |         |         |        1 |     15 |       2 |       6 |      18 |
| task_type=dispatch    | cost ratio        | baseline-review / baseline          |      2.431 |         |         |        0 |      0 |      18 |       6 |      18 |
| task_type=dispatch    | success (pp)      | optional - baseline                 |     -3.704 |         |         |        1 |     16 |       1 |       6 |      18 |
| task_type=dispatch    | cost ratio        | optional / baseline                 |      1.059 |         |         |        5 |      0 |      13 |       6 |      18 |
| task_type=dispatch    | success (pp)      | enforced - baseline                 |    -12     |         |         |        0 |     14 |       4 |       6 |      18 |
| task_type=dispatch    | cost ratio        | enforced / baseline                 |      1.665 |         |         |        1 |      0 |      17 |       6 |      18 |
| task_type=dispatch    | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-optional / baseline        |      1.112 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=dispatch    | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-enforced / baseline        |      2.029 |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=dispatch    | success (pp)      | optional - baseline-review          |      2.778 |         |         |        1 |     17 |       0 |       6 |      18 |
| task_type=dispatch    | cost ratio        | optional / baseline-review          |      0.436 |         |         |       17 |      0 |       1 |       6 |      18 |
| task_type=dispatch    | success (pp)      | enforced - baseline-review          |     -5.556 |         |         |        0 |     16 |       2 |       6 |      18 |
| task_type=dispatch    | cost ratio        | enforced / baseline-review          |      0.685 |         |         |       15 |      0 |       3 |       6 |      18 |
| task_type=dispatch    | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-optional / baseline-review |      0.376 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=dispatch    | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-enforced / baseline-review |      0.687 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=dispatch    | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-optional / optional        |      1.112 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=dispatch    | success (pp)      | intellij-enforced - enforced        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=dispatch    | cost ratio        | intellij-enforced / enforced        |      1.148 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=impls       | success (pp)      | baseline-review - baseline          |      7.407 |         |         |        2 |     16 |       0 |       6 |      18 |
| task_type=impls       | cost ratio        | baseline-review / baseline          |      1.992 |         |         |        0 |      0 |      18 |       6 |      18 |
| task_type=impls       | success (pp)      | optional - baseline                 |      6.667 |         |         |        1 |     14 |       0 |       5 |      15 |
| task_type=impls       | cost ratio        | optional / baseline                 |      1.006 |         |         |        6 |      0 |       9 |       5 |      15 |
| task_type=impls       | success (pp)      | enforced - baseline                 |      4.444 |         |         |        1 |     13 |       1 |       5 |      15 |
| task_type=impls       | cost ratio        | enforced / baseline                 |      1.474 |         |         |        2 |      0 |      13 |       5 |      15 |
| task_type=impls       | success (pp)      | intellij-optional - baseline        |      9.259 |         |         |        2 |      7 |       0 |       3 |       9 |
| task_type=impls       | cost ratio        | intellij-optional / baseline        |      1.006 |         |         |        4 |      0 |       5 |       3 |       9 |
| task_type=impls       | success (pp)      | intellij-enforced - baseline        |      7.407 |         |         |        1 |      7 |       1 |       3 |       9 |
| task_type=impls       | cost ratio        | intellij-enforced / baseline        |      1.795 |         |         |        1 |      0 |       8 |       3 |       9 |
| task_type=impls       | success (pp)      | optional - baseline-review          |     -2.222 |         |         |        0 |     14 |       1 |       5 |      15 |
| task_type=impls       | cost ratio        | optional / baseline-review          |      0.518 |         |         |       15 |      0 |       0 |       5 |      15 |
| task_type=impls       | success (pp)      | enforced - baseline-review          |     -4.444 |         |         |        0 |     14 |       1 |       5 |      15 |
| task_type=impls       | cost ratio        | enforced / baseline-review          |      0.759 |         |         |       11 |      0 |       4 |       5 |      15 |
| task_type=impls       | success (pp)      | intellij-optional - baseline-review |     -5.556 |         |         |        0 |      8 |       1 |       3 |       9 |
| task_type=impls       | cost ratio        | intellij-optional / baseline-review |      0.463 |         |         |        9 |      0 |       0 |       3 |       9 |
| task_type=impls       | success (pp)      | intellij-enforced - baseline-review |     -7.407 |         |         |        0 |      7 |       2 |       3 |       9 |
| task_type=impls       | cost ratio        | intellij-enforced / baseline-review |      0.827 |         |         |        6 |      0 |       3 |       3 |       9 |
| task_type=impls       | success (pp)      | intellij-optional - optional        |     -2.778 |         |         |        1 |      4 |       1 |       2 |       6 |
| task_type=impls       | cost ratio        | intellij-optional / optional        |      1.063 |         |         |        1 |      0 |       5 |       2 |       6 |
| task_type=impls       | success (pp)      | intellij-enforced - enforced        |     -0     |         |         |        1 |      4 |       1 |       2 |       6 |
| task_type=impls       | cost ratio        | intellij-enforced / enforced        |      1.413 |         |         |        2 |      0 |       4 |       2 |       6 |
| task_type=inspect     | success (pp)      | baseline-review - baseline          |      3.704 |         |         |        2 |     16 |       0 |       6 |      18 |
| task_type=inspect     | cost ratio        | baseline-review / baseline          |      2.021 |         |         |        1 |      0 |      17 |       6 |      18 |
| task_type=inspect     | success (pp)      | optional - baseline                 |      4.444 |         |         |        2 |     13 |       0 |       5 |      15 |
| task_type=inspect     | cost ratio        | optional / baseline                 |      0.994 |         |         |        7 |      0 |       8 |       5 |      15 |
| task_type=inspect     | success (pp)      | enforced - baseline                 |     -4.444 |         |         |        2 |     10 |       3 |       5 |      15 |
| task_type=inspect     | cost ratio        | enforced / baseline                 |      1.069 |         |         |        5 |      0 |      10 |       5 |      15 |
| task_type=inspect     | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=inspect     | cost ratio        | intellij-optional / baseline        |      1.065 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=inspect     | success (pp)      | intellij-enforced - baseline        |    -22.2   |         |         |        0 |      2 |       1 |       1 |       3 |
| task_type=inspect     | cost ratio        | intellij-enforced / baseline        |      1.794 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=inspect     | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     15 |       0 |       5 |      15 |
| task_type=inspect     | cost ratio        | optional / baseline-review          |      0.493 |         |         |       15 |      0 |       0 |       5 |      15 |
| task_type=inspect     | success (pp)      | enforced - baseline-review          |     -8.889 |         |         |        0 |     12 |       3 |       5 |      15 |
| task_type=inspect     | cost ratio        | enforced / baseline-review          |      0.53  |         |         |       15 |      0 |       0 |       5 |      15 |
| task_type=inspect     | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=inspect     | cost ratio        | intellij-optional / baseline-review |      0.522 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=inspect     | success (pp)      | intellij-enforced - baseline-review |    -22.2   |         |         |        0 |      2 |       1 |       1 |       3 |
| task_type=inspect     | cost ratio        | intellij-enforced / baseline-review |      0.878 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=move        | success (pp)      | baseline-review - baseline          |     -2.083 |         |         |        0 |     23 |       1 |       8 |      24 |
| task_type=move        | cost ratio        | baseline-review / baseline          |      2.464 |         |         |        0 |      0 |      24 |       8 |      24 |
| task_type=move        | flaws (mean diff) | baseline-review - baseline          |     -0.035 |         |         |        2 |     22 |       0 |       8 |      24 |
| task_type=move        | success (pp)      | optional - baseline                 |      7.143 |         |         |        2 |     18 |       1 |       7 |      21 |
| task_type=move        | cost ratio        | optional / baseline                 |      1.069 |         |         |        7 |      0 |      14 |       7 |      21 |
| task_type=move        | flaws (mean diff) | optional - baseline                 |     -0.016 |         |         |        2 |     18 |       1 |       7 |      21 |
| task_type=move        | success (pp)      | enforced - baseline                 |      3.968 |         |         |        2 |     17 |       2 |       7 |      21 |
| task_type=move        | cost ratio        | enforced / baseline                 |      1.69  |         |         |        3 |      0 |      18 |       7 |      21 |
| task_type=move        | flaws (mean diff) | enforced - baseline                 |     -0.04  |         |         |        2 |     19 |       0 |       7 |      21 |
| task_type=move        | success (pp)      | intellij-optional - baseline        |      5.556 |         |         |        2 |      3 |       1 |       2 |       6 |
| task_type=move        | cost ratio        | intellij-optional / baseline        |      1.093 |         |         |        2 |      0 |       4 |       2 |       6 |
| task_type=move        | flaws (mean diff) | intellij-optional - baseline        |      0.056 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=move        | success (pp)      | intellij-enforced - baseline        |     22.2   |         |         |        2 |      4 |       0 |       2 |       6 |
| task_type=move        | cost ratio        | intellij-enforced / baseline        |      1.569 |         |         |        1 |      0 |       5 |       2 |       6 |
| task_type=move        | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=move        | success (pp)      | optional - baseline-review          |      9.524 |         |         |        2 |     19 |       0 |       7 |      21 |
| task_type=move        | cost ratio        | optional / baseline-review          |      0.434 |         |         |       21 |      0 |       0 |       7 |      21 |
| task_type=move        | flaws (mean diff) | optional - baseline-review          |      0.024 |         |         |        0 |     20 |       1 |       7 |      21 |
| task_type=move        | success (pp)      | enforced - baseline-review          |      6.349 |         |         |        3 |     16 |       2 |       7 |      21 |
| task_type=move        | cost ratio        | enforced / baseline-review          |      0.687 |         |         |       17 |      0 |       4 |       7 |      21 |
| task_type=move        | flaws (mean diff) | enforced - baseline-review          |      0     |         |         |        0 |     21 |       0 |       7 |      21 |
| task_type=move        | success (pp)      | intellij-optional - baseline-review |     13.9   |         |         |        2 |      3 |       1 |       2 |       6 |
| task_type=move        | cost ratio        | intellij-optional / baseline-review |      0.44  |         |         |        6 |      0 |       0 |       2 |       6 |
| task_type=move        | flaws (mean diff) | intellij-optional - baseline-review |      0.056 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=move        | success (pp)      | intellij-enforced - baseline-review |     30.6   |         |         |        3 |      3 |       0 |       2 |       6 |
| task_type=move        | cost ratio        | intellij-enforced / baseline-review |      0.631 |         |         |        6 |      0 |       0 |       2 |       6 |
| task_type=move        | flaws (mean diff) | intellij-enforced - baseline-review |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=move        | success (pp)      | intellij-optional - optional        |    -38.9   |         |         |        0 |      1 |       2 |       1 |       3 |
| task_type=move        | cost ratio        | intellij-optional / optional        |      0.997 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=move        | flaws (mean diff) | intellij-optional - optional        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=move        | success (pp)      | intellij-enforced - enforced        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=move        | cost ratio        | intellij-enforced / enforced        |      1.562 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=move        | flaws (mean diff) | intellij-enforced - enforced        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=pr          | success (pp)      | baseline-review - baseline          |      0     |  -3.448 |   2.682 |        6 |     77 |       4 |      29 |      87 |
| task_type=pr          | cost ratio        | baseline-review / baseline          |      2.27  |   2.106 |   2.431 |        1 |      0 |      86 |      29 |      87 |
| task_type=pr          | flaws (mean diff) | baseline-review - baseline          |      0.008 |  -0.079 |   0.092 |       16 |     56 |      15 |      29 |      87 |
| task_type=pr          | success (pp)      | optional - baseline                 |     -2.444 |  -6.667 |   2.222 |        4 |     64 |       7 |      25 |      75 |
| task_type=pr          | cost ratio        | optional / baseline                 |      0.979 |   0.888 |   1.066 |       29 |      0 |      46 |      25 |      75 |
| task_type=pr          | flaws (mean diff) | optional - baseline                 |      0.016 |  -0.075 |   0.11  |        9 |     56 |       9 |      25 |      74 |
| task_type=pr          | success (pp)      | enforced - baseline                 |     -4.222 |  -9.778 |   1.117 |        3 |     63 |       9 |      25 |      75 |
| task_type=pr          | cost ratio        | enforced / baseline                 |      1.358 |   1.194 |   1.52  |       13 |      0 |      62 |      25 |      75 |
| task_type=pr          | flaws (mean diff) | enforced - baseline                 |      0.146 |   0.038 |   0.278 |        9 |     45 |      19 |      25 |      73 |
| task_type=pr          | success (pp)      | intellij-optional - baseline        |      0     |         |         |        2 |     20 |       2 |       8 |      24 |
| task_type=pr          | cost ratio        | intellij-optional / baseline        |      0.963 |         |         |       12 |      0 |      12 |       8 |      24 |
| task_type=pr          | flaws (mean diff) | intellij-optional - baseline        |      0.09  |         |         |        4 |     13 |       7 |       8 |      24 |
| task_type=pr          | success (pp)      | intellij-enforced - baseline        |     -0.694 |         |         |        2 |     21 |       1 |       8 |      24 |
| task_type=pr          | cost ratio        | intellij-enforced / baseline        |      1.267 |         |         |        5 |      0 |      19 |       8 |      24 |
| task_type=pr          | flaws (mean diff) | intellij-enforced - baseline        |      0.09  |         |         |        3 |     14 |       7 |       8 |      24 |
| task_type=pr          | success (pp)      | optional - baseline-review          |     -2.444 |  -6.444 |   1.778 |        2 |     66 |       7 |      25 |      75 |
| task_type=pr          | cost ratio        | optional / baseline-review          |      0.436 |   0.414 |   0.46  |       75 |      0 |       0 |      25 |      75 |
| task_type=pr          | flaws (mean diff) | optional - baseline-review          |      0.014 |  -0.062 |   0.089 |       11 |     53 |      10 |      25 |      74 |
| task_type=pr          | success (pp)      | enforced - baseline-review          |     -4.222 |  -9.778 |   1.111 |        2 |     63 |      10 |      25 |      75 |
| task_type=pr          | cost ratio        | enforced / baseline-review          |      0.605 |   0.559 |   0.663 |       69 |      0 |       6 |      25 |      75 |
| task_type=pr          | flaws (mean diff) | enforced - baseline-review          |      0.144 |   0.011 |   0.312 |        9 |     46 |      18 |      25 |      73 |
| task_type=pr          | success (pp)      | intellij-optional - baseline-review |     -1.389 |         |         |        1 |     22 |       1 |       8 |      24 |
| task_type=pr          | cost ratio        | intellij-optional / baseline-review |      0.424 |         |         |       24 |      0 |       0 |       8 |      24 |
| task_type=pr          | flaws (mean diff) | intellij-optional - baseline-review |     -0.063 |         |         |        5 |     12 |       7 |       8 |      24 |
| task_type=pr          | success (pp)      | intellij-enforced - baseline-review |     -2.083 |         |         |        1 |     21 |       2 |       8 |      24 |
| task_type=pr          | cost ratio        | intellij-enforced / baseline-review |      0.558 |         |         |       24 |      0 |       0 |       8 |      24 |
| task_type=pr          | flaws (mean diff) | intellij-enforced - baseline-review |     -0.063 |         |         |        5 |     13 |       6 |       8 |      24 |
| task_type=pr          | success (pp)      | intellij-optional - optional        |      1.389 |         |         |        1 |     10 |       1 |       4 |      12 |
| task_type=pr          | cost ratio        | intellij-optional / optional        |      0.904 |         |         |        5 |      0 |       7 |       4 |      12 |
| task_type=pr          | flaws (mean diff) | intellij-optional - optional        |     -0.056 |         |         |        3 |      6 |       3 |       4 |      12 |
| task_type=pr          | success (pp)      | intellij-enforced - enforced        |      2.778 |         |         |        1 |     11 |       0 |       4 |      12 |
| task_type=pr          | cost ratio        | intellij-enforced / enforced        |      0.976 |         |         |        4 |      0 |       8 |       4 |      12 |
| task_type=pr          | flaws (mean diff) | intellij-enforced - enforced        |     -0.139 |         |         |        3 |      6 |       3 |       4 |      12 |
| task_type=refs        | success (pp)      | baseline-review - baseline          |      4.861 |         |         |        3 |     21 |       0 |       8 |      24 |
| task_type=refs        | cost ratio        | baseline-review / baseline          |      2.176 |         |         |        0 |      0 |      24 |       8 |      24 |
| task_type=refs        | success (pp)      | optional - baseline                 |      5.556 |         |         |        3 |     18 |       0 |       7 |      21 |
| task_type=refs        | cost ratio        | optional / baseline                 |      1.001 |         |         |       10 |      0 |      11 |       7 |      21 |
| task_type=refs        | success (pp)      | enforced - baseline                 |      2.381 |         |         |        3 |     16 |       2 |       7 |      21 |
| task_type=refs        | cost ratio        | enforced / baseline                 |      1.532 |         |         |        2 |      0 |      19 |       7 |      21 |
| task_type=refs        | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=refs        | cost ratio        | intellij-optional / baseline        |      1.098 |         |         |        2 |      0 |       4 |       2 |       6 |
| task_type=refs        | success (pp)      | intellij-enforced - baseline        |    -22.2   |         |         |        0 |      4 |       2 |       2 |       6 |
| task_type=refs        | cost ratio        | intellij-enforced / baseline        |      2.027 |         |         |        0 |      0 |       6 |       2 |       6 |
| task_type=refs        | success (pp)      | optional - baseline-review          |      0     |         |         |        0 |     21 |       0 |       7 |      21 |
| task_type=refs        | cost ratio        | optional / baseline-review          |      0.457 |         |         |       21 |      0 |       0 |       7 |      21 |
| task_type=refs        | success (pp)      | enforced - baseline-review          |     -3.175 |         |         |        0 |     19 |       2 |       7 |      21 |
| task_type=refs        | cost ratio        | enforced / baseline-review          |      0.7   |         |         |       18 |      0 |       3 |       7 |      21 |
| task_type=refs        | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=refs        | cost ratio        | intellij-optional / baseline-review |      0.52  |         |         |        6 |      0 |       0 |       2 |       6 |
| task_type=refs        | success (pp)      | intellij-enforced - baseline-review |    -22.2   |         |         |        0 |      4 |       2 |       2 |       6 |
| task_type=refs        | cost ratio        | intellij-enforced / baseline-review |      0.96  |         |         |        4 |      0 |       2 |       2 |       6 |
| task_type=refs        | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=refs        | cost ratio        | intellij-optional / optional        |      1.06  |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=refs        | success (pp)      | intellij-enforced - enforced        |    -33.3   |         |         |        0 |      2 |       1 |       1 |       3 |
| task_type=refs        | cost ratio        | intellij-enforced / enforced        |      1.071 |         |         |        2 |      0 |       1 |       1 |       3 |
| task_type=rename      | success (pp)      | baseline-review - baseline          |     -3.704 |         |         |        0 |     17 |       1 |       6 |      18 |
| task_type=rename      | cost ratio        | baseline-review / baseline          |      2.552 |         |         |        1 |      0 |      17 |       6 |      18 |
| task_type=rename      | flaws (mean diff) | baseline-review - baseline          |     -0.093 |         |         |        3 |     15 |       0 |       6 |      18 |
| task_type=rename      | success (pp)      | optional - baseline                 |     -3.333 |         |         |        0 |     14 |       1 |       5 |      15 |
| task_type=rename      | cost ratio        | optional / baseline                 |      1.058 |         |         |        4 |      0 |      11 |       5 |      15 |
| task_type=rename      | flaws (mean diff) | optional - baseline                 |     -0.044 |         |         |        2 |     12 |       1 |       5 |      15 |
| task_type=rename      | success (pp)      | enforced - baseline                 |      0     |         |         |        0 |     15 |       0 |       5 |      15 |
| task_type=rename      | cost ratio        | enforced / baseline                 |      2.78  |         |         |        1 |      0 |      14 |       5 |      15 |
| task_type=rename      | flaws (mean diff) | enforced - baseline                 |      0     |         |         |        2 |     10 |       3 |       5 |      15 |
| task_type=rename      | success (pp)      | intellij-optional - baseline        |    -13     |         |         |        0 |      7 |       2 |       3 |       9 |
| task_type=rename      | cost ratio        | intellij-optional / baseline        |      1.04  |         |         |        2 |      0 |       7 |       3 |       9 |
| task_type=rename      | flaws (mean diff) | intellij-optional - baseline        |     -0.037 |         |         |        1 |      8 |       0 |       3 |       9 |
| task_type=rename      | success (pp)      | intellij-enforced - baseline        |     14.8   |         |         |        2 |      7 |       0 |       3 |       9 |
| task_type=rename      | cost ratio        | intellij-enforced / baseline        |      2.079 |         |         |        1 |      0 |       8 |       3 |       9 |
| task_type=rename      | flaws (mean diff) | intellij-enforced - baseline        |      0.296 |         |         |        0 |      6 |       3 |       3 |       9 |
| task_type=rename      | success (pp)      | optional - baseline-review          |     -3.333 |         |         |        0 |     14 |       1 |       5 |      15 |
| task_type=rename      | cost ratio        | optional / baseline-review          |      0.418 |         |         |       15 |      0 |       0 |       5 |      15 |
| task_type=rename      | flaws (mean diff) | optional - baseline-review          |      0.044 |         |         |        1 |     13 |       1 |       5 |      15 |
| task_type=rename      | success (pp)      | enforced - baseline-review          |      0     |         |         |        0 |     15 |       0 |       5 |      15 |
| task_type=rename      | cost ratio        | enforced / baseline-review          |      1.098 |         |         |        7 |      0 |       8 |       5 |      15 |
| task_type=rename      | flaws (mean diff) | enforced - baseline-review          |      0.089 |         |         |        1 |     11 |       3 |       5 |      15 |
| task_type=rename      | success (pp)      | intellij-optional - baseline-review |     -5.556 |         |         |        0 |      8 |       1 |       3 |       9 |
| task_type=rename      | cost ratio        | intellij-optional / baseline-review |      0.391 |         |         |        9 |      0 |       0 |       3 |       9 |
| task_type=rename      | flaws (mean diff) | intellij-optional - baseline-review |      0     |         |         |        0 |      9 |       0 |       3 |       9 |
| task_type=rename      | success (pp)      | intellij-enforced - baseline-review |     22.2   |         |         |        2 |      7 |       0 |       3 |       9 |
| task_type=rename      | cost ratio        | intellij-enforced / baseline-review |      0.782 |         |         |        6 |      0 |       3 |       3 |       9 |
| task_type=rename      | flaws (mean diff) | intellij-enforced - baseline-review |      0.333 |         |         |        0 |      6 |       3 |       3 |       9 |
| task_type=rename      | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=rename      | cost ratio        | intellij-optional / optional        |      0.958 |         |         |        3 |      0 |       3 |       2 |       6 |
| task_type=rename      | flaws (mean diff) | intellij-optional - optional        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=rename      | success (pp)      | intellij-enforced - enforced        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=rename      | cost ratio        | intellij-enforced / enforced        |      0.804 |         |         |        3 |      0 |       3 |       2 |       6 |
| task_type=rename      | flaws (mean diff) | intellij-enforced - enforced        |     -0.056 |         |         |        1 |      5 |       0 |       2 |       6 |
| task_type=rename-file | success (pp)      | baseline-review - baseline          |     -4.167 |         |         |        0 |     23 |       1 |       8 |      24 |
| task_type=rename-file | cost ratio        | baseline-review / baseline          |      3.233 |         |         |        0 |      0 |      24 |       8 |      24 |
| task_type=rename-file | flaws (mean diff) | baseline-review - baseline          |     -0.069 |         |         |        7 |     10 |       7 |       8 |      24 |
| task_type=rename-file | success (pp)      | optional - baseline                 |      0     |         |         |        0 |     21 |       0 |       7 |      21 |
| task_type=rename-file | cost ratio        | optional / baseline                 |      1.125 |         |         |        6 |      0 |      15 |       7 |      21 |
| task_type=rename-file | flaws (mean diff) | optional - baseline                 |     -0.151 |         |         |        7 |     10 |       4 |       7 |      21 |
| task_type=rename-file | success (pp)      | enforced - baseline                 |     -1.587 |         |         |        0 |     20 |       1 |       7 |      21 |
| task_type=rename-file | cost ratio        | enforced / baseline                 |      1.907 |         |         |        2 |      0 |      19 |       7 |      21 |
| task_type=rename-file | flaws (mean diff) | enforced - baseline                 |     -0.032 |         |         |        6 |      9 |       6 |       7 |      21 |
| task_type=rename-file | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=rename-file | cost ratio        | intellij-optional / baseline        |      1.255 |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=rename-file | flaws (mean diff) | intellij-optional - baseline        |      0.111 |         |         |        0 |      2 |       1 |       1 |       3 |
| task_type=rename-file | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=rename-file | cost ratio        | intellij-enforced / baseline        |      2.921 |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=rename-file | flaws (mean diff) | intellij-enforced - baseline        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=rename-file | success (pp)      | optional - baseline-review          |      4.762 |         |         |        1 |     20 |       0 |       7 |      21 |
| task_type=rename-file | cost ratio        | optional / baseline-review          |      0.363 |         |         |       21 |      0 |       0 |       7 |      21 |
| task_type=rename-file | flaws (mean diff) | optional - baseline-review          |     -0.032 |         |         |        3 |     15 |       3 |       7 |      21 |
| task_type=rename-file | success (pp)      | enforced - baseline-review          |      3.175 |         |         |        1 |     19 |       1 |       7 |      21 |
| task_type=rename-file | cost ratio        | enforced / baseline-review          |      0.616 |         |         |       19 |      0 |       2 |       7 |      21 |
| task_type=rename-file | flaws (mean diff) | enforced - baseline-review          |      0.087 |         |         |        4 |     11 |       6 |       7 |      21 |
| task_type=rename-file | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=rename-file | cost ratio        | intellij-optional / baseline-review |      0.288 |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=rename-file | flaws (mean diff) | intellij-optional - baseline-review |     -0.167 |         |         |        1 |      2 |       0 |       1 |       3 |
| task_type=rename-file | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=rename-file | cost ratio        | intellij-enforced / baseline-review |      0.67  |         |         |        3 |      0 |       0 |       1 |       3 |
| task_type=rename-file | flaws (mean diff) | intellij-enforced - baseline-review |     -0.278 |         |         |        2 |      1 |       0 |       1 |       3 |
| task_type=signature   | success (pp)      | baseline-review - baseline          |     -6.667 |         |         |        0 |     13 |       2 |       5 |      15 |
| task_type=signature   | cost ratio        | baseline-review / baseline          |      2.355 |         |         |        0 |      0 |      15 |       5 |      15 |
| task_type=signature   | flaws (mean diff) | baseline-review - baseline          |     -0.167 |         |         |        4 |     11 |       0 |       5 |      15 |
| task_type=signature   | success (pp)      | optional - baseline                 |     -4.167 |         |         |        0 |     11 |       1 |       4 |      12 |
| task_type=signature   | cost ratio        | optional / baseline                 |      1.003 |         |         |        7 |      0 |       5 |       4 |      12 |
| task_type=signature   | flaws (mean diff) | optional - baseline                 |     -0.125 |         |         |        3 |      7 |       2 |       4 |      12 |
| task_type=signature   | success (pp)      | enforced - baseline                 |     -8.333 |         |         |        0 |     11 |       1 |       4 |      12 |
| task_type=signature   | cost ratio        | enforced / baseline                 |      1.716 |         |         |        2 |      0 |      10 |       4 |      12 |
| task_type=signature   | flaws (mean diff) | enforced - baseline                 |     -0.014 |         |         |        2 |      9 |       1 |       4 |      12 |
| task_type=signature   | success (pp)      | intellij-optional - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=signature   | cost ratio        | intellij-optional / baseline        |      0.839 |         |         |        4 |      0 |       2 |       2 |       6 |
| task_type=signature   | flaws (mean diff) | intellij-optional - baseline        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=signature   | success (pp)      | intellij-enforced - baseline        |     -5.556 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=signature   | cost ratio        | intellij-enforced / baseline        |      2.574 |         |         |        0 |      0 |       6 |       2 |       6 |
| task_type=signature   | flaws (mean diff) | intellij-enforced - baseline        |      0.167 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=signature   | success (pp)      | optional - baseline-review          |      4.167 |         |         |        1 |     11 |       0 |       4 |      12 |
| task_type=signature   | cost ratio        | optional / baseline-review          |      0.422 |         |         |       12 |      0 |       0 |       4 |      12 |
| task_type=signature   | flaws (mean diff) | optional - baseline-review          |      0.083 |         |         |        1 |      7 |       4 |       4 |      12 |
| task_type=signature   | success (pp)      | enforced - baseline-review          |      0     |         |         |        2 |      9 |       1 |       4 |      12 |
| task_type=signature   | cost ratio        | enforced / baseline-review          |      0.722 |         |         |        9 |      0 |       3 |       4 |      12 |
| task_type=signature   | flaws (mean diff) | enforced - baseline-review          |      0.194 |         |         |        2 |      6 |       4 |       4 |      12 |
| task_type=signature   | success (pp)      | intellij-optional - baseline-review |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| task_type=signature   | cost ratio        | intellij-optional / baseline-review |      0.42  |         |         |        6 |      0 |       0 |       2 |       6 |
| task_type=signature   | flaws (mean diff) | intellij-optional - baseline-review |      0.083 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=signature   | success (pp)      | intellij-enforced - baseline-review |     -5.556 |         |         |        0 |      5 |       1 |       2 |       6 |
| task_type=signature   | cost ratio        | intellij-enforced / baseline-review |      1.288 |         |         |        1 |      0 |       5 |       2 |       6 |
| task_type=signature   | flaws (mean diff) | intellij-enforced - baseline-review |      0.25  |         |         |        0 |      4 |       2 |       2 |       6 |
| task_type=signature   | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      3 |       0 |       1 |       3 |
| task_type=signature   | cost ratio        | intellij-optional / optional        |      0.918 |         |         |        1 |      0 |       2 |       1 |       3 |
| task_type=signature   | flaws (mean diff) | intellij-optional - optional        |     -0.278 |         |         |        2 |      1 |       0 |       1 |       3 |
| task_type=signature   | success (pp)      | intellij-enforced - enforced        |    -11.1   |         |         |        0 |      2 |       1 |       1 |       3 |
| task_type=signature   | cost ratio        | intellij-enforced / enforced        |      1.467 |         |         |        0 |      0 |       3 |       1 |       3 |
| task_type=signature   | flaws (mean diff) | intellij-enforced - enforced        |      0     |         |         |        1 |      1 |       1 |       1 |       3 |


### By probe_half

| stratum                                   | outcome           | contrast                            |   estimate |   ci_lo |   ci_hi |   better |   same |   worse |   tasks |   cells |
|:------------------------------------------|:------------------|:------------------------------------|-----------:|--------:|--------:|---------:|-------:|--------:|--------:|--------:|
| probe_half=probe score above median       | success (pp)      | baseline-review - baseline          |     -1.852 |  -9.259 |   4.167 |        3 |     30 |       3 |      12 |      36 |
| probe_half=probe score above median       | cost ratio        | baseline-review / baseline          |      2.085 |   1.794 |   2.353 |        1 |      0 |      35 |      12 |      36 |
| probe_half=probe score above median       | flaws (mean diff) | baseline-review - baseline          |      0     |  -0.148 |   0.13  |        8 |     23 |       5 |      12 |      36 |
| probe_half=probe score above median       | success (pp)      | optional - baseline                 |     -6.173 |         |         |        1 |     23 |       3 |       9 |      27 |
| probe_half=probe score above median       | cost ratio        | optional / baseline                 |      0.892 |         |         |       15 |      0 |      12 |       9 |      27 |
| probe_half=probe score above median       | flaws (mean diff) | optional - baseline                 |      0     |         |         |        4 |     19 |       3 |       9 |      26 |
| probe_half=probe score above median       | success (pp)      | enforced - baseline                 |     -9.877 |         |         |        0 |     23 |       4 |       9 |      27 |
| probe_half=probe score above median       | cost ratio        | enforced / baseline                 |      1.254 |         |         |        8 |      0 |      19 |       9 |      27 |
| probe_half=probe score above median       | flaws (mean diff) | enforced - baseline                 |      0.133 |         |         |        4 |     16 |       5 |       9 |      25 |
| probe_half=probe score above median       | success (pp)      | intellij-optional - baseline        |      2.222 |         |         |        1 |     14 |       0 |       5 |      15 |
| probe_half=probe score above median       | cost ratio        | intellij-optional / baseline        |      0.918 |         |         |        9 |      0 |       6 |       5 |      15 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-optional - baseline        |      0.078 |         |         |        3 |      9 |       3 |       5 |      15 |
| probe_half=probe score above median       | success (pp)      | intellij-enforced - baseline        |      0     |         |         |        0 |     15 |       0 |       5 |      15 |
| probe_half=probe score above median       | cost ratio        | intellij-enforced / baseline        |      1.145 |         |         |        5 |      0 |      10 |       5 |      15 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-enforced - baseline        |     -0.033 |         |         |        3 |      9 |       3 |       5 |      15 |
| probe_half=probe score above median       | success (pp)      | optional - baseline-review          |     -3.704 |         |         |        1 |     24 |       2 |       9 |      27 |
| probe_half=probe score above median       | cost ratio        | optional / baseline-review          |      0.443 |         |         |       27 |      0 |       0 |       9 |      27 |
| probe_half=probe score above median       | flaws (mean diff) | optional - baseline-review          |      0.006 |         |         |        3 |     21 |       2 |       9 |      26 |
| probe_half=probe score above median       | success (pp)      | enforced - baseline-review          |     -7.407 |         |         |        0 |     23 |       4 |       9 |      27 |
| probe_half=probe score above median       | cost ratio        | enforced / baseline-review          |      0.623 |         |         |       23 |      0 |       4 |       9 |      27 |
| probe_half=probe score above median       | flaws (mean diff) | enforced - baseline-review          |      0.14  |         |         |        2 |     18 |       5 |       9 |      25 |
| probe_half=probe score above median       | success (pp)      | intellij-optional - baseline-review |      2.222 |         |         |        1 |     14 |       0 |       5 |      15 |
| probe_half=probe score above median       | cost ratio        | intellij-optional / baseline-review |      0.439 |         |         |       15 |      0 |       0 |       5 |      15 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-optional - baseline-review |      0.011 |         |         |        2 |      8 |       5 |       5 |      15 |
| probe_half=probe score above median       | success (pp)      | intellij-enforced - baseline-review |      0     |         |         |        1 |     13 |       1 |       5 |      15 |
| probe_half=probe score above median       | cost ratio        | intellij-enforced / baseline-review |      0.547 |         |         |       15 |      0 |       0 |       5 |      15 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-enforced - baseline-review |     -0.1   |         |         |        2 |      9 |       4 |       5 |      15 |
| probe_half=probe score above median       | success (pp)      | intellij-optional - optional        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| probe_half=probe score above median       | cost ratio        | intellij-optional / optional        |      0.862 |         |         |        3 |      0 |       3 |       2 |       6 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-optional - optional        |     -0.056 |         |         |        1 |      3 |       2 |       2 |       6 |
| probe_half=probe score above median       | success (pp)      | intellij-enforced - enforced        |      0     |         |         |        0 |      6 |       0 |       2 |       6 |
| probe_half=probe score above median       | cost ratio        | intellij-enforced / enforced        |      0.829 |         |         |        4 |      0 |       2 |       2 |       6 |
| probe_half=probe score above median       | flaws (mean diff) | intellij-enforced - enforced        |     -0.444 |         |         |        2 |      3 |       1 |       2 |       6 |
| probe_half=probe score at or below median | success (pp)      | baseline-review - baseline          |      0.222 |  -2.148 |   2.667 |       13 |    203 |       9 |      75 |     225 |
| probe_half=probe score at or below median | cost ratio        | baseline-review / baseline          |      2.383 |   2.286 |   2.494 |        2 |      0 |     223 |      75 |     225 |
| probe_half=probe score at or below median | flaws (mean diff) | baseline-review - baseline          |     -0.045 |  -0.114 |   0.021 |       24 |     91 |      17 |      44 |     132 |
| probe_half=probe score at or below median | success (pp)      | optional - baseline                 |      1.178 |  -1.347 |   4.04  |       13 |    176 |       9 |      66 |     198 |
| probe_half=probe score at or below median | cost ratio        | optional / baseline                 |      1.039 |   1.007 |   1.074 |       72 |      0 |     126 |      66 |     198 |
| probe_half=probe score at or below median | flaws (mean diff) | optional - baseline                 |     -0.038 |  -0.114 |   0.034 |       19 |     84 |      14 |      39 |     117 |
| probe_half=probe score at or below median | success (pp)      | enforced - baseline                 |     -0.926 |  -4.211 |   2.275 |       13 |    165 |      20 |      66 |     198 |
| probe_half=probe score at or below median | cost ratio        | enforced / baseline                 |      1.618 |   1.486 |   1.756 |       24 |      0 |     174 |      66 |     198 |
| probe_half=probe score at or below median | flaws (mean diff) | enforced - baseline                 |      0.048 |  -0.038 |   0.14  |       17 |     76 |      24 |      39 |     117 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline        |     -0.585 |  -4.971 |   4.094 |        5 |     47 |       5 |      19 |      57 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline        |      1.037 |   0.988 |   1.091 |       20 |      0 |      37 |      19 |      57 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline        |      0.04  |  -0.015 |   0.101 |        2 |     25 |       6 |      11 |      33 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline        |      1.462 |  -6.725 |   9.942 |        7 |     44 |       6 |      19 |      57 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline        |      1.837 |   1.604 |   2.104 |        6 |      0 |      51 |      19 |      57 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline        |      0.192 |   0.056 |   0.348 |        0 |     25 |       8 |      11 |      33 |
| probe_half=probe score at or below median | success (pp)      | optional - baseline-review          |      0.421 |  -2.694 |   3.706 |        6 |    183 |       9 |      66 |     198 |
| probe_half=probe score at or below median | cost ratio        | optional / baseline-review          |      0.439 |   0.421 |   0.454 |      197 |      0 |       1 |      66 |     198 |
| probe_half=probe score at or below median | flaws (mean diff) | optional - baseline-review          |      0.02  |  -0.037 |   0.078 |       13 |     87 |      17 |      39 |     117 |
| probe_half=probe score at or below median | success (pp)      | enforced - baseline-review          |     -1.684 |  -4.461 |   1.515 |        8 |    171 |      19 |      66 |     198 |
| probe_half=probe score at or below median | cost ratio        | enforced / baseline-review          |      0.684 |   0.637 |   0.732 |      165 |      0 |      33 |      66 |     198 |
| probe_half=probe score at or below median | flaws (mean diff) | enforced - baseline-review          |      0.107 |   0.017 |   0.208 |       14 |     77 |      26 |      39 |     117 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - baseline-review |     -0.877 |  -5.556 |   3.808 |        3 |     50 |       4 |      19 |      57 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / baseline-review |      0.427 |   0.396 |   0.459 |       57 |      0 |       0 |      19 |      57 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - baseline-review |     -0.04  |  -0.111 |   0.03  |        4 |     25 |       4 |      11 |      33 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - baseline-review |      1.17  |  -8.48  |  12     |        6 |     44 |       7 |      19 |      57 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / baseline-review |      0.755 |   0.655 |   0.88  |       42 |      0 |      15 |      19 |      57 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - baseline-review |      0.111 |  -0.051 |   0.303 |        5 |     21 |       7 |      11 |      33 |
| probe_half=probe score at or below median | success (pp)      | intellij-optional - optional        |     -3.889 | -12.2   |   1.111 |        2 |     24 |       4 |      10 |      30 |
| probe_half=probe score at or below median | cost ratio        | intellij-optional / optional        |      1     |   0.961 |   1.042 |        9 |      0 |      21 |      10 |      30 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-optional - optional        |     -0.065 |         |         |        4 |     13 |       1 |       6 |      18 |
| probe_half=probe score at or below median | success (pp)      | intellij-enforced - enforced        |     -3.333 | -11.1   |   3.333 |        2 |     25 |       3 |      10 |      30 |
| probe_half=probe score at or below median | cost ratio        | intellij-enforced / enforced        |      1.17  |   1.007 |   1.346 |        9 |      0 |      21 |      10 |      30 |
| probe_half=probe score at or below median | flaws (mean diff) | intellij-enforced - enforced        |      0.037 |         |         |        3 |     12 |       3 |       6 |      18 |


## LSP adoption in the optional arm (observational)

| model             |   runs |   lsp_used |   success_when_used |   success_when_not |
|:------------------|-------:|-----------:|--------------------:|-------------------:|
| claude-haiku-5-5  |    225 |       0    |             nan     |              0.738 |
| claude-opus-5-5   |     75 |       0.16 |               0.667 |              0.81  |
| claude-sonnet-5-5 |    150 |       0    |             nan     |              0.713 |

## LSP operations used (all arms)

|                               |   calls |
|:------------------------------|--------:|
| lsp_navigate:references       |     776 |
| lsp_diagnostics:              |     640 |
| lsp_navigate:implementation   |     265 |
| lsp_navigate:workspaceSymbols |     246 |
| lsp_navigate:symbols          |     221 |
| lsp_navigate:definition       |     106 |
| lsp_navigate:incomingCalls    |      96 |
| lsp_navigate:symbolBody       |      87 |
| lsp_rename:preview            |      65 |
| lsp_rename:                   |      55 |
| lsp_navigate:request          |      46 |
| lsp_rename:apply              |      30 |
| lsp_diagnostics:diagnostics   |      24 |
| lsp_status:status             |      23 |
| lsp_status:servers            |      21 |
| lsp_status:retry              |      20 |
| lsp_navigate:hover            |      19 |
| lsp_status:restart            |       8 |
| lsp_status:logs               |       5 |
| lsp_status:                   |       3 |
| lsp_status:projects           |       1 |
| lsp_status:configuration      |       1 |
| lsp_status:stop               |       1 |
