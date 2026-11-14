"""The pre-registered analysis (docs/ANALYSIS_PLAN.md) over results/<plan>/runs.csv.

Writes results/<plan>/report/: report.md (tables), *.csv (every number in the tables), *.png (figures).
"""
from __future__ import annotations

import itertools
import json
import os
import sys
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")
ARMS = ["baseline", "optional", "enforced", "intellij-optional", "intellij-enforced"]
PAIRS = [("optional", "baseline"), ("enforced", "baseline"), ("enforced", "optional"),
         ("intellij-optional", "baseline"), ("intellij-enforced", "baseline"),
         ("intellij-optional", "optional"), ("intellij-enforced", "enforced")]
RNG_SEED = 20261110
B = 10_000


def holm(p: list[float]) -> list[float]:
    order = np.argsort(p)
    m = len(p)
    adj = np.empty(m)
    running = 0.0
    for rank, i in enumerate(order):
        running = max(running, (m - rank) * p[i])
        adj[i] = min(1.0, running)
    return list(adj)


def bh(p: list[float]) -> list[float]:
    p = np.asarray(p, dtype=float)
    m = len(p)
    if m == 0:
        return []
    order = np.argsort(p)
    ranked = p[order] * m / (np.arange(m) + 1)
    ranked = np.minimum.accumulate(ranked[::-1])[::-1]
    adj = np.empty(m)
    adj[order] = np.minimum(ranked, 1.0)
    return list(adj)


def task_means(df: pd.DataFrame, col: str, a: str, b: str, log: bool = False) -> pd.DataFrame:
    """Per task x model, the mean of col in arm a and arm b (paired cells only)."""
    d = df[df.arm.isin([a, b])].copy()
    if log:
        d = d[d[col] > 0]
        d[col] = np.log(d[col].astype(float))
    m = d.groupby(["task_key", "model", "arm"])[col].mean().unstack("arm")
    if a not in m.columns or b not in m.columns:
        return m.iloc[0:0]
    return m.dropna(subset=[a, b])


def cluster_bootstrap(cells: pd.DataFrame, a: str, b: str, stat, rng) -> tuple[float, float, float]:
    """Resample tasks (with all their model cells); stat maps a frame of cells to a number."""
    tasks = cells.index.get_level_values("task_key").unique()
    groups = {t: cells.xs(t, level="task_key", drop_level=False) for t in tasks}
    point = stat(cells)
    draws = []
    for _ in range(B):
        pick = rng.choice(len(tasks), size=len(tasks), replace=True)
        draws.append(stat(pd.concat([groups[tasks[i]] for i in pick])))
    lo, hi = np.percentile(draws, [2.5, 97.5])
    return point, lo, hi


def sign_flip_p(cells: pd.DataFrame, a: str, b: str, rng) -> float:
    """Paired permutation test on per-task differences (models averaged within task)."""
    diff = (cells[a] - cells[b]).groupby(level="task_key").mean().to_numpy()
    if len(diff) == 0 or np.allclose(diff, 0):
        return 1.0
    obs = abs(diff.mean())
    flips = rng.choice([-1, 1], size=(B, len(diff)))
    perm = np.abs((flips * diff).mean(axis=1))
    return float((np.sum(perm >= obs - 1e-12) + 1) / (B + 1))


def contrast_table(df: pd.DataFrame, label: str, rng) -> pd.DataFrame:
    out = []
    for a, b in PAIRS:
        s = task_means(df, "success_f", a, b)
        if len(s):
            pt, lo, hi = cluster_bootstrap(s, a, b, lambda c: (c[a] - c[b]).mean() * 100, rng)
            out.append(dict(stratum=label, outcome="success (pp)", contrast=f"{a} - {b}", estimate=pt, ci_lo=lo,
                            ci_hi=hi, p=sign_flip_p(s, a, b, rng), tasks=s.index.get_level_values(0).nunique(),
                            cells=len(s)))
        c = task_means(df, "cost_f", a, b, log=True)
        if len(c):
            pt, lo, hi = cluster_bootstrap(c, a, b, lambda x: float(np.exp((x[a] - x[b]).mean())), rng)
            out.append(dict(stratum=label, outcome="cost ratio", contrast=f"{a} / {b}", estimate=pt, ci_lo=lo,
                            ci_hi=hi, p=sign_flip_p(c, a, b, rng), tasks=c.index.get_level_values(0).nunique(),
                            cells=len(c)))
    return pd.DataFrame(out)


