"""Builds index.html and llms.txt from the study's result datasets in data/. Standard library only.

Run from the repository root:  uv run --no-project python build_site.py
Every number on the page is read from data/, never typed in. Charts are inline SVG; raw tables sit in collapsed
<details> blocks below them.
"""

import statistics
import collections
import csv
import html
import math
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent
DATA = ROOT / "data"
OUT = ROOT / "index.html"
LLMS = ROOT / "llms.txt"
SITE = "https://commandertvis.github.io/tereditor-lsp-research/"

# Categorical slots 1 and 2 of the validated reference palette (light surface).
BLUE, ORANGE = "var(--blue)", "var(--orange)"
INK, MUTED, GRID = "var(--ink)", "var(--muted)", "var(--grid)"

ARMS = ["optional", "enforced", "baseline-review", "intellij-optional", "intellij-enforced"]
CHART_ARMS = [a for a in ARMS if a != "baseline-review"]  # baseline-review stays in the raw data only
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
        vals = {i: float(str(body[i][col]).split()[0].rstrip("%")) for i in idx if str(body[i][col]) != ""}
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


# Terms that get a dotted underline and a quick tooltip in tables (CSS only, no delay, keyboard-focusable).
TERMS = {
    "baseline": "No language-server tools: Claude Code with its core tools only (read, edit, shell and grep).",
    "optional": "Language-server tools available; the agent decides by itself whether to use them.",
    "enforced": "Language-server tools available, and the agent is told and nudged by hooks to use them.",
    "flaw": "Damage the tests cannot see, found by a reviewer in the diff: a leftover old name, an unrelated edit, "
            "formatting churn, inconsistent naming or dead code.",
}
TERM_RE = re.compile(r"(?<![-\w])(baseline|optional|enforced|flaws?)(?![-\w])", re.I)


def gloss(text):
    """Escape plain text and wrap each glossary term in it with an underlined, tooltipped span."""
    def wrap(m):
        key = m.group(1).lower().rstrip("s") if m.group(1).lower().startswith("flaw") else m.group(1).lower()
        return f'<span class="term" tabindex="0" data-tip="{esc(TERMS[key])}">{m.group(1)}</span>'
    return TERM_RE.sub(wrap, esc(text))


def table(headers, body, continued=()):
    """continued: indexes of rows that continue the row above (their first cells are joined to it)."""
    head = "".join(f"<th>{gloss(h)}</th>" for h in headers)
    lines = [("<tr class='join'>" if i + 1 in continued else "<tr>") + "".join(f"<td>{c if isinstance(c, Raw) else gloss(c)}</td>" for c in r) + "</tr>"
             for i, r in enumerate(body)]
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

def rank_colours(values, higher_better):
    """Best value green, worst red, the rest yellow; ties share the colour, and all-equal stays neutral."""
    if len(set(values)) < 2:
        return ["var(--okay)"] * len(values)
    best = max(values) if higher_better else min(values)
    worst = min(values) if higher_better else max(values)
    return ["var(--good)" if v == best else "var(--bad)" if v == worst else "var(--okay)" for v in values]


def forest(items, lo, hi, ref, fmt, title, log=False, width=680, higher_better=True):
    """Dot-and-interval rows with the baseline (the reference) as the first row. Colours rank the rows like the
    tables do: best green, worst red, the rest yellow. items: (label, est, ci_lo, ci_hi, colour (ignored), tooltip)."""
    items = [("baseline", ref, None, None, None, "baseline (the reference)")] + list(items)
    colours = rank_colours([it[1] for it in items], higher_better)
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
        colour = colours[i]
        parts.append(f'<text x="{left - 10}" y="{y + 4:.1f}" text-anchor="end" class="label">{esc(label)}</text>')
        parts.append(f'<g class="mark"><title>{esc(tip)}</title>'
                     f'<rect x="{left}" y="{y - row_h / 2:.1f}" width="{plot_w}" height="{row_h}" fill="transparent"/>')
        if a is not None and b is not None:
            parts.append(f'<line x1="{x(max(a, lo)):.1f}" x2="{x(min(b, hi)):.1f}" y1="{y:.1f}" y2="{y:.1f}" stroke="{colour}" stroke-width="2" stroke-linecap="round" opacity="0.4"/>')
        parts.append(f'<circle cx="{x(est):.1f}" cy="{y:.1f}" r="5" fill="{colour}" stroke="var(--bg)" stroke-width="2"/></g>')
    parts.append("</svg>")
    return "".join(parts)


def wilson(k, n, z=1.96):
    p = k / n
    d = 1 + z * z / n
    c = (p + z * z / (2 * n)) / d
    h = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return c - h, c + h


