"""Builds index.html and llms.txt from the study's result datasets in data/. Standard library only.

Run from the repository root:  uv run --no-project python build_site.py
Every number on the page is read from data/, never typed in. Charts are inline SVG; raw tables sit in collapsed
<details> blocks below them.
"""

import csv
import html
import math
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent
DATA = ROOT / "data"
OUT = ROOT / "index.html"
LLMS = ROOT / "llms.txt"
SITE = "https://commandertvis.github.io/tereditor-lsp-research/"

# Categorical slots 1 and 2 of the validated reference palette (light surface).
BLUE, ORANGE = "#2a78d6", "#eb6834"
INK, MUTED, GRID = "#222", "#555", "#ddd"

ARMS = ["optional", "enforced", "baseline-review", "intellij-optional", "intellij-enforced"]
MODELS = ["claude-haiku-5-5", "claude-sonnet-5-5", "claude-opus-5-5"]
MODEL_NAME = {"claude-haiku-5-5": "Haiku 5.5", "claude-sonnet-5-5": "Sonnet 5.5", "claude-opus-5-5": "Opus 5.5"}


def rows(name):
    with open(DATA / name, newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def num(x, digits=2):
    return f"{float(x):.{digits}f}"


def signed(x, digits=1):
    return f"{float(x):+.{digits}f}"


def esc(x):
    return html.escape(str(x))


class Raw(str):
    """A table cell that is already HTML."""


def usage(share, arm):
    """Share of runs that called an LSP tool, with dots: three = uses the tools a lot, two = sometimes, one = ignores."""
    pct = f"{100 * share:.0f}%"
    if arm.startswith("baseline"):
        return pct
    n, word = (3, "uses the tools a lot") if share >= 0.75 else (1, "ignores the tools") if share <= 0.10 else (2, "uses the tools sometimes")
    dots = "".join(f'<circle cx="{4 + 8 * i}" cy="7" r="3" fill="{INK if i < n else GRID}"/>' for i in range(3))
    return Raw(f'<svg class="use" width="24" height="14" role="img" aria-label="{word}"><title>{word}</title>{dots}</svg> {pct}')


def rank(body, col, higher_is_better, groups=None):
    """Tint a column (within each group of rows): best green, worst red, the rest yellow; ties share the tint."""
    for idx in (groups or [range(len(body))]):
        vals = {i: float(str(body[i][col]).rstrip("%")) for i in idx if str(body[i][col]) != ""}
        if len(set(vals.values())) < 2:
            continue
        best = max(vals.values()) if higher_is_better else min(vals.values())
        worst = min(vals.values()) if higher_is_better else max(vals.values())
        for i, v in vals.items():
            if v == best:
                body[i][col] = Raw(f'<span class="win" title="best in this table">{esc(body[i][col])}</span>')
            elif v == worst:
                body[i][col] = Raw(f'<span class="lose" title="worst in this table">{esc(body[i][col])}</span>')
            else:
                body[i][col] = Raw(f'<span class="mid" title="in between">{esc(body[i][col])}</span>')


def table(headers, body):
    head = "".join(f"<th>{esc(h)}</th>" for h in headers)
    lines = ["<tr>" + "".join(f"<td>{c if isinstance(c, Raw) else esc(c)}</td>" for c in r) + "</tr>" for r in body]
    return f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(lines)}</tbody></table>"


def spoiler(summary, inner):
    return f"<details><summary>{esc(summary)}</summary>{inner}</details>"


def find(rs, **kw):
    for r in rs:
        if all(r.get(k) == v for k, v in kw.items()):
            return r
    return None


def contrast_name(arm, outcome):
    return f"{arm} / baseline" if outcome == "cost ratio" else f"{arm} - baseline"


# ---------- charts ----------

