"""The analysis of docs/ANALYSIS_PLAN.md over results/<plan>/runs.csv: descriptive and paired.

Writes results/<plan>/report/: report.md (tables), *.csv (every number in the tables), overview.png.
"""
from __future__ import annotations

import json
import os
import re
import sys
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")
ARMS = ["baseline", "baseline-review", "optional", "enforced", "intellij-optional", "intellij-enforced"]
# Every arm against baseline; each LSP arm against the self-review habit; IntelliJ against the tereditor arm of its mode.
PAIRS = ([(a, "baseline") for a in ARMS if a != "baseline"]
         + [(a, "baseline-review") for a in ("optional", "enforced", "intellij-optional", "intellij-enforced")]
         + [("intellij-optional", "optional"), ("intellij-enforced", "enforced")])
RNG_SEED = 20261110
B = 2000          # resamples of tasks for the interval of spread
MIN_TASKS = 10    # strata with fewer tasks show counts and no interval


def cells(df: pd.DataFrame, col: str, a: str, b: str, log: bool = False) -> pd.DataFrame:
    """Per task x model, the mean of col in arm a and in arm b (paired cells only)."""
    d = df[df.arm.isin([a, b])].copy()
    if log:
        d = d[d[col] > 0]
        d[col] = np.log(d[col].astype(float))
    m = d.groupby(["task_key", "model", "arm"])[col].mean().unstack("arm")
    if a not in m.columns or b not in m.columns:
        return m.iloc[0:0]
    return m.dropna(subset=[a, b])


def interval(c: pd.DataFrame, stat, rng):
    """Percentile interval of stat over resamples of tasks (all of a task's cells move together)."""
    tasks = c.index.get_level_values("task_key").unique()
    groups = {t: c.xs(t, level="task_key", drop_level=False) for t in tasks}
    draws = []
    for _ in range(B):
        pick = rng.choice(len(tasks), size=len(tasks), replace=True)
        draws.append(stat(pd.concat([groups[tasks[i]] for i in pick])))
    return tuple(np.percentile(draws, [2.5, 97.5]))


def row(label, outcome, contrast, c, a, b, stat, better, rng):
    d = c[a] - c[b]
    tasks = c.index.get_level_values("task_key").nunique()
    lo = hi = np.nan
    if tasks >= MIN_TASKS:
        lo, hi = interval(c, stat, rng)
    return dict(stratum=label, outcome=outcome, contrast=contrast, estimate=stat(c), ci_lo=lo, ci_hi=hi,
                better=int((better(d)).sum()), same=int((d.abs() < 1e-12).sum()), worse=int((better(-d)).sum()),
                tasks=tasks, cells=len(c))


def contrast_table(df: pd.DataFrame, label: str, rng) -> pd.DataFrame:
    out = []
    for a, b in PAIRS:
        s = cells(df, "success_f", a, b)
        if len(s):
            out.append(row(label, "success (pp)", f"{a} - {b}", s, a, b, lambda c: (c[a] - c[b]).mean() * 100, lambda d: d > 1e-12, rng))
        c = cells(df, "cost_f", a, b, log=True)
        if len(c):  # log scale: a lower value is cheaper, so "better" counts cells where a was cheaper
            out.append(row(label, "cost ratio", f"{a} / {b}", c, a, b, lambda x: float(np.exp((x[a] - x[b]).mean())), lambda d: d < -1e-12, rng))
        if "flaws_f" in df and df.flaws_f.notna().any():
            f = cells(df.dropna(subset=["flaws_f"]), "flaws_f", a, b)
            if len(f):
                out.append(row(label, "flaws (mean diff)", f"{a} - {b}", f, a, b, lambda x: (x[a] - x[b]).mean(), lambda d: d < -1e-12, rng))
    return pd.DataFrame(out)


def fmt(t: pd.DataFrame) -> str:
    if t.empty:
        return "_no data_\n"
    t = t.copy()
    for col in ("estimate", "ci_lo", "ci_hi"):
        t[col] = t[col].map(lambda v: "" if pd.isna(v) else (f"{v:.3f}" if abs(v) < 10 else f"{v:.1f}"))
    return t.to_markdown(index=False) + "\n"


def describe(df: pd.DataFrame) -> pd.DataFrame:
    g = df.groupby(["model", "arm"])
    d = {
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
    }
    if "flaws_f" in df and df.flaws_f.notna().any():
        d["mean_flaws"] = g.flaws_f.mean().round(2)
    return pd.DataFrame(d).reset_index()


def probe_score(task_key: str, root: str) -> float:
    """Highest verbatim share over the models, from the memprobe output saved in the task directory (NaN if none)."""
    p = os.path.join(root, "tasks", task_key, "memprobe.txt")
    try:
        shares = re.findall(r"worst verbatim share ([0-9.]+)", open(p).read())
        return float(shares[-1]) if shares else np.nan
    except OSError:
        return np.nan


def main(plan: str) -> None:
    root = os.environ.get("STUDY_ROOT", ".")
    base = os.path.join(root, "results", plan)
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
    if "flaws" in df:
        df["flaws_f"] = pd.to_numeric(df.flaws, errors="coerce")
    rng = np.random.default_rng(RNG_SEED)

    md = [f"# Report: {plan}\n",
          "Descriptive and paired: differences observed on these tasks, with a task-resampling interval for the spread. "
          f"Strata under {MIN_TASKS} tasks show counts only.\n",
          f"Runs finished: {n_all}; excluded (contamination or never reached the model): {len(excluded)}; analysed: "
          f"{len(df)}; tasks: {df.task_key.nunique()}; total cost: ${df.cost_f.sum():.2f}.\n"]
    desc = describe(df)
    desc.to_csv(os.path.join(rep, "descriptive.csv"), index=False)
    md += ["## By model and arm\n", desc.to_markdown(index=False) + "\n"]

    main_t = contrast_table(df, "all", rng)
    main_t.to_csv(os.path.join(rep, "contrasts.csv"), index=False)
    md += ["## Contrasts on the tasks both arms ran (better / same / worse = cells where the first arm did better, equal, worse; "
           "for cost, better = cheaper)\n", fmt(main_t)]

    df["probe_score"] = df.task_key.map(lambda k: probe_score(k, root))
    med = df.probe_score.median()
    if df.probe_score.notna().any():
        df["probe_half"] = np.where(df.probe_score > med, "probe score above median", "probe score at or below median")
    strata = ["model", "lang", "size", "task_type"] + (["probe_half"] if "probe_half" in df else [])
    sec = []
    for col in strata:
        fam = pd.concat([contrast_table(df[df[col] == v], f"{col}={v}", rng) for v in sorted(df[col].dropna().unique())],
                        ignore_index=True)
        fam.to_csv(os.path.join(rep, f"by_{col}.csv"), index=False)
        sec += [f"### By {col}\n", fmt(fam), ""]
    md += ["## The same contrasts by stratum\n"] + sec

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
            t.plot.bar(ax=ax, rot=0)
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
