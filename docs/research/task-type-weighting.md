# Weighting task types in pooled results

How benchmark builders set the mix of task types in a mixed workload, what they do when they pool across types, and
what follows for this study's nine task types ([TASKS.md](../TASKS.md)) and its registered analysis
([ANALYSIS_PLAN.md](../ANALYSIS_PLAN.md)). Every claim below was checked against the source that owns it unless it is
marked "not verified".

## Short answer

Builders do one of four things, and almost none of them derive weights from measured usage:

- Pool every item with equal weight and let the type mix be whatever collection produced (SWE-bench, SWE-bench
  Verified, the original MMLU code, LiveCodeBench, Terminal-Bench). The resulting weights are an accident of curation:
  Django is 37% of SWE-bench and 46% of SWE-bench Verified.
- Give each task or category equal weight regardless of its size (SPEC CPU's geometric mean over benchmarks,
  BIG-bench's mean of normalised per-task scores, HELM's mean win rate over scenarios, tinyBenchmarks and the Open LLM
  Leaderboard's MMLU as a mean over subjects).
- Fix a mix that models one application and enforce it (TPC-C's minimum transaction percentages).
- Refuse a single number because no weighting is universally representative (MLPerf Training and Inference, YCSB's
  per-workload results; HELM says the same while still publishing a win rate).

The statistics literature adds two rules that matter here. Pooled numbers are only interpretable once the weights are
stated, because micro and macro averages can rank systems differently. When the effect varies by type, the right way
to get a population number is to model the effect by type and then average over a stated type distribution
(post-stratification), not to weight runs inside the model.

For this study, whose tasks are constructed rather than sampled from a natural population, the type mix is a design
choice. The recommendation is to make the design close to balanced across types, keep the registered task-weighted
models as primary while stating the implied type weights, add an equal-weight-per-type estimate as a pre-registered
sensitivity analysis, and offer a usage-weighted view only if usage frequencies per type are measured.

## LLM and agent benchmarks

### SWE-bench

Jimenez, Yang, Wettig, Yao, Pei, Press, Narasimhan. "SWE-bench: Can Language Models Resolve Real-World GitHub
Issues?" ICLR 2024. <https://arxiv.org/abs/2310.06770>

- Instances come from a three-stage filter (§2.1): about 90,000 PRs from 12 popular Python repositories, kept if they
  resolve an issue and change test files, then kept if at least one test goes from fail to pass and the environment
  installs. 2,294 instances remain. Repositories were chosen for popularity, maintenance and test coverage; nothing in
  the pipeline targets a mix of repositories, issue kinds or difficulty.
- The per-repository counts (Figure 3) are very uneven: django 850, sympy 386, scikit-learn 229, sphinx 187,
  matplotlib 184, pytest 119, xarray 110, astropy 95, pylint 57, requests 44, seaborn 22, flask 11.
- The metric is "the percentage of task instances that are resolved" (§2.1, "Evaluation metrics"), an unweighted mean
  over instances, so each repository's weight is its share of instances. The paper reports per-repository resolve
  rates separately (Appendix, Table 19) but does not reweight.
- SWE-bench Lite (300 instances) was sampled to be "more self-contained" with "a similar diversity and distribution of
  task instances across repositories as the original" (§2.4), i.e. it preserves the accidental mix rather than
  balancing it.

### SWE-bench Verified

Sources reached: the dataset card (<https://huggingface.co/datasets/princeton-nlp/SWE-bench_Verified>), the annotation
instructions OpenAI published
(<https://cdn.openai.com/introducing-swe-bench-verified/swe-b-annotation-instructions.pdf>), and the dataset's
statistics endpoint on Hugging Face.

- The card says only that it is "a subset of 500 samples from the SWE-bench test set, which have been human-validated
  for quality".
- Annotators rated each sample for issue specification (0 to 3), test scoping (0 to 3), other problems, and a
  difficulty bucket: "<15 min fix", "15 min - 1 hour", "1-4 hours", ">4 hours" (instructions, Section 3, Question 3.1).
- The released 500 have difficulty counts 194, 261, 42 and 3 in those buckets, and django is 231 of 500 (46%). Flask
  is 1, seaborn 2. The score is again the unweighted resolve rate.
- Not verified: how the 500 were drawn from the annotated pool. OpenAI's announcement
  (<https://openai.com/index/introducing-swe-bench-verified/>) returned HTTP 403. A search-engine excerpt of it says
  1,699 randomly sampled test instances were screened by 93 developers; that excerpt is not a primary reading. A third
  party reports 196 tasks in the easiest bucket where the released data has 194.

### HELM

Liang, Bommasani, Lee, et al. "Holistic Evaluation of Language Models." TMLR 2023. <https://arxiv.org/abs/2211.09110>

- Scenarios are chosen for coverage of a taxonomy (16 core scenarios, §3), and each is evaluated on up to 1,000
  instances (§11.2), so scenario size does not drive weight.
- Aggregation in the paper is a head-to-head win rate (§8.1, Figure 26): "the fraction of head-to-head comparisons
  between the given model and all other models, across all scenarios, where the given model is higher along the
  metric". Every scenario counts once.
- The label "mean win rate" is the leaderboard's. In the HELM source (`src/helm/benchmark/presentation/summarize.py`,
  `compute_aggregate_row_win_rates`), a model's win rate is computed per column (scenario) as the probability of
  beating a uniformly random other model, then averaged across columns with equal weight (median is the alternative).
- The authors decline a universal aggregate (§11.3): "We do not believe there exists a universal aggregation that
  satisfies all preferences, reflects all values, or captures all circumstances appropriately", while calling
  single-number metrics "useful practical tools to simplify decision-making". They also note that ranking A above B
  "requires making a judgment that (implicitly/explicitly) weighs the circumstances in which each is better".
- A win rate depends on which other models are in the table. It is a ranking device, not an effect size, and has no
  analogue in a study comparing a fixed set of arms.

### BIG-bench

Srivastava et al. "Beyond the Imitation Game: Quantifying and extrapolating the capabilities of language models."
Transactions on Machine Learning Research (per the arXiv journal reference). <https://arxiv.org/abs/2206.04615>

- Each task's author declares a preferred metric with a low and a high score. Aggregate performance (§3.1) is
  `100 × (raw − low) / (high − low)` averaged over all tasks, so every task weighs the same however many examples it
  has. Within a task with subtasks, evaluation draws up to 1000 divided by the number of subtasks examples from each
  subtask (Appendix, model evaluation details), again equalising subtasks.
- BIG-bench Lite (24 tasks, §2.2) was selected by hand "based on task keyword coverage and inclusion of certain task
  types such as code, non-English capabilities and measuring bias": a coverage rule, not a frequency rule.

### MMLU

Hendrycks, Burns, Basart, Zou, Mazeika, Song, Steinhardt. "Measuring Massive Multitask Language Understanding." ICLR
2021. <https://arxiv.org/abs/2009.03300>

- 57 subjects; the test set has 14,079 questions and "each subject contains 100 test examples at the minimum" (§3).
  Subjects are very unequal: on the Hugging Face copy (`cais/mmlu`) professional law has 1,534 test questions and ten
  subjects have exactly 100. That copy's total is 14,042, not the paper's 14,079; the difference is not explained in
  either place.
- The paper's Table 1 reports "average weighted accuracy". The authors' evaluation script
  (<https://github.com/hendrycks/test/blob/master/evaluate.py>) computes `np.mean(np.concatenate(all_cors))`: a micro
  average over questions, in which professional law carries about 11% of the weight against 1.75% for an equal share.
- tinyBenchmarks (below, §5) describes MMLU as "measured by averaging the accuracies on each of the categories", the
  macro convention used by the Open LLM Leaderboard. The same benchmark therefore circulates under two different
  weightings, and published MMLU numbers are not comparable without knowing which one was used.

### LiveCodeBench

Jain, Han, Gu, Li, Yan, Zhang, Wang, Solar-Lezama, Sen, Stoica. "LiveCodeBench: Holistic and Contamination Free
Evaluation of Large Language Models for Code." 2024. <https://arxiv.org/abs/2403.07974>

- Difficulty labels come from the platforms (§3.2): LeetCode's own labels; AtCoder ratings [0, 200), [200, 400),
  [400, 500] with problems above 500 excluded; Codeforces ratings 800, (800, 1000], (1000, 1300], Division 3 and 4
  only.
- "Balanced problem difficulty" (§1) means removing problems that are too hard to discriminate, not equal counts. The
  authors' reason is directly relevant: "the averaging of evaluation scores across problems with different difficulty
  levels artificially minimizes the differences between models", so they also report Easy, Medium and Hard subsets
  separately. The May 2023 to May 2024 set has 511 problems: 182 easy, 206 medium, 123 hard (Table 1).
- Pass@1 is the fraction of problems solved, from 10 samples per problem (§4, "Evaluation Metrics"): an unweighted
  mean over problems.
- Contamination control is by time window (§3.1, §5.1): every problem carries its contest date and a model is scored
  only on problems released after its training cutoff (or release date when the cutoff is unpublished). The difficulty mix
  therefore changes with the window chosen.

### Terminal-Bench

Merrill et al. "Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces." ICLR 2026.
<https://arxiv.org/abs/2601.11868>

- 93 contributors wrote 229 tasks; 89 were kept for Terminal-Bench 2.0 "based on the author's difficulty assessment and
  a quality assessment by three experienced human reviewers" (§2.2).
- Authors assigned a category per task (§2.4, Figure 4). Counts: software engineering 26, system administration 9,
  data science 8, security 8, scientific computing 8, file operations 5, debugging 5, data processing 4, model
  training 4, mathematics 4, machine learning 3, and one each for games, video processing, data querying,
  optimisation and personal assistant. The paper treats the spread as a diversity property ("no single category
  represents the majority of tasks") and does not weight by category.
- The headline is the resolution rate over tasks, with 95% confidence intervals, from at least five runs of every
  agent and model pair (§3). Human-predicted difficulty (medium or hard) is compared with an empirical difficulty
  derived from pass rates (§4.3), descriptively.
- Table 2's caption mentions "all 74 tasks" against 89 everywhere else; the paper does not explain the difference.

### tinyBenchmarks and IRT weighting

Maia Polo, Weber, Choshen, Sun, Xu, Yurochkin. "tinyBenchmarks: evaluating LLMs with fewer examples." ICML 2024.
<https://arxiv.org/abs/2402.14992>

- A scenario score is the average over items, but "when different sub-scenarios have different numbers of examples
  ... one would just have to use a weighted average instead, to make sure every sub-scenario is equally important"
  (§3; Appendix A defines the balance weights).
- Stratified random sampling (§3.1, following Perlitz et al. on HELM) samples so that the counts of any two
  sub-scenarios differ by at most one, with the stated rationale that "sub-scenarios should be equally represented".
- The IRT estimators (p-IRT, gp-IRT, §4) weight anchor items by the share of the full set each represents; their
  purpose is to reproduce the full-benchmark score from about 100 items, not to change what the score weights. They
  need response data from hundreds of earlier models to fit item parameters, which this study does not have.

## Systems benchmarks

### SPEC CPU 2017

SPEC. "SPEC CPU 2017 Overview / What's New?" and "SPEC CPU 2017 Run and Reporting Rules."
<https://www.spec.org/cpu2017/Docs/overview.html>, <https://www.spec.org/cpu2017/Docs/runrules.html>

- Each benchmark's score is a ratio to a reference machine (time on the reference machine over time on the system
  under test); the overall metric is the geometric mean of the per-benchmark ratios (overview Q15; run rules §4.10).
  No benchmark carries a weight; each counts once.
- The only rationale SPEC gives in these documents is invariance: "when comparing any two systems measured with the
  CPU 2017, their performance relative to each other would remain the same even if a different reference machine was
  used. This is a consequence of the mathematics involved in calculating the individual and overall (geometric mean)
  metrics" (Q18).
- SPEC does not claim the mix represents any workload: users should choose the metric "depending on how you use
  computers" (Q17) and no standard benchmark "can replace benchmarking your own actual application" (Q5).
- Not verified: Fleming and Wallace, "How not to lie with statistics: the correct way to summarize benchmark results",
  CACM 1986 (<https://dl.acm.org/doi/10.1145/5666.5673>), the usual citation for the geometric mean of normalised
  results, returned HTTP 403.

### TPC-C

Transaction Processing Performance Council. "TPC Benchmark C Standard Specification, Revision 5.11." 2010.
<https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-c_v5.11.0.pdf>

- Clause 5.2.3 (page 70) fixes minimum shares of the mix: Payment 43.0%, Order-Status 4.0%, Delivery 4.0%,
  Stock-Level 4.0%. New-Order has no minimum "as its measured rate is the reported throughput" (tpmC).
- The rationale is application modelling, not measurement: "approximately one Payment transaction for each New-Order
  transaction and approximately one Order-Status transaction, one Delivery transaction, and one Stock-Level
  transaction for every 10 New-Order transactions. This mix results in the complete business processing of each
  order" (Clause 5.2.3, Comment 1).
- Clause 5.2.4 enforces it: weighted random selection with weights kept within 5% of their initial values, or a
  shuffled deck of 23 cards (10 New-Order, 10 Payment, one of each other type).

### TPC-H

Transaction Processing Performance Council. "TPC Benchmark H Standard Specification, Revision 3.0.1."
<https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-h_v3.0.1.pdf>

- Power@Size is "the inverse of the geometric mean of the timing intervals" of the 22 queries and 2 refresh functions
  in a single stream, times 3600 and the scale factor (Clause 5.4.1.1): each query counts once.
- If the longest query takes more than 1000 times the shortest, short timings are raised to max/1000 for this metric
  (Clause 5.4.1.4), which caps how far one very fast query can move a geometric mean.
- Throughput@Size is total queries over elapsed time with S concurrent streams, `(S × 22 × 3600) / Ts × SF` (Clause
  5.4.2.1): an arithmetic, time-weighted view in which long queries dominate.
- QphH@Size combines the two (Clause 5.4.3.1). Not verified: the formula is an image in the PDF and did not extract;
  it is commonly given as the square root of Power@Size times Throughput@Size.

### YCSB

Cooper, Silberstein, Tam, Ramakrishnan, Sears. "Benchmarking Cloud Serving Systems with YCSB." SoCC 2010.
Text read from a course mirror of the published paper:
<https://www.cs.duke.edu/courses/fall13/compsci590.4/838-CloudPapers/ycsb.pdf>.

- The core workloads were chosen to span a space, explicitly not to model an application: "We did not attempt to
  exactly model a particular application or set of applications, as is done in benchmarks like TPC-C ... our goal was
  to examine a wide range of workload characteristics, in order to understand in which portions of the space of
  workloads systems performed well or poorly" (§4).
- Table 2 defines A (50% read, 50% update), B (95/5 read/update), C (100% read), D (95% read, 5% insert, latest
  distribution) and E (95% scan, 5% insert), each with an example application. Workload F (50% read, 50%
  read-modify-write) is not in the paper; it is defined in the project's repository
  (<https://github.com/brianfrankcooper/YCSB/blob/master/workloads/workloadf>).
- Results are reported per workload (§6); there is no cross-workload aggregate.

### MLPerf

Mattson et al. "MLPerf Training Benchmark." MLSys 2020. <https://arxiv.org/abs/1910.01500>; Reddi et al. "MLPerf
Inference Benchmark." ISCA 2020. <https://arxiv.org/abs/1911.02549>

- Training (§4.2.4): "a summary score implies some weighting of individual benchmark scores. Given the diversity of
  system users and the wide range of applications that MLPerf covers, no weighting scheme is universally
  representative. Second, a summary score becomes less meaningful if a submitter declines to report results on all
  benchmarks."
- Inference (§IV.C): "MLPerf Inference provides no 'summary score.' ... not all ML tasks are equally important for all
  systems, and the job of weighting some more heavily than others is highly subjective."
- The second Training reason applies directly to this study: arms do not run on the same projects (IntelliJ only on
  JVM projects), so a single pooled number across pairs would mix different task sets.

## Statistical guidance

### Macro versus micro averages

- Sebastiani, "Machine Learning in Automated Text Categorization", ACM Computing Surveys 2002
  (<https://arxiv.org/abs/cs/0110053>, §7.1.1): micro-averaging sums decisions over all categories, macro-averaging
  averages per-category results; "These two methods may give quite different results, especially if the different
  categories have very different generality", and the choice "obviously depends on the application requirements".
- scikit-learn documentation, "Metrics and scoring", §3.4.4.1 (<https://scikit-learn.org/stable/modules/model_evaluation.html>):
  macro gives "equal weight to each class" and "may be a means of highlighting" infrequent classes, but "the
  assumption that all classes are equally important is often untrue, such that macro-averaging will over-emphasize the
  typically low performance on an infrequent class"; a "weighted" average weights each class by its frequency.
- In this study's terms, the registered models are micro over tasks (each task counts once, so each type counts in
  proportion to its number of tasks); an equal-weight-per-type estimate is macro.

### Post-stratification and modelling by type

Gelman, "Struggles with Survey Weighting and Regression Modeling", Statistical Science 22(2), 2007.
<http://www.stat.columbia.edu/~gelman/research/published/STS226.pdf>

- §1.2 defines the post-stratified estimate as the cell estimates averaged with population cell sizes as weights,
  θ = Σ N_j θ_j / Σ N_j, and notes that under its model "the assignment of sample sizes to poststrata is irrelevant":
  the sample may be balanced while the target weights are not.
- §1.4 is the rule for effects: when the outcome depends on both the stratifier X and the variable of interest z,
  "the appropriate way to estimate the regression of y on z is to regress y on X, z and then average over the
  population distribution of X", including interactions between X and z, after which post-stratification over X is
  required to get the population effect. Here z is the arm and X the task type.
- §1.3: standard errors of weighted estimates cannot be obtained from the weights alone; the weighting procedure must
  be part of the variance computation (for this study: the bootstrap must recompute the weighted estimate in every
  resample).
- The precision cost of unequal weights is usually summarised by Kish's design effect, 1 + CV² of the weights (Kish,
  "Weighting for unequal Pi", Journal of Official Statistics 8(2), 1992, cited by Gelman §1.3). Not verified in
  Kish's text: the available PDF is a scan without extractable text. The figures below use the equivalent form
  n Σw² / (Σw)².

### Clustering, repetitions and paired comparisons

Miller, "Adding Error Bars to Evals: A Statistical Approach to Language Model Evaluations", Anthropic, 2024.
<https://arxiv.org/abs/2411.00640>

- §2.2: when items come in related groups, standard errors must be clustered on the group; on real evaluations the
  clustered standard error was up to about three times the naive one (Table 4).
- §3.1: resampling an item several times reduces only the within-item part of the variance; the upper bound on the
  reduction is fixed by the between-item variance. Beyond a few repetitions, more tasks buy more precision than more
  repetitions.
- §4.2: paired comparisons on the same items remove between-item variance from the contrast, which is what the
  registered within-task arm contrasts already do.

### Critiques of aggregate scores

- Ethayarajh and Jurafsky, "Utility is in the Eye of the User: A Critique of NLP Leaderboards", EMNLP 2020
  (<https://arxiv.org/abs/2009.13888>): "Given that each practitioner has their own preferences, there is no way to
  rank models so that everyone is satisfied"; leaderboards should report the components practitioners need (§1).
- Colombo, Noiry, Irurozki, Clémençon, "What are the best systems? New perspectives on NLP Benchmarking", NeurIPS 2022
  (<https://arxiv.org/abs/2202.03799>, §1): averaging across tasks "is seriously flawed since the different metrics are
  usually not on the same scales", and "even a pre-processing renormalization scheme would fail to capture the
  intrinsic difficulty of the tasks".
- Rofin, Mikhailov, Florinskiy, et al., "Vote'n'Rank: Revision of Benchmarking with Social Choice Theory", EACL 2023
  (<https://arxiv.org/abs/2210.05769>, §1): mean aggregation "implies that all task metrics are homogeneous", relies on
  absolute differences, and treats tasks of different complexity equally; leaders "may dominate the others only on the
  outlier tasks".
- These critiques target ranking many systems on heterogeneous metrics. This study's primary outcomes (success and
  cost) are on one scale across types, which removes the scale objection but not the weighting one.

## Recommendation for this study

### What the registered analysis already implies

`success ~ arm * model + (1 | task)` and the log-cost model have no task-type term, and every task counts once. The
pooled arm contrast is therefore a task-weighted average, and each type's weight is its share of tasks. That puts this
study in the SWE-bench / MMLU-original camp unless the counts are set deliberately. Under the current rule in TASKS.md
(refs, rename, compile, bugfix, and one rotating type per project), and assuming an even rotation and an xlarge shape
of refs, compile and one rotating type (TASKS.md fixes neither), the illustrative totals are refs 35, compile 35,
rename 27, bugfix 27, impls 9, callers 8, dispatch 8, inspect 5, signature 5 (159 tasks). The four core types then
carry about 78% of the pooled weight and each rotating type 3 to 6%, so the primary hypotheses would mostly be about
the four core types.

The log-cost contrast is a geometric mean of per-task cost ratios with every task counting once, the same aggregation
SPEC uses per benchmark, and like SPEC's it does not depend on which arm is the reference. Very cheap runs (early
crashes, empty answers) can pull it down, the effect TPC-H's clamp in Clause 5.4.1.4 limits; the registered
survivor-matched table removes unsolved tasks but not cheap failed runs on the remaining ones.

### Counts per type per project

The aim is a design close enough to balance that task-weighted and type-weighted estimates nearly coincide, with type
crossed with language and size rather than confounded with them.

- Small, medium and large projects (27): six tasks each. One each of `refs`, `rename`, `compile`, `bugfix`, plus two of
  `impls`, `dispatch`, `callers`, `inspect`, `signature`, assigned by a fixed rotation written down before curation,
  so that each rotating type appears about equally often and at every size. Where a language cannot support a type
  (Shell, CSS), the slot moves to the next type in the rotation and `project.toml` says so.
- Balance the rotation inside the JVM subset separately, because the IntelliJ pairs run only there: across the eight
  non-xlarge JVM projects (Kotlin, Java, Java+Kotlin) the 16 rotating slots give each rotating type three or four
  tasks.
- Xlarge projects (8): three tasks each, `refs`, `compile` (graded by a targeted build) and one of `impls`, `callers`,
  `dispatch` in rotation. Using the same three-type shape on every xlarge project keeps the size × type confound
  uniform instead of varying by language.
- Resulting totals, all projects: refs 35, compile 35, rename 27, bugfix 27, impls 14, callers 14, dispatch 13,
  inspect 11, signature 10; 186 tasks against the illustrative 159 under the current rule. These are upper bounds:
  they assume every non-xlarge project supports all four core types, which Shell and CSS may not.
- The extra tasks cost repetitions under the allocation rule in ANALYSIS_PLAN.md. That trade is favourable when task
  is the unit of generalisation (Miller §3.1), but the calibration pilot should confirm it against the measured
  between-task variance.

### Primary aggregation

- Keep the registered models and their task-weighted contrasts as primary; they are the most precise and are already
  registered. Add to ANALYSIS_PLAN.md a sentence naming the estimand: the arm effect averaged over the study's task
  set, in which each type's weight is its share of tasks, with those shares tabulated per primary pair (the shares
  differ between the tereditor pairs on 31 projects, the IntelliJ-vs-baseline pairs on 11 and the IntelliJ-vs-tereditor
  pairs on 7).
- Do not pool across pairs: each pair runs on its own project subset (MLPerf Training §4.2.4's second reason).

### Secondary per-type reporting

- Report every type's arm contrast for every primary pair, with its task count, as HELM, LiveCodeBench and MLPerf do
  for their components. The registered "by task type" interaction analysis covers this; it should also state the
  per-type task counts it rests on.
- Per-type inference needs enough tasks whose arm difference is non-zero, whatever the test. The registered
  per-stratum bootstrap intervals degenerate with a handful of tasks, and an exact sign-flip test on n such tasks
  cannot give a two-sided p below 2^(1−n): 0.0625 at five, 0.031 at six, 0.0078 at eight. Six is therefore the bare
  minimum before the Benjamini-Hochberg adjustment within the family; eight leaves room for it. Ties are likely where
  tasks are at ceiling, which the smoke runs already showed on small projects. Pre-register that a per-type contrast
  is tested only if it has at least eight tasks with a non-zero arm difference, and is otherwise reported
  descriptively. On the counts above this makes most per-type results for the IntelliJ pairs descriptive.
- Ask the calibration pilot for the per-type share of tasks at ceiling (solved in every run of every arm), not only
  the between-task variance, since a type at ceiling carries pooled weight but no information about arms.

### Sensitivity: equal weight per type

- Pre-register, as a sensitivity analysis for the 14 primary contrasts, the type-standardised estimate: the mean over
  the types present in the pair's subset of the per-type arm differences in success rate (and of per-type log cost
  ratios). This is the macro view that SPEC, BIG-bench, HELM and tinyBenchmarks use.
- Its interval comes from a bootstrap that resamples tasks within type, keeping per-type counts fixed and recomputing
  the standardised estimate in each resample (Gelman §1.3). That differs from the registered bootstrap, which
  resamples tasks without regard to type; the plan should name the difference.
- Its precision cost is the Kish design effect of per-task weights proportional to 1/n_type: 1.24 on the proposed
  counts (effective 150 of 186 tasks), against 1.75 on the illustrative current-rule counts (effective 91 of 159). This is the
  quantitative case for balancing by design rather than by weights.
- Report a disagreement in sign, or one estimate significant and the other not, as a finding that the conclusion
  depends on the task mix.

### Optional: usage-weighted view

- A usage-weighted estimate is the same standardisation with weights w_type taken from how often developers ask
  agents for each kind of work (Gelman §1.2 and §1.4: model by type, then average over the target distribution).
- The data it needs: a sample of real agent sessions or developer tickets classified into the nine types, with a
  documented sampling frame, a second rater on a subset for agreement, and a share for work that fits none of the
  types (which the study cannot represent and must report). No source consulted for this note gives such frequencies.
- Report it with the Kish design effect of its weights and only as exploratory, since the weights are not part of the
  registered design. Without such data, follow MLPerf and HELM and do not invent weights.

### Changes this implies elsewhere (proposed, not made)

- TASKS.md, "Target per project": six tasks for small to large projects with the rotation rule above, three fixed-shape
  tasks for xlarge.
- ANALYSIS_PLAN.md: the estimand sentence and per-pair type-share table for the primary analysis; the equal-weight
  sensitivity analysis with its within-type bootstrap; the minimum of eight discordant tasks for per-type tests; the
  pilot's per-type ceiling check. No confirmatory run has happened, so these can go into the plan body rather than
  "Changes after registration".

## Sources not reached or not verified

- OpenAI, "Introducing SWE-bench Verified" (<https://openai.com/index/introducing-swe-bench-verified/>): HTTP 403. The
  sampling of the 500 from the annotated pool is unverified, as are the figures known only from a search excerpt
  (1,699 annotated samples, 93 developers) and a third party (196 tasks in the easiest bucket).
- Fleming and Wallace, CACM 1986 (<https://dl.acm.org/doi/10.1145/5666.5673>): HTTP 403.
- Kish, "Weighting for unequal Pi", JOS 1992: scanned PDF without text; the design-effect formula is cited through
  Gelman 2007.
- TPC-H Clause 5.4.3.1, the QphH@Size formula: an image in the specification, not extracted.
- Manning, Raghavan, Schütze, "Introduction to Information Retrieval", §13.6 on macro and micro averaging
  (nlp.stanford.edu): connection refused; Sebastiani 2002 and the scikit-learn documentation were used instead.