def rate_groups(groups, lo, hi, title, width=680):
    """Success rate per arm, grouped by model, with the baseline rate as a dashed line through each group.
    groups: [(group label, [(arm label, rate, ci_lo, ci_hi, colour, tooltip)])]; the first row of a group is the baseline."""
    left, right, row_h, top, gap = 190, 20, 26, 14, 14
    n_rows = sum(len(g[1]) for g in groups)
    height = top + row_h * n_rows + gap * (len(groups) - 1) + 40
    plot_w = width - left - right

    def x(v):
        return left + (v - lo) / (hi - lo) * plot_w

    parts = [f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="{esc(title)}" class="chart">']
    for t in range(math.ceil(lo / 10) * 10, int(hi) + 1, 10):
        parts.append(f'<line x1="{x(t):.1f}" x2="{x(t):.1f}" y1="{top - 6}" y2="{height - 34}" stroke="{GRID}" stroke-width="1"/>')
        parts.append(f'<text x="{x(t):.1f}" y="{height - 14}" text-anchor="middle" class="tick">{t}%</text>')
    y = top
    for gi, (label, rows_) in enumerate(groups):
        base = rows_[0][1]
        colours = rank_colours([r[1] for r in rows_], True)
        parts.append(f'<line x1="{x(base):.1f}" x2="{x(base):.1f}" y1="{y - 4}" y2="{y + row_h * len(rows_) + 4}" '
                     f'stroke="{MUTED}" stroke-width="1.5" stroke-dasharray="4 3"/>')
        for i, (arm, rate, a, b, _, tip) in enumerate(rows_):
            colour = colours[i]
            cy = y + row_h * i + row_h / 2
            name = f"{label}, {arm}"
            parts.append(f'<text x="{left - 10}" y="{cy + 4:.1f}" text-anchor="end" class="label">{esc(name)}</text>')
            parts.append(f'<g class="mark"><title>{esc(tip)}</title>'
                         f'<rect x="{left}" y="{cy - row_h / 2:.1f}" width="{plot_w}" height="{row_h}" fill="transparent"/>'
                         f'<line x1="{x(a):.1f}" x2="{x(b):.1f}" y1="{cy:.1f}" y2="{cy:.1f}" stroke="{colour}" stroke-width="2" stroke-linecap="round" opacity="0.4"/>'
                         f'<circle cx="{x(rate):.1f}" cy="{cy:.1f}" r="5" fill="{colour}" stroke="var(--bg)" stroke-width="2"/></g>')
        y += row_h * len(rows_) + gap
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
               f"{sum(flaws) / len(flaws):.2f} ({len(flaws)})" if flaws else ""]
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
                 "Flaws per reviewed edit run (reviewed runs)"], body)
    zero = "every one includes zero" if all(i[2] <= 0 <= i[3] for i in items) else "not all include zero"
    return len(tasks), len(sub), chart, tbl, zero


def kind_table(runs):
    """All arms (IntelliJ pooled into optional and enforced) on synthetic tasks and on real PR tasks."""
    merge = {"intellij-optional": "optional", "intellij-enforced": "enforced"}
    runs = [dict(r, arm=merge.get(r["arm"], r["arm"])) for r in runs]
    kinds = [("Synthetic", lambda r: r["task_type"] != "pr"), ("Real PRs", lambda r: r["task_type"] == "pr")]
    arms = [("baseline", "baseline (no LS)"), ("optional", "optional, any LS"),
            ("enforced", "enforced, any LS")]
    body = []
    for kind, pick in kinds:
        sub = [r for r in runs if pick(r)]
        ntasks = len({(r["project"], r["task"]) for r in sub})
        for arm, label in arms:
            rs = [r for r in sub if r["arm"] == arm]
            flaws = [float(r["flaws"]) for r in rs if r["flaws"] not in ("", None)]
            ok = sum(r["success"] in ("True", "true", "1", "1.0") for r in rs) / len(rs)
            body.append([kind if arm == "baseline" else "", ntasks if arm == "baseline" else "", label, len(rs),
                         f"{100 * ok:.0f}%",
                         f"{statistics.median(float(r['cost_usd'] or 0) for r in rs):.3f}",
                         f"{statistics.median(float(r['wall_s'] or 0) for r in rs):.0f}",
                         usage(sum(r["lsp_used"] in ("True", "true", "1") for r in rs) / len(rs), arm),
                         f"{sum(flaws) / len(flaws):.2f} ({len(flaws)})" if flaws else ""])
    groups = [range(0, 3), range(3, 6)]  # rank within each kind
    rank(body, 4, True, groups)
    rank(body, 5, False, groups)
    rank(body, 8, False, groups)
    return table(["Kind", "Tasks", "Arm", "Runs", "Success", "Median cost (USD)", "Median wall time (s)",
                  "Runs using LSP tools", "Flaws per reviewed edit run (reviewed runs)"], body, continued=[i for i, r in enumerate(body) if r[0] == ""])