def mixed_models(df: pd.DataFrame) -> str:
    lines = []
    try:
        import statsmodels.formula.api as smf
        from statsmodels.genmod.bayes_mixed_glm import BinomialBayesMixedGLM

        d = df.copy()
        d["arm"] = pd.Categorical(d.arm, categories=ARMS)
        glmm = BinomialBayesMixedGLM.from_formula("success_f ~ C(arm) * C(model)", {"task": "0 + C(task_key)"}, d)
        fit = glmm.fit_vb()
        lines.append("### Success: logistic mixed model, random intercept per task (variational Bayes)\n")
        lines.append("```\n" + str(fit.summary()) + "\n```\n")
        gee = smf.gee("success_f ~ C(arm) * C(model)", "task_key", d, family=__import__("statsmodels.api").api.families.Binomial(),
                      cov_struct=__import__("statsmodels.api").api.cov_struct.Exchangeable()).fit()
        lines.append("### Success: GEE, exchangeable within task (robustness)\n")
        lines.append("```\n" + str(gee.summary()) + "\n```\n")
        c = d[d.cost_f > 0].copy()
        c["log_cost"] = np.log(c.cost_f)
        lmm = smf.mixedlm("log_cost ~ C(arm) * C(model)", c, groups=c["task_key"]).fit()
        lines.append("### log(cost): linear mixed model, random intercept per task\n")
        lines.append("```\n" + str(lmm.summary()) + "\n```\n")
    except Exception as exc:  # small pilots may not support the full model
        lines.append(f"Mixed models not fitted: {exc!r}\n")
    return "\n".join(lines)


def fmt(t: pd.DataFrame) -> str:
    if t.empty:
        return "_no data_\n"
    t = t.copy()
    for col in ("estimate", "ci_lo", "ci_hi"):
        t[col] = t[col].map(lambda v: f"{v:.3f}" if abs(v) < 10 else f"{v:.1f}")
    for col in ("p", "p_adj"):
        if col in t:
            t[col] = t[col].map(lambda v: f"{v:.4f}")
    return t.to_markdown(index=False) + "\n"


def describe(df: pd.DataFrame) -> pd.DataFrame:
    g = df.groupby(["model", "arm"])
    return pd.DataFrame({
        "runs": g.size(),
        "success": g.success_f.mean().round(3),
        "mean_cost_usd": g.cost_f.mean().round(4),
        "median_cost_usd": g.cost_f.median().round(4),
        "median_wall_s": g.wall_s.median().round(1),
        "median_turns": g.num_turns.median(),
        "lsp_used": g.lsp_used_f.mean().round(3),
        "mean_lsp_calls": g.lsp_calls.mean().round(2),
        "mean_grep": (g.grep_tool.mean() + g.bash_search.mean()).round(2),
        "mean_read": (g.read_tool.mean() + g.bash_read.mean()).round(2),
        "capped": g.capped_f.mean().round(3),
    }).reset_index()


