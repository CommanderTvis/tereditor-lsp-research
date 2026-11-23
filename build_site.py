"""Builds index.html from the study's result datasets in data/. Standard library only.

Run from the repository root:  uv run --no-project python build_site.py
Every number on the page is read from data/, never typed in.
"""

import csv
import html
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent
DATA = ROOT / "data"
OUT = ROOT / "index.html"

KEY_CONTRASTS = [
    "optional - baseline",
    "enforced - baseline",
    "baseline-review - baseline",
    "intellij-optional - baseline",
    "intellij-enforced - baseline",
]


def rows(name):
    with open(DATA / name, newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def num(x, digits=2):
    return f"{float(x):.{digits}f}"


def signed(x, digits=1):
    return f"{float(x):+.{digits}f}"


def esc(x):
    return html.escape(str(x))


def table(headers, body):
    head = "".join(f"<th>{esc(h)}</th>" for h in headers)
    lines = []
    for r in body:
        lines.append("<tr>" + "".join(f"<td>{esc(c)}</td>" for c in r) + "</tr>")
    return f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(lines)}</tbody></table>"


def find(rs, **kw):
    for r in rs:
        if all(r.get(k) == v for k, v in kw.items()):
            return r
    raise KeyError(kw)


def main():
    runs = rows("runs.csv")
    contrasts = rows("contrasts.csv")
    descriptive = rows("descriptive.csv")
    by_model = rows("by_model.csv")
    by_lang = rows("by_lang.csv")
    by_size = rows("by_size.csv")
    by_probe = rows("by_probe_half.csv")

    n_runs = len(runs)
    n_projects = len({r["project"] for r in runs})
    n_tasks = len({(r["project"], r["task"]) for r in runs})
    total_cost = sum(float(r["cost_usd"] or 0) for r in runs)
    excluded = sum(1 for r in runs if r["contaminated"] not in ("", "False", "false", "0"))

    def c_all(outcome, contrast):
        return find(contrasts, stratum="all", outcome=outcome, contrast=contrast)

    opt_s = c_all("success (pp)", "optional - baseline")
    enf_s = c_all("success (pp)", "enforced - baseline")
    enf_c = c_all("cost ratio", "enforced / baseline")
    opt_c = c_all("cost ratio", "optional / baseline")
    rev_c = c_all("cost ratio", "baseline-review / baseline")

    headline = (
        f"Across {n_tasks} tasks, the optional arm changed success by {signed(opt_s['estimate'])} points "
        f"(interval {signed(opt_s['ci_lo'])} to {signed(opt_s['ci_hi'])}) and cost {num(opt_c['estimate'])} times the "
        f"baseline. The enforced arm changed success by {signed(enf_s['estimate'])} points "
        f"(interval {signed(enf_s['ci_lo'])} to {signed(enf_s['ci_hi'])}) and cost {num(enf_c['estimate'])} times the "
        f"baseline. The baseline-review arm cost {num(rev_c['estimate'])} times the baseline."
    )

    desc_rows = [
        [r["model"], r["arm"], r["runs"], num(r["success"], 3), f"{float(r['mean_cost_usd']):.4f}",
         f"{float(r['median_cost_usd']):.4f}", num(r["median_wall_s"], 1), num(r["lsp_used"], 2), num(r["mean_flaws"], 2)]
        for r in descriptive
    ]
    desc_table = table(
        ["Model", "Arm", "Runs", "Success", "Mean cost (USD)", "Median cost (USD)", "Median wall time (s)",
         "Share of runs using LSP", "Mean flaws"],
        desc_rows,
    )

    all_rows = [
        [r["contrast"], r["outcome"], signed(r["estimate"], 2) if "pp" in r["outcome"] else num(r["estimate"]),
         f"{num(r['ci_lo'])} to {num(r['ci_hi'])}", r["tasks"]]
        for r in contrasts
        if r["stratum"] == "all" and r["contrast"] in KEY_CONTRASTS
    ]
    all_table = table(["Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"], all_rows)

    def strat_rows(rs, label):
        out = []
        for r in rs:
            if r["contrast"] in KEY_CONTRASTS and r["outcome"] in ("success (pp)", "cost ratio"):
                est = signed(r["estimate"], 2) if "pp" in r["outcome"] else num(r["estimate"])
                out.append([r["stratum"].replace("_", " "), r["contrast"], r["outcome"], est,
                            f"{num(r['ci_lo'])} to {num(r['ci_hi'])}" if r["ci_lo"] else "", r["tasks"]])
        return out

    model_table = table(["Stratum", "Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"],
                        strat_rows(by_model, "model"))
    lang_table = table(["Stratum", "Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"],
                       strat_rows(by_lang, "lang"))
    size_table = table(["Stratum", "Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"],
                       strat_rows(by_size, "size"))
    probe_table = table(["Stratum", "Contrast", "Outcome", "Estimate", "Interval (95%)", "Tasks"],
                        strat_rows(by_probe, "probe"))

    page = f"""<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="Does a language server make a Claude Code agent better, faster or cheaper? Results of the LSP study confirmatory run." />
        <title>LSP study: results</title>
        <style>
            body {{ font-family: "IBM Plex Sans", "Helvetica Neue", Arial, sans-serif; font-size: 1rem; line-height: 1.6;
                   max-width: 720px; margin: 40px auto; padding: 0 20px; color: #222; }}
            h1 {{ font-size: 1.625rem; margin-bottom: 4px; }}
            h2 {{ font-size: 1.25rem; margin-top: 32px; margin-bottom: 8px; }}
            p, li {{ margin-bottom: 6px; }}
            ul {{ padding-left: 20px; }}
            a {{ color: #1a0dab; }}
            a:visited {{ color: #609; }}
            a:focus-visible {{ outline: 3px solid currentColor; outline-offset: 3px; }}
            hr {{ border: none; border-top: 1px solid #ccc; margin: 24px 0; }}
            .subtitle {{ color: #555; font-size: 0.9375rem; margin-top: 0; }}
            table {{ border-collapse: collapse; width: 100%; font-size: 0.8125rem; margin: 12px 0 20px; }}
            th, td {{ border-bottom: 1px solid #ddd; padding: 5px 7px; text-align: left; vertical-align: top; }}
            th {{ border-bottom: 2px solid #999; }}
            footer p {{ font-size: 0.8125rem; color: #555; }}
            @media (max-width: 480px) {{ body {{ margin-block: 24px; padding-inline: 16px; }} table {{ font-size: 0.75rem; }} }}
        </style>
    </head>
    <body>
        <h1>Does a language server make a Claude Code agent better, faster or cheaper?</h1>
        <p class="subtitle">Results of the confirmatory run: {n_runs:,} runs, {n_tasks} tasks, {n_projects} projects, three Claude models, five arms.</p>

        <h2>Headline</h2>
        <p>{esc(headline)}</p>
        <p>Total spend recorded in the runs was USD {total_cost:,.2f}. Runs excluded by the contamination check: {excluded}.</p>

        <h2>Arms by model</h2>
        {desc_table}

        <h2>Paired contrasts across all tasks</h2>
        <p>Each contrast is paired on the tasks both arms ran. The interval is a task-resampling interval.</p>
        {all_table}

        <h2>Contrasts by model</h2>
        {model_table}

        <h2>Contrasts by language</h2>
        {lang_table}

        <h2>Contrasts by project size</h2>
        {size_table}

        <h2>Contrasts by memorization probe score</h2>
        <p>Tasks are split at the median probe score (how easy the fix is to derive from the issue alone).</p>
        {probe_table}

        <h2>Data</h2>
        <ul>
            <li><a href="data/runs.csv">runs.csv</a>: one row per run</li>
            <li><a href="data/plan.tsv">plan.tsv</a>: the seeded run plan</li>
            <li><a href="data/descriptive.csv">descriptive.csv</a>, <a href="data/contrasts.csv">contrasts.csv</a>, <a href="data/by_model.csv">by_model.csv</a>, <a href="data/by_lang.csv">by_lang.csv</a>, <a href="data/by_size.csv">by_size.csv</a>, <a href="data/by_task_type.csv">by_task_type.csv</a>, <a href="data/by_probe_half.csv">by_probe_half.csv</a></li>
        </ul>

        <footer>
            <p>Generated by build_site.py from the files in data/.</p>
        </footer>
    </body>
</html>
"""
    OUT.write_text(page, encoding="utf-8")
    print(f"wrote {OUT} ({len(page):,} bytes)")


if __name__ == "__main__":
    main()