EX_SYN = "Rename `salt/payload.py` to `salt/wire_payload.py`. Update every import and module reference, preserving behavior and removing the old path."
EX_PR = "Header object passed to c.body() is mutated, so reusing it returns 500 from the second request on"


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
    # Distinct languages, not counting css (a stylesheet language, not a programming language).
    n_syn_tasks = len({(r["project"], r["task"]) for r in runs if r["task_type"] != "pr"})
    n_pr_tasks = len({(r["project"], r["task"]) for r in runs if r["task_type"] == "pr"})
    n_syn_types = len({r["task_type"] for r in runs} - {"pr"})
    kind_tbl = kind_table(runs)
    n_langs = len({r["lang"] for r in runs} - {"css"})
    total_cost = sum(float(r["cost_usd"] or 0) for r in runs)
    excluded = sum(1 for r in runs if r["contaminated"] not in ("", "False", "false", "0"))

    def c_all(arm, outcome):
        return find(contrasts, stratum="all", outcome=outcome, contrast=contrast_name(arm, outcome))

    opt_s, enf_s = c_all("optional", "success (pp)"), c_all("enforced", "success (pp)")
    opt_c, enf_c = c_all("optional", "cost ratio"), c_all("enforced", "cost ratio")
    rev_c = c_all("baseline-review", "cost ratio")

    def flaw_txt(arm):
        f = c_all(arm, "flaws (mean diff)")
        return f"{float(f['estimate']):+.2f} flaws per run (95% interval {float(f['ci_lo']):+.2f} to {float(f['ci_hi']):+.2f})"
    flaw_enf_txt, flaw_opt_txt = flaw_txt("enforced"), flaw_txt("optional")
    def tag(_rs=None):
        """A "fewer flaws" tag only where the pre-registered paired contrast (all tasks) excludes zero; raw,
        unpaired means do not earn one. Strata have no paired flaw interval, so they get no tag."""
        f = c_all("optional", "flaws (mean diff)")
        return ' <span class="tag win">fewer flaws</span>' if f and float(f["ci_hi"]) < 0 else ""
    tag_kinds, tag_all, tag_kotlin, tag_java = "", tag(), "", ""

    def mean_flaws(kind, arm):
        """Raw mean over reviewed edit runs (answer tasks have no diff, so no flaw count). Returns (mean, reviewed runs)."""
        merge = {"intellij-optional": "optional", "intellij-enforced": "enforced"}
        v = [float(r["flaws"]) for r in runs if r["flaws"] not in ("", None)
             and (r["task_type"] == "pr") == (kind == "pr") and merge.get(r["arm"], r["arm"]) == arm]
        return sum(v) / len(v), len(v)
    fs = {(k, a): mean_flaws(k, a) for k in ("syn", "pr") for a in ("baseline", "optional", "enforced", "baseline-review")}
    flaw_summary = (
        f"<p>Paired on the same tasks, offering LS tools (optional) changes flaws by {flaw_opt_txt}: no clear difference. "
        f"Enforcing them changes flaws by {flaw_enf_txt}.</p>"
        f"<p class='note'>Raw means per reviewed edit run, not paired: synthetic edit tasks (rename, rename-file, move, "
        f"signature; navigation questions have no diff) {fs['syn', 'optional'][0]:.2f} optional against "
        f"{fs['syn', 'baseline'][0]:.2f} baseline ({fs['syn', 'optional'][1]} and {fs['syn', 'baseline'][1]} reviewed runs); "
        f"real PRs {fs['pr', 'optional'][0]:.2f} against {fs['pr', 'baseline'][0]:.2f}.</p>")
    arm_note = ("<p class='note'>Arms: baseline = no LS tools; optional = LS tools offered; enforced = the agent is told "
                "to use them (<a href=\"#setups\">details</a>).</p>")
    enf_c_txt = f"{float(enf_c['estimate']):.2f}"
    opus_adopt = f"{float(find(descriptive, model='claude-opus-5-5', arm='optional')['lsp_used']) * 100:.0f}%"
    outline = [("top", "Does LSP help Claude Code?"), ("what-is-being-tested", "What is being tested"), ("setups", "Setups"),
               ("kinds-of-tasks", "Kinds of tasks"), ("flaws", "LS tools do not reduce refactoring flaws"), ("success-barely-moves", "LS tools don't raise success rates"),
               ("no-model-solves-more", "No model solves more tasks with LS tools"),
               ("only-opus-uses-optional-tools", "Only Opus uses tools when they're optional"),
               ("cost-goes-up-when-lsp-use-is-enforced", "Cost goes up when LSP use is enforced"),
                              ("all-ls-together", "All LS together"), ("intellij-vs-kotlin-lsp-vs-no-ls", "IntelliJ vs kotlin-lsp vs no LS"),
               ("java-intellij-vs-no-ls", "Java: IntelliJ vs no LS"), ("raw-data", "Raw data")]
    outline_html = ("<nav class='outline'><b>Contents</b><ol>"
                    + "".join(f'<li><a href="#{i}">{esc(t)}</a></li>' for i, t in outline) + "</ol></nav>")

    headline = (
        f"Across {n_tasks} tasks, offering the LS (optional arm) changed success by "
        f"{signed(opt_s['estimate'])} points (interval {signed(opt_s['ci_lo'])} to {signed(opt_s['ci_hi'])}) at "
        f"{num(opt_c['estimate'])}× the baseline cost. Pushing the agent to use it (enforced arm) changed success by "
        f"{signed(enf_s['estimate'])} points (interval {signed(enf_s['ci_lo'])} to {signed(enf_s['ci_hi'])}) at "
        f"{num(enf_c['estimate'])}× the cost. A second review turn without any LS (baseline-review) cost "
        f"{num(rev_c['estimate'])}×."
    )

    # Chart 1: success difference vs baseline, per arm, all models.
    s_items, s_rows = [], []
    for arm in CHART_ARMS:
        r = c_all(arm, "success (pp)")
        if r:
            e, a, b = float(r["estimate"]), float(r["ci_lo"]), float(r["ci_hi"])
            s_items.append((arm, e, a, b, BLUE, f"{arm} vs baseline: {e:+.1f} pp (95% interval {a:+.1f} to {b:+.1f}), {r['tasks']} tasks"))
            s_rows.append([arm, f"{e:+.2f}", f"{a:+.2f} to {b:+.2f}", r["better"], r["same"], r["worse"], r["tasks"]])
    chart_success = forest(s_items, -10, 10, 0, lambda t: "0 pp" if t == 0 else f"{t:+g} pp", "Success difference against baseline")

    # Chart 2: cost ratio vs baseline, per arm.
    c_items, c_rows = [], []
    for arm in CHART_ARMS:
        r = c_all(arm, "cost ratio")
        if r:
            e, a, b = float(r["estimate"]), float(r["ci_lo"]), float(r["ci_hi"])
            c_items.append((arm, e, a, b, ORANGE, f"{arm} / baseline: {e:.2f}× cost (95% interval {a:.2f} to {b:.2f}), {r['tasks']} tasks"))
            c_rows.append([arm, f"{e:.2f}", f"{a:.2f} to {b:.2f}", r["better"], r["same"], r["worse"], r["tasks"]])
    chart_cost = forest(c_items, 0.75, 3, 1, lambda t: f"{t:g}×", "Cost ratio against baseline", log=True, higher_better=False)

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
    r_groups = []
    for m in MODELS:
        d = {a: find(descriptive, model=m, arm=a) for a in ("baseline", "optional", "enforced")}
        rows_ = []
        for arm in ("baseline", "optional", "enforced"):
            n, rate = int(d[arm]["runs"]), float(d[arm]["success"])
            a, b = wilson(round(rate * n), n)
            rows_.append((arm, 100 * rate, 100 * a, 100 * b, None,
                          f"{MODEL_NAME[m]}, {arm}: {100 * rate:.0f}% of {n} runs (95% interval {100 * a:.0f}% to {100 * b:.0f}%)"))
        r_groups.append((MODEL_NAME[m], rows_))
    chart_models = rate_groups(r_groups, 40, 100, "Success rate by model and arm")

    # Chart 4: LSP adoption, optional vs enforced.
    groups = []
    for m in MODELS:
        o = find(descriptive, model=m, arm="optional")
        e = find(descriptive, model=m, arm="enforced")
        groups.append((MODEL_NAME[m], [float(o["lsp_used"]), float(e["lsp_used"])]))
    best_opt = max(g[1][0] for g in groups)
    chart_adoption = '<div class="shelf">' + "".join(
        f'<div{' class="top"' if o == best_opt else ''}><div class="who">{esc(label)}</div>'
        f'<div class="nums">{usage(o, "optional").rsplit(" ", 1)[0]} <b>{o * 100:.0f}%</b> <span>optional</span></div>'
        f'<div class="nums">{usage(e, "enforced").rsplit(" ", 1)[0]} <b>{e * 100:.0f}%</b> <span>enforced</span></div></div>'
        for label, (o, e) in groups) + "</div>"

    k_tasks, k_runs, chart_kotlin, kotlin_table, k_zero = server_section(
        runs, lambda p: p.startswith(("kotlin-", "java-kotlin-")),
        [("baseline", "baseline (no LS)"), ("optional", "kotlin-lsp, optional"),
         ("enforced", "kotlin-lsp, enforced"), ("intellij-optional", "IntelliJ, optional"),
         ("intellij-enforced", "IntelliJ, enforced")],
        "Success difference against baseline on Kotlin tasks")
    a_tasks, a_runs, _, all_ls_table, _ = server_section(
        runs, lambda p: True,
        [("baseline", "baseline (no LS)"), ("optional", "optional, any LS"),
         ("enforced", "enforced, any LS")],
        "Success difference against baseline, all LS",
        merge={"intellij-optional": "optional", "intellij-enforced": "enforced"})
    j_tasks, j_runs, chart_java, java_table, j_zero = server_section(
        runs, lambda p: p.startswith("java-") and not p.startswith("java-kotlin-"),
        [("baseline", "baseline (no LS)"), ("intellij-optional", "IntelliJ, optional"),
         ("intellij-enforced", "IntelliJ, enforced")],
        "Success difference against baseline on Java tasks")

    flaws = rows("flaws.csv")
    kinds = [("leftover", "an old name, path or signature the change should have updated but did not (comments, docstrings, strings, docs, configuration)"),
             ("naming", "a new name that is inconsistent with the task or the surrounding code"),
             ("churn", "formatting or whitespace changes to lines the task did not need to touch"),
             ("dead", "code, imports or files the change left dead or unused"),
             ("unrelated", "edits to places that have nothing to do with the task")]
    flaw_table = table(["Kind", "What it is", "Reported", "Counted"],
                       [[k, d, sum(1 for f in flaws if f["kind"] == k), sum(1 for f in flaws if f["kind"] == k and f["counted"] == "yes")]
                        for k, d in kinds])
    n_counted = sum(1 for f in flaws if f["counted"] == "yes")
    dropped = collections.Counter(f["dropped_by"] for f in flaws if f["counted"] != "yes")
    # Real reports, picked by run id; the task line is a one-line summary of that task's prompt.
    examples = [
        ("Python", "r00260", "check-typevar-tuple.test", "rename mypy's module <code>typeops</code> to <code>type_operations</code>"),
        ("TypeScript", "r01482", "base64.ts", "rename the module <code>utils/encode</code> to <code>utils/base64</code>"),
        ("Kotlin", "r00415", "Planner.kt", "swap the two parameters of embabel's <code>Planner.planToGoal</code>"),
    ]
    flaw_examples = ""
    for lang, rid, fname, task in examples:
        f = next(x for x in flaws if x["run_id"] == rid and x["file"].endswith(fname) and x["counted"] == "yes")
        r = find(runs, run_id=rid)
        passed = "passed" if r["success"] == "True" else "failed"
        flaw_examples += (f'<p><b>{lang}.</b> The task: {task}. The run ({esc(MODEL_NAME[r["model"]])}, {esc(r["arm"])} arm) '
                          f'{passed} the tests, and the reviewer reported:</p>'
                          f'<pre><code>{esc(f["kind"])}  {esc(f["file"])}:{esc(f["line"])}\n{esc(f["reason"])}</code></pre>')

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
         "Share of runs using LSP", "Flaws per reviewed edit run"], desc_body)
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
        <meta name="description" content="Does LSP help Claude Code? Results of the LSP study." />
        <link rel="alternate" type="text/plain" href="llms.txt" title="llms.txt" />
        <title>LSP study: results</title>
        <meta name="color-scheme" content="light dark" />
        <style>
            :root {{ --bg: #fff; --ink: #222; --muted: #555; --grid: #ddd; --rule: #999; --faint: #aaa; --code: #f6f6f4;
                    --link: #1a0dab; --visited: #609; --blue: #2a78d6; --orange: #eb6834; --good: #2e9e6a; --okay: #d9a21b; --bad: #d14b3a;
                    --win: #d9f0e3; --mid: #fbefc4; --lose: #fbdcd3; }}
            @media (prefers-color-scheme: dark) {{
                :root {{ --bg: #1a1a19; --ink: #f0efec; --muted: #c3c2b7; --grid: #3a3a38; --rule: #77766f; --faint: #6b6a64;
                        --code: #262624; --link: #8ab4f8; --visited: #c58af9; --blue: #3987e5; --orange: #d95926; --good: #3fbf86; --okay: #e0b43a; --bad: #e5654f;
                        --win: #1f4a36; --mid: #574a14; --lose: #5c2a20; }}
            }}
            body {{ font-family: "IBM Plex Sans", "Helvetica Neue", Arial, sans-serif; font-size: 1rem; line-height: 1.6;
                   max-width: 720px; margin: 40px auto; padding: 0 20px; color: {INK}; background: var(--bg); }}
            h1 {{ font-size: 1.625rem; margin-bottom: 4px; }}
            h2 {{ font-size: 1.25rem; margin-top: 32px; margin-bottom: 8px; }}
            p, li {{ margin-bottom: 6px; }}
            ul {{ padding-left: 20px; }}
            a {{ color: var(--link); }}
            a:visited {{ color: var(--visited); }}
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
            .shelf > div.top {{ background: var(--win); }}
            .shelf .who {{ font-size: 0.8125rem; color: {MUTED}; }}
            .shelf .nums b {{ font-size: 1.375rem; }}
            .shelf .nums span {{ font-size: 0.8125rem; color: {MUTED}; }}
            .faint {{ color: var(--faint); font-size: 0.6875rem; margin-top: -6px; }}
            tr.join > td:nth-child(1), tr.join > td:nth-child(2) {{ border-bottom: none; }}
            nav.outline {{ position: sticky; top: 0; z-index: 10; background: var(--bg); font-size: 0.8125rem;
                          margin: 0 -20px 16px; padding: 8px 20px; border-bottom: 1px solid var(--grid); }}
            nav.outline b {{ display: none; }}
            nav.outline ol {{ display: flex; flex-wrap: wrap; gap: 2px 14px; list-style: none; margin: 0; padding: 0; }}
            nav.outline li {{ margin: 0; }}
            nav.outline a {{ color: {MUTED}; text-decoration: none; }}
            nav.outline a[href="#raw-data"] {{ color: var(--faint); }}
            nav.outline a.here {{ color: {INK}; font-weight: 600; }}
            @media (min-width: 1100px) {{
                body {{ max-width: 960px; }}
                .page > main {{ margin-left: 240px; }}
                .page > nav {{ position: fixed; top: 40px; left: max(16px, calc(50% - 480px)); width: 200px;
                              margin: 0; padding: 0; border: none; background: none; }}
                nav.outline b {{ display: block; margin-bottom: 4px; }}
                nav.outline ol {{ flex-direction: column; gap: 0; }}
                nav.outline li {{ border-bottom: 1px solid var(--grid); padding: 5px 0; }}
                nav.outline li:last-child {{ border-bottom: none; }}
            }}
            h2 .tag {{ font-size: 0.75rem; font-weight: 600; vertical-align: middle; padding: 2px 8px; border-radius: 10px; white-space: nowrap; }}
            .term {{ border-bottom: 1px dotted currentColor; cursor: help; position: relative; }}
            .term:hover::after, .term:focus::after {{ content: attr(data-tip); position: absolute; left: 0; top: 100%;
                   margin-top: 4px; width: max-content; max-width: 260px; white-space: normal; z-index: 10;
                   background: var(--ink); color: var(--bg); font-size: 0.75rem; font-weight: 400; line-height: 1.4;
                   padding: 6px 8px; border-radius: 4px; text-align: left; pointer-events: none; }}
            .term:focus {{ outline: none; }}
            .win {{ background: var(--win); padding: 1px 5px; border-radius: 3px; }}
            .mid {{ background: var(--mid); padding: 1px 5px; border-radius: 3px; }}
            .lose {{ background: var(--lose); padding: 1px 5px; border-radius: 3px; }}
            svg.use {{ vertical-align: -2px; }}
            .legend span {{ margin-right: 16px; white-space: nowrap; }}
            details {{ margin: 4px 0 20px; }}
            summary {{ cursor: pointer; color: {MUTED}; font-size: 0.875rem; }}
            table {{ border-collapse: collapse; width: 100%; font-size: 0.8125rem; margin: 10px 0; }}
            th, td {{ border-bottom: 1px solid {GRID}; padding: 5px 7px; text-align: left; vertical-align: top; }}
            th {{ border-bottom: 2px solid var(--rule); }}
            pre {{ background: var(--code); padding: 10px 12px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; font-size: 0.75rem; line-height: 1.45; }}
            code {{ font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 0.875em; }}
            dt {{ font-weight: 700; margin-top: 10px; }}
            dd {{ margin: 2px 0 0 0; }}
            footer p {{ font-size: 0.8125rem; color: {MUTED}; }}
            @media (max-width: 480px) {{ body {{ margin-block: 24px; padding-inline: 16px; }} table {{ font-size: 0.75rem; }} }}
        </style>
    </head>
    <body>
    <div class="page">
        {outline_html}
        <main>
        <h1 id="top">Does LSP help Claude Code?</h1>
        <p class="subtitle">{n_runs:,} runs, {n_tasks} tasks, {n_projects} projects, three Claude models, {n_langs} programming languages.</p>

        <h2 id="what-is-being-tested">What is being tested</h2>
        <p><a href="https://github.com/CommanderTvis/tereditor">tereditor</a> gives a coding agent a project's
        language server (LS) over <a href="https://modelcontextprotocol.io">MCP</a> (Pyright for Python, clangd for C and
        C++, <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a> for Kotlin, and so on), and can serve
        IntelliJ's language server instead for Java and Kotlin, which the study tests as a separate contestant. Does that make
        Claude Code solve more tasks, cheaper or faster?</p>
        <details>
        <summary>MCP tools and an example call</summary>
        <p>MCP tools:</p>
        <dl>
            <dt><code>lsp_navigate</code></dt>
            <dd>Definitions, references, implementations, symbols, callers and callees.</dd>
            <dt><code>lsp_diagnostics</code></dt>
            <dd>Errors in edited files or the whole workspace.</dd>
            <dt><code>lsp_rename</code>, <code>lsp_code_actions</code>, <code>lsp_format</code></dt>
            <dd>Rename a symbol or move a file, apply quick fixes and refactorings, format. Preview first.</dd>
            <dt><code>lsp_status</code></dt>
            <dd>The servers and what they support.</dd>
        </dl>
        <p>The server runs in its own sandbox, so these arms get no compiler the baseline lacks.</p>
        <p>A call from the run (Haiku, Python): every reference to a class.</p>
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
        <p class="faint">Run r00023 (task refs-payment-card-number, python-small, enforced arm).</p>
        </details>

        <h2 id="setups">Setups</h2>
        <p>Same agent, same task, no compiler. Only the LS tools change.</p>
        <dl>
            <dt>baseline</dt>
            <dd>No LS. Plain Claude Code: read, edit, shell (grep).</dd>
            <dt>optional</dt>
            <dd>LS tools available. The agent may use them or not.</dd>
            <dt>enforced</dt>
            <dd>LS tools available, and the agent is told and nudged by hooks to use them.</dd>
        </dl>
        <p class="faint" style="margin-top: 0">Also in the charts: the IntelliJ versions of optional and enforced, where IntelliJ is the LS (Java and Kotlin projects
        only). On Kotlin this compares IntelliJ with <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a>, which the plain optional and enforced arms use.</p>

        <h2 id="kinds-of-tasks">Kinds of tasks{tag_kinds}</h2>
        <p><b>Synthetic</b> ({n_syn_tasks} tasks, {n_syn_types} types: rename, rename-file, move, signature, refs,
        callers, impls, dispatch, inspect). A short, precise change or question about a real open-source project.
        Example: <i>{esc(EX_SYN)}</i></p>
        <p><b>Real PRs</b> ({n_pr_tasks} tasks). Mined from real pull requests: the prompt is the issue text, and the
        tests come from the PR. Example: <i>{esc(EX_PR)}</i></p>
        {kind_tbl}
        <p class="note">Flaws are counted on edit runs only, so the synthetic flaw mean covers rename, rename-file, move
        and signature tasks (navigation questions have no diff to review), and the number in brackets is the count of
        reviewed runs behind it, not the Runs column. These are raw means; the paired comparison is under
        <a href="#flaws">Flaws</a>.</p>
        <p>The results below compare three outcomes between arms on the same tasks: the flaws a run leaves, whether it
        succeeds, and what it costs.</p>

        <h2 id="flaws">LS tools do not reduce refactoring flaws{tag_all}</h2>
        {flaw_summary}
        {arm_note}
        <p>Tests decide whether a change works. A flaw is damage the tests cannot see. After each edit run, a reviewer
        (Haiku 5.5) reads the diff and searches the edited tree for five kinds of it;
        {len(flaws)} were reported in all, {n_counted} of them confirmed by the re-check below.</p>
        {flaw_table}
        {spoiler("Examples from the run", flaw_examples)}
        <h3 id="flaws-rechecked">Flaw counts re-checked</h3>
        <p>The first reviewer (Haiku 5.5) flagged far too much, so a second model (Opus 5.5) re-checked each of its
        {len(flaws)} flaws without knowing which setup produced the run. Only the {n_counted} it confirmed are counted on
        this page. The rest were mostly harmless formatting on lines the change had to touch anyway, such as import
        order ({dropped["formatting_changed_line"]}), the same mistake repeated across files
        ({dropped["duplicate"]}), or simply wrong ({dropped["wrong"]}). No human has checked the confirmed flaws yet.
        Details: <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/main/analysis/recheck_flaws.py">the check</a>,
        <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/flaws.csv">every flaw with its verdict</a>.</p>

        <h2 id="success-barely-moves">LS tools don't raise success rates</h2>
        {arm_note}
        <p>A run succeeds when an automatic grader accepts the result. For real PRs the grader runs the tests from the
        pull request. For synthetic tasks it checks the change with a build and tests, or, for questions, compares the
        written answer with the known one. Success rate is the share of runs that pass.</p>
        <p>Change in success rate against the baseline arm, all models pooled. The dashed line is no change. Colours: green best, red worst, yellow in between. Bars show 95% intervals.</p>
        {chart_success}
        {spoiler("Show the numbers", table(hdr, s_rows))}

        <h2 id="no-model-solves-more">No model solves more tasks with LS tools</h2>
        <p>Success rate of each arm, for each model. The dashed line is that model's baseline. Colours rank the arms within each model: green best, red worst, yellow in between.</p>
        {chart_models}
        {spoiler("Show the numbers", table(["Model", "Arm", "Estimate (pp)", "Interval (95%)", "Tasks"], m_rows))}

        <h2 id="only-opus-uses-optional-tools">Only Opus uses tools when they're optional</h2>
        <p>Share of runs that called at least one LS tool. With optional tools Haiku and Sonnet never call them, and Opus does in {opus_adopt} of runs. When enforced, all three use them in most runs.</p>
        {chart_adoption}

        <h2 id="cost-goes-up-when-lsp-use-is-enforced">Cost goes up when LSP use is enforced</h2>
        <p>Enforced runs cost about {enf_c_txt}× the baseline; optional runs about the same. Cost of each arm as a multiple of the baseline (log scale). The dashed line is equal cost.</p>
        {chart_cost}
        {spoiler("Show the numbers", table(hdr, c_rows))}

        <h2 id="all-ls-together">All LS together{tag_all}</h2>
        <p>Success, cost, time, adoption and flaws for each arm, pooled over all language servers: the IntelliJ runs are counted with optional and enforced.
        {a_tasks} tasks, {a_runs:,} runs.</p>
        {all_ls_table}

        <h2 id="intellij-vs-kotlin-lsp-vs-no-ls">IntelliJ vs kotlin-lsp vs no LS{tag_kotlin}</h2>
        <p>The {k_tasks} Kotlin and mixed Java+Kotlin tasks ran with both LS:
        <a href="https://github.com/Kotlin/kotlin-lsp">kotlin-lsp</a> (the optional and enforced arms) and IntelliJ
        (the intellij arms), {k_runs} runs in all. Success change against the baseline on these tasks:</p>
        {chart_kotlin}
        {kotlin_table}
        <p class="note">{k_tasks} tasks is a small sample: the intervals are wide, and {k_zero}. Cost and time are medians over all three models.</p>

        <h2 id="java-intellij-vs-no-ls">Java: IntelliJ vs no LS{tag_java}</h2>
        <p>On the {j_tasks} pure Java tasks IntelliJ is the only LS (tereditor has no other headless
        Java server), so the comparison is IntelliJ against the baseline, {j_runs} runs in all.</p>
        {chart_java}
        {java_table}
        <p class="note">{j_tasks} tasks is a small sample: the intervals are wide, and {j_zero}. Cost and time are
        medians over all three models.</p>

        <h2 id="raw-data">Raw data</h2>
        {spoiler("Arms by model", desc_table)}
        {spoiler("Contrasts by model", strat_table(by_model))}
        {spoiler("Contrasts by language", strat_table(by_lang))}
        {spoiler("Contrasts by project size", strat_table(by_size))}
        {spoiler("Contrasts by task type", strat_table(by_task))}
        {spoiler("Contrasts by memorization probe score", strat_table(by_probe))}
        <ul>
            <li><a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/runs.csv">runs.csv</a>: one row per run</li>
            <li><a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/plan.tsv">plan.tsv</a>: the seeded run plan</li>
            <li><a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/flaws.csv">flaws.csv</a>: every flaw the reviewer reported</li>
            <li><a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/descriptive.csv">descriptive.csv</a>, <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/contrasts.csv">contrasts.csv</a>,
                <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/by_model.csv">by_model.csv</a>, <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/by_lang.csv">by_lang.csv</a>,
                <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/by_size.csv">by_size.csv</a>, <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/by_task_type.csv">by_task_type.csv</a>,
                <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/data/by_probe_half.csv">by_probe_half.csv</a></li>
            
        </ul>

        <footer>
            <p>Generated by <a href="https://github.com/CommanderTvis/tereditor-lsp-research/blob/gh-pages/build_site.py">build_site.py</a> from the files in <a href="https://github.com/CommanderTvis/tereditor-lsp-research/tree/gh-pages/data">data/</a>.</p>
        </footer>
        <script>
            const links = {{}};
            document.querySelectorAll("nav.outline a").forEach(a => links[a.hash.slice(1)] = a);
            const heads = [...document.querySelectorAll("h1[id], h2[id]")];
            let picked = null;  // set by a click on the outline, kept until the reader scrolls by hand
            function mark() {{
                // the last heading that has reached the upper part of the window
                const line = window.innerHeight * 0.3;
                let current = heads[0];
                heads.forEach(h => {{ if (h.getBoundingClientRect().top <= line) current = h; }});
                if (picked) current = picked;
                Object.values(links).forEach(a => a.classList.remove("here"));
                if (current && links[current.id]) links[current.id].classList.add("here");
            }}
            Object.values(links).forEach(a => a.addEventListener("click", () => {{
                picked = document.getElementById(a.hash.slice(1));
                mark();
            }}));
            ["wheel", "touchmove", "keydown"].forEach(t => addEventListener(t, () => {{ picked = null; }}, {{ passive: true }}));
            addEventListener("scroll", mark, {{ passive: true }});
            addEventListener("resize", mark);
            mark();
        </script>
        </main>
    </div>
    </body>
</html>
"""
    OUT.write_text(page, encoding="utf-8")

    llms = f"""# LSP study: does LSP help Claude Code?

> A controlled comparison of Claude Code agents with and without language-server (LSP) tools: {n_runs:,} runs on {n_tasks} tasks in {n_projects} projects, three Claude models (Haiku 5.5, Sonnet 5.5, Opus 5.5), {n_langs} programming languages. {headline}

What is tested: tereditor (https://github.com/CommanderTvis/tereditor), an IDE-like workbench for terminal coding agents whose headless build serves a project's language server to an agent over MCP. Its six tools: lsp_navigate (definitions, references, implementations, symbols, call hierarchies, one read-only LSP query), lsp_diagnostics (errors for edited files or the workspace), lsp_rename, lsp_code_actions and lsp_format (preview before writing, workspace only), lsp_status (servers and capabilities). Example call: lsp_navigate {{"operation": "references", "query": "PaymentCardNumber", "workspace": "/workspace"}} returns the reference locations with zero-based lines and previews.

Arms: baseline (Claude Code core tools only: Read, Edit, Write, Bash, Task, ToolSearch); baseline-review (baseline plus a second review turn); optional (LSP tools offered, not required); enforced (LSP use pushed by prompt and hooks); intellij-optional and intellij-enforced (IntelliJ as the language server, JVM projects only; on Kotlin the plain optional and enforced arms use https://github.com/Kotlin/kotlin-lsp). Success is a deterministic grader's pass rate; cost is Claude Code's total_cost_usd. Contrasts are paired on tasks; intervals are 95% task-resampling intervals.

## Findings

- Success: offering LS tools (optional) and enforcing them (enforced) do not change the pass rate by a clear amount. Both intervals include zero.
- Flaws: paired on the same tasks, optional LS tools change flaws by {flaw_opt_txt}, no clear difference. Enforced LS use leaves more: {flaw_enf_txt}.
- Cost: optional costs about the same as baseline; enforced costs about {enf_c_txt} times as much.
- Adoption: when offered, the agent uses LS tools in {opus_adopt} of optional runs on Opus and in none on Haiku or Sonnet.
- Task kinds: {n_syn_tasks} synthetic tasks ({n_syn_types} types) and {n_pr_tasks} real pull-request tasks. Both are reported separately on the page.
- Java and Kotlin: the sample is small (12 pure Java tasks, {k_tasks} Kotlin and mixed tasks); every interval includes zero.

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