def main(plan: str) -> None:
    base = os.path.join(os.environ.get("STUDY_ROOT", "."), "results", plan)
    rep = os.path.join(base, "report")
    os.makedirs(rep, exist_ok=True)
    df = pd.read_csv(os.path.join(base, "runs.csv"))
    n_all = len(df)
    excluded = df[(df.contaminated == True) | (df.reached_model == False)]  # noqa: E712
    df = df.drop(excluded.index)
    df = df[df.graded == True].copy()  # noqa: E712
    df["success_f"] = df.success.astype(str).str.lower().eq("true").astype(float)
    df["cost_f"] = pd.to_numeric(df.cost_usd, errors="coerce").fillna(0.0)
    df["lsp_used_f"] = df.lsp_used.astype(str).str.lower().eq("true").astype(float)
    df["capped_f"] = df.capped.astype(str).str.lower().eq("true").astype(float)
    rng = np.random.default_rng(RNG_SEED)

    md = [f"# Report: {plan}\n", f"Runs finished: {n_all}; excluded (contamination or never reached the model): "
          f"{len(excluded)}; analysed: {len(df)}; tasks: {df.task_key.nunique()}; total cost: "
          f"${df.cost_f.sum():.2f}.\n"]
    desc = describe(df)
    desc.to_csv(os.path.join(rep, "descriptive.csv"), index=False)
    md += ["## Descriptive, by model and arm\n", desc.to_markdown(index=False) + "\n"]

    prim = contrast_table(df, "all", rng)
    if not prim.empty:
        prim["p_adj"] = holm(prim.p.tolist())
    prim.to_csv(os.path.join(rep, "primary.csv"), index=False)
    md += ["## Primary contrasts (task-clustered bootstrap 95% CI; paired sign-flip p; Holm over all primary contrasts)\n", fmt(prim)]

    md += ["## Mixed models\n", mixed_models(df)]

    sec = []
    for col in ("model", "lang", "size", "task_type"):
        fam = pd.concat([contrast_table(df[df[col] == v], f"{col}={v}", rng) for v in sorted(df[col].unique())],
                        ignore_index=True)
        if not fam.empty:
            fam["p_adj"] = bh(fam.p.tolist())
        fam.to_csv(os.path.join(rep, f"by_{col}.csv"), index=False)
        sec += [f"### By {col} (Benjamini-Hochberg within this family)\n", fmt(fam)]
        sec.append("")
    md += ["## Secondary contrasts (exploratory)\n"] + sec

    opt = df[df.arm == "optional"]
    if len(opt):
        a = opt.groupby(["model"]).agg(runs=("run_id", "size"), lsp_used=("lsp_used_f", "mean"),
                                       success_when_used=("success_f", lambda s: s[opt.loc[s.index, "lsp_used_f"] == 1].mean()),
                                       success_when_not=("success_f", lambda s: s[opt.loc[s.index, "lsp_used_f"] == 0].mean()))
        md += ["## LSP adoption in the optional arm (observational)\n", a.round(3).to_markdown() + "\n"]

    ops: dict[str, int] = {}
    for s in df.lsp_ops.dropna():
        for k, v in json.loads(s).items():
            ops[k] = ops.get(k, 0) + v
    if ops:
        md += ["## LSP operations used (all arms)\n",
               pd.Series(ops).sort_values(ascending=False).rename("calls").to_markdown() + "\n"]

    if len(excluded):
        md += ["## Excluded runs\n", excluded[["run_id", "arm", "model", "task_key", "contamination"]].to_markdown(index=False) + "\n"]

    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(1, 2, figsize=(11, 4))
        for ax, (col, title) in zip(axes, (("success_f", "Success rate"), ("cost_f", "Mean cost (USD)"))):
            t = df.groupby(["model", "arm"])[col].mean().unstack("arm").reindex(columns=[a for a in ARMS if a in set(df.arm)])
            t.plot.bar(ax=ax, rot=0, color=["#8c8c8c", "#4c78a8", "#f58518", "#54a24b", "#e45756"][: len(t.columns)])
            ax.set_title(title)
            ax.set_xlabel("")
        fig.tight_layout()
        fig.savefig(os.path.join(rep, "overview.png"), dpi=150)
    except Exception as exc:
        md.append(f"\n(figure not drawn: {exc!r})\n")

    with open(os.path.join(rep, "report.md"), "w") as f:
        f.write("\n".join(md))
    print(os.path.join(rep, "report.md"))


if __name__ == "__main__":
    main(sys.argv[1])