def forest(items, lo, hi, ref, fmt, title, log=False, width=680):
    """Dot-and-interval rows. items: (label, est, ci_lo, ci_hi, colour, tooltip)."""
    left, right, row_h, top = 190, 20, 30, 26
    height = top + row_h * len(items) + 34
    plot_w = width - left - right

    def x(v):
        if log:
            v, a, b = math.log(v), math.log(lo), math.log(hi)
        else:
            a, b = lo, hi
        return left + (v - a) / (b - a) * plot_w

    ticks = _ticks(lo, hi, log)
    parts = [f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="{esc(title)}" class="chart">']
    for t in ticks:
        parts.append(f'<line x1="{x(t):.1f}" x2="{x(t):.1f}" y1="{top - 6}" y2="{height - 28}" stroke="{GRID}" stroke-width="1"/>')
        parts.append(f'<text x="{x(t):.1f}" y="{height - 10}" text-anchor="middle" class="tick">{esc(fmt(t))}</text>')
    parts.append(f'<line x1="{x(ref):.1f}" x2="{x(ref):.1f}" y1="{top - 10}" y2="{height - 28}" stroke="{MUTED}" stroke-width="1.5" stroke-dasharray="4 3"/>')
    for i, (label, est, a, b, colour, tip) in enumerate(items):
        y = top + row_h * i + row_h / 2
        parts.append(f'<text x="{left - 10}" y="{y + 4:.1f}" text-anchor="end" class="label">{esc(label)}</text>')
        parts.append(f'<g class="mark"><title>{esc(tip)}</title>'
                     f'<rect x="{left}" y="{y - row_h / 2:.1f}" width="{plot_w}" height="{row_h}" fill="transparent"/>')
        if a is not None and b is not None:
            parts.append(f'<line x1="{x(max(a, lo)):.1f}" x2="{x(min(b, hi)):.1f}" y1="{y:.1f}" y2="{y:.1f}" stroke="{colour}" stroke-width="2" stroke-linecap="round"/>')
        parts.append(f'<circle cx="{x(est):.1f}" cy="{y:.1f}" r="5" fill="{colour}" stroke="#fff" stroke-width="2"/></g>')
    parts.append("</svg>")
    return "".join(parts)


def _ticks(lo, hi, log):
    if log:
        cands = [0.5, 0.75, 1, 1.25, 1.5, 2, 2.5, 3]
        return [t for t in cands if lo <= t <= hi]
    span = hi - lo
    step = next(s for s in (1, 2, 5, 10, 20, 25, 50) if span / s <= 8)
    start = math.ceil(lo / step) * step
    out, t = [], start
    while t <= hi + 1e-9:
        out.append(round(t, 6))
        t += step
    return out


def legend(series):
    return "<p class='legend'>" + " ".join(
        f"<span><svg width='12' height='12' aria-hidden='true'><circle cx='6' cy='6' r='5' fill='{c}'/></svg> {esc(n)}</span>"
        for n, c in series) + "</p>"


# ---------- page ----------

def server_section(runs, is_project, arms, title, merge=None):
    """Language-server arms against the baseline on one group of projects. arms: [(arm, label)], baseline first.
    merge maps an arm onto another one, to pool them (the IntelliJ arms into optional and enforced)."""
    if merge:
        runs = [dict(r, arm=merge.get(r["arm"], r["arm"])) for r in runs]
    import random
    import statistics
    sub = [r for r in runs if is_project(r["project"]) and r["arm"] in {a for a, _ in arms}]
    tasks = sorted({(r["project"], r["task"]) for r in sub})

    def ok(r):
        return 1.0 if r["success"] in ("True", "true", "1", "1.0") else 0.0

    cell = {}  # (task, model, arm) -> mean success over repetitions
    for r in sub:
        cell.setdefault(((r["project"], r["task"]), r["model"], r["arm"]), []).append(ok(r))
    cell = {k: sum(v) / len(v) for k, v in cell.items()}
    models = sorted({r["model"] for r in sub})

    def diff(arm, ts):
        d = [cell[(t, m, arm)] - cell[(t, m, "baseline")] for t in ts for m in models
             if (t, m, arm) in cell and (t, m, "baseline") in cell]
        return 100 * sum(d) / len(d)

    rng = random.Random(0)
    items, body = [], []
    for arm, label in arms:
        rs = [r for r in sub if r["arm"] == arm]
        flaws = [float(r["flaws"]) for r in rs if r["flaws"] not in ("", None)]
        row = [label, len(rs), f"{100 * sum(ok(r) for r in rs) / len(rs):.0f}%",
               f"{statistics.median(float(r['cost_usd'] or 0) for r in rs):.3f}",
               f"{statistics.median(float(r['wall_s'] or 0) for r in rs):.0f}",
               usage(sum(r['lsp_used'] in ('True', 'true', '1') for r in rs) / len(rs), arm),
               f"{sum(flaws) / len(flaws):.2f}" if flaws else ""]
        if arm != "baseline":
            est = diff(arm, tasks)
            boots = sorted(diff(arm, [rng.choice(tasks) for _ in tasks]) for _ in range(2000))
            lo, hi = boots[49], boots[1949]
            colour = BLUE if arm.startswith("intellij") else ORANGE
            items.append((label, est, lo, hi, colour,
                          f"{label} vs baseline: {est:+.1f} pp (95% interval {lo:+.1f} to {hi:+.1f}), {len(tasks)} tasks"))
        body.append(row)
    rank(body, 2, True)
    rank(body, 6, False)
    rank(body, 3, False)
    lim = max(10, 5 * math.ceil(max(max(abs(i[2]), abs(i[3])) for i in items) / 5))
    chart = forest(items, -lim, lim, 0, lambda t: "0 pp" if t == 0 else f"{t:+g} pp",
                   title)
    tbl = table(["Arm", "Runs", "Success", "Median cost (USD)", "Median wall time (s)", "Runs using LSP tools",
                 "Mean flaws"], body)
    zero = "every one includes zero" if all(i[2] <= 0 <= i[3] for i in items) else "not all include zero"
    return len(tasks), len(sub), chart, tbl, zero


def main():
    runs = rows("runs.csv")
    contrasts = rows("contrasts.csv")
    descriptive = rows("descriptive.csv")
    by_model = rows("by_model.csv")
    by_lang = rows("by_lang.csv")
    by_size = rows("by_size.csv")
    by_task = rows("by_task_type.csv")
    by_probe = rows("by_probe_half.csv")

    n_runs = len(runs)
    n_projects = len({r["project"] for r in runs})
    n_tasks = len({(r["project"], r["task"]) for r in runs})
    total_cost = sum(float(r["cost_usd"] or 0) for r in runs)
    excluded = sum(1 for r in runs if r["contaminated"] not in ("", "False", "false", "0"))

    def c_all(arm, outcome):
        return find(contrasts, stratum="all", outcome=outcome, contrast=contrast_name(arm, outcome))

    opt_s, enf_s = c_all("optional", "success (pp)"), c_all("enforced", "success (pp)")
    opt_c, enf_c = c_all("optional", "cost ratio"), c_all("enforced", "cost ratio")
    rev_c = c_all("baseline-review", "cost ratio")

    headline = (
        f"Across {n_tasks} tasks, offering the language server (optional arm) changed success by "
        f"{signed(opt_s['estimate'])} points (interval {signed(opt_s['ci_lo'])} to {signed(opt_s['ci_hi'])}) at "
        f"{num(opt_c['estimate'])}× the baseline cost. Pushing the agent to use it (enforced arm) changed success by "
        f"{signed(enf_s['estimate'])} points (interval {signed(enf_s['ci_lo'])} to {signed(enf_s['ci_hi'])}) at "
        f"{num(enf_c['estimate'])}× the cost. A second review turn without any language server (baseline-review) cost "
        f"{num(rev_c['estimate'])}×."
    )

    # Chart 1: success difference vs baseline, per arm, all models.
    s_items, s_rows = [], []
    for arm in ARMS:
        r = c_all(arm, "success (pp)")
        if r:
            e, a, b = float(r["estimate"]), float(r["ci_lo"]), float(r["ci_hi"])
            s_items.append((arm, e, a, b, BLUE, f"{arm} vs baseline: {e:+.1f} pp (95% interval {a:+.1f} to {b:+.1f}), {r['tasks']} tasks"))
            s_rows.append([arm, f"{e:+.2f}", f"{a:+.2f} to {b:+.2f}", r["better"], r["same"], r["worse"], r["tasks"]])
    chart_success = forest(s_items, -10, 10, 0, lambda t: "0 pp" if t == 0 else f"{t:+g} pp", "Success difference against baseline")

    # Chart 2: cost ratio vs baseline, per arm.
    c_items, c_rows = [], []
    for arm in ARMS:
        r = c_all(arm, "cost ratio")
        if r:
            e, a, b = float(r["estimate"]), float(r["ci_lo"]), float(r["ci_hi"])
            c_items.append((arm, e, a, b, ORANGE, f"{arm} / baseline: {e:.2f}× cost (95% interval {a:.2f} to {b:.2f}), {r['tasks']} tasks"))
            c_rows.append([arm, f"{e:.2f}", f"{a:.2f} to {b:.2f}", r["better"], r["same"], r["worse"], r["tasks"]])
    chart_cost = forest(c_items, 0.75, 3, 1, lambda t: f"{t:g}×", "Cost ratio against baseline", log=True)

    # Chart 3: per model, optional and enforced success difference.
    m_items, m_rows = [], []
    for m in MODELS:
        for arm, colour in (("optional", BLUE), ("enforced", ORANGE)):
            r = find(by_model, stratum=f"model={m}", outcome="success (pp)", contrast=contrast_name(arm, "success (pp)"))
            if r:
                e, a, b = float(r["estimate"]), float(r["ci_lo"]), float(r["ci_hi"])
                m_items.append((f"{MODEL_NAME[m]}, {arm}", e, a, b, colour,
                                f"{MODEL_NAME[m]}, {arm} vs baseline: {e:+.1f} pp (95% interval {a:+.1f} to {b:+.1f})"))
                m_rows.append([MODEL_NAME[m], arm, f"{e:+.2f}", f"{a:+.2f} to {b:+.2f}", r["tasks"]])
    chart_models = forest(m_items, -10, 10, 0, lambda t: "0 pp" if t == 0 else f"{t:+g} pp", "Success difference by model")

    # Chart 4: LSP adoption, optional vs enforced.
    groups = []
    for m in MODELS:
        o = find(descriptive, model=m, arm="optional")
        e = find(descriptive, model=m, arm="enforced")
        groups.append((MODEL_NAME[m], [float(o["lsp_used"]), float(e["lsp_used"])]))
    chart_adoption = '<div class="shelf">' + "".join(
        f'<div><div class="who">{esc(label)}</div>'
        f'<div class="nums">{usage(o, "optional").rsplit(" ", 1)[0]} <b>{o * 100:.0f}%</b> <span>optional</span></div>'
        f'<div class="nums">{usage(e, "enforced").rsplit(" ", 1)[0]} <b>{e * 100:.0f}%</b> <span>enforced</span></div></div>'
        for label, (o, e) in groups) + "</div>"

    k_tasks, k_runs, chart_kotlin, kotlin_table, k_zero = server_section(
        runs, lambda p: p.startswith(("kotlin-", "java-kotlin-")),
        [("baseline", "baseline (no language server)"), ("optional", "kotlin-lsp, optional"),
         ("enforced", "kotlin-lsp, enforced"), ("intellij-optional", "IntelliJ, optional"),
         ("intellij-enforced", "IntelliJ, enforced")],
        "Success difference against baseline on Kotlin tasks")
    a_tasks, a_runs, _, all_ls_table, _ = server_section(
        runs, lambda p: True,
        [("baseline", "baseline (no language server)"), ("optional", "optional, any language server"),
         ("enforced", "enforced, any language server")],
        "Success difference against baseline, all language servers",
        merge={"intellij-optional": "optional", "intellij-enforced": "enforced"})
    j_tasks, j_runs, chart_java, java_table, j_zero = server_section(
        runs, lambda p: p.startswith("java-") and not p.startswith("java-kotlin-"),
        [("baseline", "baseline (no language server)"), ("intellij-optional", "IntelliJ, optional"),
         ("intellij-enforced", "IntelliJ, enforced")],
        "Success difference against baseline on Java tasks")

    flaws = rows("flaws.csv")
    kinds = [("leftover", "an old name, path or signature the change should have updated but did not (comments, docstrings, strings, docs, configuration)"),
             ("naming", "a new name that is inconsistent with the task or the surrounding code"),
             ("churn", "formatting or whitespace changes to lines the task did not need to touch"),
             ("dead", "code, imports or files the change left dead or unused"),
             ("unrelated", "edits to places that have nothing to do with the task")]
    flaw_table = table(["Kind", "What it is", "Reported"],
                       [[k, d, sum(1 for f in flaws if f["kind"] == k)] for k, d in kinds])
    fx = find(flaws, run_id="r00110", kind="leftover")
    fx_run = find(runs, run_id="r00110")
    fx_passed = "passed" if fx_run["success"] == "True" else "failed"

    # Raw tables.
    desc_body = [[MODEL_NAME[r["model"]], r["arm"], r["runs"], num(r["success"], 3), f"{float(r['mean_cost_usd']):.4f}",
          f"{float(r['median_cost_usd']):.4f}", num(r["median_wall_s"], 1), usage(float(r["lsp_used"]), r["arm"]), num(r["mean_flaws"], 2)]
         for r in descriptive]
    by_m = [[i for i, r in enumerate(desc_body) if r[0] == MODEL_NAME[m]] for m in MODELS]
    rank(desc_body, 3, True, by_m)
    rank(desc_body, 8, False, by_m)
    rank(desc_body, 4, False, by_m)
    rank(desc_body, 5, False, by_m)
    desc_table = table(
        ["Model", "Arm", "Runs", "Success", "Mean cost (USD)", "Median cost (USD)", "Median wall time (s)",
         "Share of runs using LSP", "Mean flaws"], desc_body)
    hdr = ["Arm", "Estimate", "Interval (95%)", "Better", "Same", "Worse", "Tasks"]

    def strat_table(rs):
        keys = {contrast_name(a, o) for a in ARMS for o in ("success (pp)", "cost ratio")}
        body = [[r["stratum"].split("=", 1)[-1], r["contrast"], r["outcome"],
                 signed(r["estimate"], 2) if "pp" in r["outcome"] else num(r["estimate"]),
                 f"{num(r['ci_lo'])} to {num(r['ci_hi'])}" if r["ci_lo"] else "(too few tasks)", r["tasks"]]
                for r in rs if r["contrast"] in keys and r["outcome"] in ("success (pp)", "cost ratio")]
        return table(["Stratum", "Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"], body)

    page = f"""<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="Does a language server make a Claude Code agent better, faster or cheaper? Results of the LSP study confirmatory run." />
        <link rel="alternate" type="text/plain" href="llms.txt" title="llms.txt" />
        <title>LSP study: results</title>
        <style>
            body {{ font-family: "IBM Plex Sans", "Helvetica Neue", Arial, sans-serif; font-size: 1rem; line-height: 1.6;
                   max-width: 720px; margin: 40px auto; padding: 0 20px; color: {INK}; background: #fff; }}
            h1 {{ font-size: 1.625rem; margin-bottom: 4px; }}
            h2 {{ font-size: 1.25rem; margin-top: 32px; margin-bottom: 8px; }}
            p, li {{ margin-bottom: 6px; }}
            ul {{ padding-left: 20px; }}
            a {{ color: #1a0dab; }}
            a:visited {{ color: #609; }}
            a:focus-visible, summary:focus-visible {{ outline: 3px solid currentColor; outline-offset: 3px; }}
            .subtitle, .note {{ color: {MUTED}; font-size: 0.9375rem; margin-top: 0; }}
            .chart {{ width: 100%; height: auto; display: block; margin: 8px 0 4px; }}
            .chart .tick {{ font-size: 11px; fill: {MUTED}; }}
            .chart .label {{ font-size: 12px; fill: {INK}; }}
            .chart .value {{ font-size: 11px; fill: {INK}; }}
            .chart .mark:hover circle, .chart .mark:hover path {{ opacity: 0.75; }}
            .legend {{ font-size: 0.8125rem; color: {MUTED}; }}
            .shelf {{ display: flex; gap: 12px; flex-wrap: wrap; margin: 10px 0 20px; }}
            .shelf > div {{ flex: 1 1 150px; border: 1px solid {GRID}; border-radius: 6px; padding: 10px 14px; }}
            .shelf .who {{ font-size: 0.8125rem; color: {MUTED}; }}
            .shelf .nums b {{ font-size: 1.375rem; }}
            .shelf .nums span {{ font-size: 0.8125rem; color: {MUTED}; }}
            .win {{ background: #d9f0e3; padding: 1px 5px; border-radius: 3px; }}
            .mid {{ background: #fbefc4; padding: 1px 5px; border-radius: 3px; }}
            .lose {{ background: #fbdcd3; padding: 1px 5px; border-radius: 3px; }}
            svg.use {{ vertical-align: -2px; }}
            .legend span {{ margin-right: 16px; white-space: nowrap; }}
            details {{ margin: 4px 0 20px; }}
            summary {{ cursor: pointer; color: {MUTED}; font-size: 0.875rem; }}
            table {{ border-collapse: collapse; width: 100%; font-size: 0.8125rem; margin: 10px 0; }}
            th, td {{ border-bottom: 1px solid {GRID}; padding: 5px 7px; text-align: left; vertical-align: top; }}
            th {{ border-bottom: 2px solid #999; }}
            pre {{ background: #f6f6f4; padding: 10px 12px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; font-size: 0.75rem; line-height: 1.45; }}
            code {{ font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 0.875em; }}
            dt {{ font-weight: 700; margin-top: 10px; }}
            dd {{ margin: 2px 0 0 0; }}
            footer p {{ font-size: 0.8125rem; color: {MUTED}; }}
            @media (max-width: 480px) {{ body {{ margin-block: 24px; padding-inline: 16px; }} table {{ font-size: 0.75rem; }} }}
        </style>
    </head>
    <body>
        <h1>Does a language server make a Claude Code agent better, faster or cheaper?</h1>
        <p class="subtitle">Confirmatory run: {n_runs:,} runs, {n_tasks} tasks, {n_projects} projects, three Claude models, five arms.</p>

        <h2>What is being tested</h2>
        <p><a href="https://github.com/CommanderTvis/tereditor">tereditor</a> is an IDE-like workbench for terminal
        coding agents. Its headless build runs without a window and serves language tools to an agent over
        <a href="https://modelcontextprotocol.io">MCP</a> for one project: behind each tool sits the project
        language's language server (for example Pyright for Python, clangd for C and C++, <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a> for Kotlin). The study asks whether giving a Claude Code agent these tools changes how often it solves a task,
        what it costs and how long it takes.</p>
        <p>The agent sees six MCP tools:</p>
        <dl>
            <dt><code>lsp_navigate</code></dt>
            <dd>finds definitions, references, implementations, symbols and call hierarchies (callers and callees),
            and can send one read-only LSP query.</dd>
            <dt><code>lsp_diagnostics</code></dt>
            <dd>reports errors for the files an agent edited, by path or glob, or for the whole workspace, and can
            hide everything below a severity.</dd>
            <dt><code>lsp_rename</code>, <code>lsp_code_actions</code>, <code>lsp_format</code></dt>
            <dd>rename a symbol everywhere (or move a file and fix its imports), list and apply quick fixes and
            refactorings, and format a file. All three preview before they write and only change files inside the
            workspace.</dd>
            <dt><code>lsp_status</code></dt>
            <dd>shows the servers and starts them, and dumps the capabilities a server declared.</dd>
        </dl>
        <p>The language server and its runtime live in a separate sandbox; the agent reaches it only through a socket,
        so the tool arms get no compiler the baseline lacks.</p>
        <p>An example from the run, with Haiku on a Python project: the agent asks for every reference to a class by
        name, and the server answers with the locations (lines and columns are zero-based; the previews number
        lines from one).</p>
        <pre><code>// call: mcp__tereditor__lsp_navigate
{{"operation": "references", "query": "PaymentCardNumber",
 "path": "pydantic_extra_types/payment.py", "workspace": "/workspace", "limit": 200}}

// answer (shortened)
{{"state": "ready", "server": "python", "total": 3,
 "locations": [
  {{"path": "pydantic_extra_types/payment.py", "line": 34, "column": 6,
   "preview": "35: class PaymentCardNumber(str):"}},
  {{"path": "pydantic_extra_types/payment.py", "line": 69, "column": 76,
   "preview": "70:     def validate(cls, __input_value: str, ...) -&gt; PaymentCardNumber:"}},
  {{"path": "pydantic_extra_types/payment.py", "line": 215, "column": 33,
   "preview": "216:         brand, required_length = PaymentCardNumber._identify_brand(card_number)"}}]}}</code></pre>
        <p class="note">Run r00023 (task refs-payment-card-number, python-small, enforced arm).</p>

        <h2>The arms</h2>
        <p>Same agent, same task, no compiler. Only the language-server tools change.</p>
        <dl>
            <dt>baseline</dt>
            <dd>No language server. Plain Claude Code: read, edit, shell (grep).</dd>
            <dt>optional</dt>
            <dd>Language-server tools available. The agent may use them or not.</dd>
            <dt>enforced</dt>
            <dd>Language-server tools available, and the agent is told and nudged by hooks to use them.</dd>
        </dl>
        <p class="note">Also in the charts: baseline-review (baseline plus a second "review your work" turn) and the
        IntelliJ versions of optional and enforced, where IntelliJ is the language server (Java and Kotlin projects
        only). On Kotlin this compares IntelliJ with <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a>, which the plain optional and enforced arms use.</p>

        <h2>Success barely moves</h2>
        <p>Change in success rate against the baseline arm, all models pooled. The dashed line is no change.</p>
        {chart_success}
        {spoiler("Show the numbers", table(hdr, s_rows))}

        <h2>Cost goes up when LSP use is enforced</h2>
        <p>Cost of each arm as a multiple of the baseline (log scale). The dashed line is equal cost.</p>
        {chart_cost}
        {spoiler("Show the numbers", table(hdr, c_rows))}

        <h2>No model gains from it</h2>
        <p>Success change against the baseline, per model.</p>
        {legend([("optional", BLUE), ("enforced", ORANGE)])}
        {chart_models}
        {spoiler("Show the numbers", table(["Model", "Arm", "Estimate (pp)", "Interval (95%)", "Tasks"], m_rows))}

        <h2>Offered, the tools go unused</h2>
        <p>Share of runs that called at least one language-server tool.</p>
        {chart_adoption}

        <h2>What counts as a flaw</h2>
        <p>Tests decide whether a change works. A flaw is damage the tests cannot see. After each edit run, a reviewer
        (Haiku 5.5, which never sees the arm) reads the diff and searches the edited tree for five kinds of it;
        {len(flaws)} were reported in all.</p>
        {flaw_table}
        <p>An example. The task: rename Lucene's class <code>QueryBuilder</code> to <code>TextQueryBuilder</code>. The run
        ({esc(MODEL_NAME[fx_run["model"]])}, {esc(fx_run["arm"])} arm) {fx_passed} the tests, and the reviewer reported:</p>
        <pre><code>{esc(fx["kind"])}  {esc(fx["file"])}:{esc(fx["line"])}
{esc(fx["reason"])}</code></pre>
        <p class="note">The reviewer's reports have not been checked by a human yet. All of them are in
        <a href="data/flaws.csv">flaws.csv</a>.</p>

        <h2>All language servers together</h2>
        <p>Every language server pooled: the IntelliJ runs are counted with optional and enforced.
        {a_tasks} tasks, {a_runs:,} runs.</p>
        {all_ls_table}

        <h2>IntelliJ vs kotlin-lsp vs no language server</h2>
        <p>The {k_tasks} Kotlin and mixed Java+Kotlin tasks ran with both language servers:
        <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a> (the optional and enforced arms) and IntelliJ
        (the intellij arms), {k_runs} runs in all. Success change against the baseline on these tasks:</p>
        {legend([("IntelliJ", BLUE), ("kotlin-lsp", ORANGE)])}
        {chart_kotlin}
        {kotlin_table}
        <p class="note">{k_tasks} tasks is a small sample: the intervals are wide, and {k_zero}. Cost and time are medians over all three models.</p>

        <h2>Java: IntelliJ vs no language server</h2>
        <p>On the {j_tasks} pure Java tasks IntelliJ is the only language server (tereditor has no other headless
        Java server), so the comparison is IntelliJ against the baseline, {j_runs} runs in all.</p>
        {chart_java}
        {java_table}
        <p class="note">{j_tasks} tasks is a small sample: the intervals are wide, and {j_zero}. Cost and time are
        medians over all three models.</p>

        <h2>Raw data</h2>
        {spoiler("Arms by model", desc_table)}
        {spoiler("Contrasts by model", strat_table(by_model))}
        {spoiler("Contrasts by language", strat_table(by_lang))}
        {spoiler("Contrasts by project size", strat_table(by_size))}
        {spoiler("Contrasts by task type", strat_table(by_task))}
        {spoiler("Contrasts by memorization probe score", strat_table(by_probe))}
        <ul>
            <li><a href="data/runs.csv">runs.csv</a>: one row per run</li>
            <li><a href="data/plan.tsv">plan.tsv</a>: the seeded run plan</li>
            <li><a href="data/flaws.csv">flaws.csv</a>: every flaw the reviewer reported</li>
            <li><a href="data/descriptive.csv">descriptive.csv</a>, <a href="data/contrasts.csv">contrasts.csv</a>,
                <a href="data/by_model.csv">by_model.csv</a>, <a href="data/by_lang.csv">by_lang.csv</a>,
                <a href="data/by_size.csv">by_size.csv</a>, <a href="data/by_task_type.csv">by_task_type.csv</a>,
                <a href="data/by_probe_half.csv">by_probe_half.csv</a></li>
            <li><a href="llms.txt">llms.txt</a>: this page's findings for language models</li>
        </ul>

        <footer>
            <p>Generated by build_site.py from the files in data/.</p>
        </footer>
    </body>
</html>
"""
    OUT.write_text(page, encoding="utf-8")

    llms = f"""# LSP study: does a language server make a Claude Code agent better, faster or cheaper?

> A controlled comparison of Claude Code agents with and without language-server (LSP) tools: {n_runs:,} runs on {n_tasks} tasks in {n_projects} projects, three Claude models (Haiku 5.5, Sonnet 5.5, Opus 5.5), five arms. {headline}

What is tested: tereditor (https://github.com/CommanderTvis/tereditor), an IDE-like workbench for terminal coding agents whose headless build serves a project's language server to an agent over MCP. Its six tools: lsp_navigate (definitions, references, implementations, symbols, call hierarchies, one read-only LSP query), lsp_diagnostics (errors for edited files or the workspace), lsp_rename, lsp_code_actions and lsp_format (preview before writing, workspace only), lsp_status (servers and capabilities). Example call: lsp_navigate {{"operation": "references", "query": "PaymentCardNumber", "workspace": "/workspace"}} returns the reference locations with zero-based lines and previews.

Arms: baseline (Claude Code core tools only: Read, Edit, Write, Bash, Task, ToolSearch); baseline-review (baseline plus a second review turn); optional (LSP tools offered, not required); enforced (LSP use pushed by prompt and hooks); intellij-optional and intellij-enforced (IntelliJ as the language server, JVM projects only; on Kotlin the plain optional and enforced arms use https://github.com/Kotlin/kotlin-lsp). Success is a deterministic grader's pass rate; cost is Claude Code's total_cost_usd. Contrasts are paired on tasks; intervals are 95% task-resampling intervals.

## Data

- [runs.csv]({SITE}data/runs.csv): one row per run (task, arm, model, tool calls, cost, turns, success)
- [plan.tsv]({SITE}data/plan.tsv): the seeded run plan
- [flaws.csv]({SITE}data/flaws.csv): every quality flaw the reviewer reported (run, kind, file, line, reason)
- [descriptive.csv]({SITE}data/descriptive.csv): success, cost, time and LSP use per model and arm
- [contrasts.csv]({SITE}data/contrasts.csv): paired contrasts against the baseline, all tasks
- [by_model.csv]({SITE}data/by_model.csv), [by_lang.csv]({SITE}data/by_lang.csv), [by_size.csv]({SITE}data/by_size.csv), [by_task_type.csv]({SITE}data/by_task_type.csv), [by_probe_half.csv]({SITE}data/by_probe_half.csv): the same contrasts by stratum

## Page

- [Results page]({SITE}): charts and tables built from the data above
"""
    LLMS.write_text(llms, encoding="utf-8")
    print(f"wrote {OUT.name} ({len(page):,} bytes) and {LLMS.name} ({len(llms):,} bytes)")


if __name__ == "__main__":
    main()
