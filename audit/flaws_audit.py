"""Exploratory audit of the flaw outcome (not part of the pre-registered analysis).

Reads the restored run directories of a plan and writes data/flaws_audit.json for build_site.py:
  - pooled and per-kind flaw means with their denominators (reviewed edit runs, not all runs);
  - optional vs baseline, paired by (task, model), with and without the runs that called LS tools, per model and kind,
    with a task-resampling interval, the tasks that drive the difference and robustness checks;
  - what reaches the session unasked (hooks, code diagnostics, orphan tool results) per arm;
  - what reaches the flaw reviewer per arm (LS artifact files in the reviewed diff), and reviews skipped per arm;
  - the TypeORM signature task: the same stale JSDoc counted 10 or 0 times by the reviewer.

Usage (standard library only):  uv run --no-project python audit/flaws_audit.py <results/main> [data/flaws_audit.json]
"""

import collections
import csv
import json
import os
import random
import re
import statistics
import sys

ANSWER_TYPES = {"refs", "impls", "dispatch", "callers", "inspect"}
MERGE = {"intellij-optional": "optional", "intellij-enforced": "enforced"}
MODELS = ["claude-haiku-5-5", "claude-sonnet-5-5", "claude-opus-5-5"]
ARTIFACT = re.compile(r"(^|/)(\.project|\.classpath|\.factorypath|\.settings/|\.idea/|\.vscode/|compile_commands\.json|"
                      r"pyrightconfig\.json|\.tereditor)")


def kind(r):
    return "pr" if r["task_type"] == "pr" else "syn"


def zero_call(r):
    return r["lsp_calls"] in ("0", "", "0.0")


def mean_or_none(v):
    return round(sum(v) / len(v), 3) if v else None


def paired(runs, opt_arms, only_zero, models=None, kinds=None, metric=lambda x: x, exclude_tasks=(), seed=1, boots=4000):
    """Optional minus baseline flaws, paired on (task, model) cells (repetitions averaged), resampled by task."""
    cells = collections.defaultdict(lambda: collections.defaultdict(list))
    for r in runs:
        if r["flaws"] == "" or r["task"] in exclude_tasks:
            continue
        if models and r["model"] not in models or kinds and kind(r) not in kinds:
            continue
        side = "base" if r["arm"] == "baseline" else ("opt" if r["arm"] in opt_arms else None)
        if side is None or side == "opt" and only_zero and not zero_call(r):
            continue
        cells[(r["project"], r["task"], r["model"])][side].append(metric(float(r["flaws"])))
    pairs = {k: (statistics.mean(v["base"]), statistics.mean(v["opt"])) for k, v in cells.items() if v["base"] and v["opt"]}
    by_task = collections.defaultdict(list)
    for (p, t, _), (b, o) in pairs.items():
        by_task[(p, t)].append(o - b)
    tasks = sorted(by_task)
    if not tasks:
        return None

    def est(ts):
        d = [x for t in ts for x in by_task[t]]
        return sum(d) / len(d)

    rng = random.Random(seed)
    dist = sorted(est([rng.choice(tasks) for _ in tasks]) for _ in range(boots))
    per_task = {f"{p}/{t}": statistics.mean(v) for (p, t), v in by_task.items()}
    return {"tasks": len(tasks), "cells": len(pairs),
            "baseline": round(statistics.mean(b for b, _ in pairs.values()), 3),
            "optional": round(statistics.mean(o for _, o in pairs.values()), 3),
            "diff": round(est(tasks), 3), "ci_lo": round(dist[int(0.025 * boots)], 3), "ci_hi": round(dist[int(0.975 * boots) - 1], 3),
            "better": sum(v < 0 for v in per_task.values()), "same": sum(v == 0 for v in per_task.values()),
            "worse": sum(v > 0 for v in per_task.values()), "per_task": per_task}


def need(p):
    """A paired result that must exist (the strata used below always have pairs)."""
    if p is None:
        raise ValueError("no paired cells")
    return p


def summary(p):
    return {k: v for k, v in need(p).items() if k != "per_task"}


def stream_events(path):
    with open(path, errors="replace") as fh:
        for line in fh:
            try:
                yield json.loads(line)
            except ValueError:
                continue


def injected(base, rid):
    """Content that reached the agent without it asking: hook events, code diagnostics, tool results with no call."""
    out = collections.Counter()
    uses, results = set(), []
    for e in stream_events(f"{base}/runs/{rid}/stream.jsonl"):
        if e.get("type") == "system" and str(e.get("subtype", "")).startswith("hook_"):
            out["hook_events"] += 1
        m = e.get("message") or {}
        d = m.get("diagnostics")
        if d is not None and "cache_miss_reason" not in json.dumps(d):  # API cache notes are not code diagnostics
            out["code_diagnostics"] += 1
        for it in m.get("content") or [] if isinstance(m.get("content"), list) else []:
            if it.get("type") == "tool_use":
                uses.add(it["id"])
            elif it.get("type") == "tool_result":
                results.append(it.get("tool_use_id"))
    out["orphan_tool_results"] = sum(1 for x in results if x not in uses)
    return out


def main(base, out_path):
    runs = list(csv.DictReader(open(f"{base}/runs.csv", newline="", encoding="utf-8")))
    by_id = {r["run_id"]: r for r in runs}
    res = {}

    # 1. Denominators: the flaw mean is over reviewed edit runs; answer tasks have no diff and no flaw count.
    den = {}
    for arm in ("baseline", "optional", "enforced"):
        rs = [r for r in runs if MERGE.get(r["arm"], r["arm"]) == arm]
        row = {}
        for k, pick in (("all", lambda r: True), ("syn", lambda r: kind(r) == "syn"), ("pr", lambda r: kind(r) == "pr")):
            sub = [r for r in rs if pick(r)]
            v = [float(r["flaws"]) for r in sub if r["flaws"] != ""]
            row[k] = {"runs": len(sub), "reviewed": len(v), "mean": mean_or_none(v)}
        row["weighted_by_all_runs"] = round((row["syn"]["mean"] * row["syn"]["runs"] + row["pr"]["mean"] * row["pr"]["runs"])
                                            / (row["syn"]["runs"] + row["pr"]["runs"]), 3)
        den[arm] = row
    res["denominators"] = den
    res["review_status"] = {}
    for r in runs:
        if r["task_type"] in ANSWER_TYPES:
            continue
        p = f"{base}/runs/{r['run_id']}/review/result.json"
        d = json.load(open(p)) if os.path.exists(p) else {}
        st = ("skipped: " + d["skipped"]) if d.get("skipped") else ("unparsed" if d.get("parsed") is False else
                                                                     ("reviewed" if d.get("flaws") is not None else "missing"))
        res["review_status"].setdefault(r["arm"], collections.Counter())[st] += 1

    # 2. Optional vs baseline, paired, all runs and zero-call runs.
    pc = []
    for arms, label in (({"optional"}, "optional"), ({"intellij-optional"}, "intellij-optional"),
                        ({"optional", "intellij-optional"}, "optional + intellij-optional")):
        for only_zero in (False, True):
            for kinds, kl in ((None, "all"), ({"syn"}, "syn"), ({"pr"}, "pr")):
                p = paired(runs, arms, only_zero, kinds=kinds)
                if p:
                    pc.append({"arm": label, "runs": "zero LS calls" if only_zero else "all", "kind": kl,
                               **{k: v for k, v in p.items() if k != "per_task"}})
    res["paired"] = pc
    res["paired_by_model_zero_call"] = []
    for m in MODELS:
        for kinds, kl in ((None, "all"), ({"syn"}, "syn"), ({"pr"}, "pr")):
            res["paired_by_model_zero_call"].append(
                {"model": m, "kind": kl, **summary(paired(runs, {"optional"}, True, models={m}, kinds=kinds))})
    syn = need(paired(runs, {"optional"}, True, kinds={"syn"}))
    drivers = sorted(syn["per_task"].items(), key=lambda x: x[1])
    res["drivers"] = {"sum_of_task_diffs": round(sum(syn["per_task"].values()), 3),
                      "most_negative": [[t, round(v, 3)] for t, v in drivers[:5]],
                      "most_positive": [[t, round(v, 3)] for t, v in drivers[-3:]]}
    top = drivers[0][0].split("/", 1)[1]
    res["robustness"] = [
        {"check": "flaw count", **summary(syn)},
        {"check": f"flaw count, without {top}", **summary(paired(runs, {"optional"}, True, kinds={"syn"}, exclude_tasks=(top,)))},
        {"check": "any flaw (0/1)", **summary(paired(runs, {"optional"}, True, kinds={"syn"}, metric=lambda x: 1.0 if x > 0 else 0.0))},
        {"check": "flaw count capped at 3", **summary(paired(runs, {"optional"}, True, kinds={"syn"}, metric=lambda x: min(x, 3.0)))},
    ]

    # 3. What reaches the session unasked, per arm.
    inj = collections.defaultdict(collections.Counter)
    for r in runs:
        c = injected(base, r["run_id"])
        inj[r["arm"]]["runs"] += 1
        for k, v in c.items():
            inj[r["arm"]][k] += v
        inj[r["arm"]]["runs_with_hooks"] += 1 if c["hook_events"] else 0
    res["injected"] = {a: dict(c) for a, c in inj.items()}

    # 4. What reaches the reviewer: LS artifact files in the reviewed diff.
    art = collections.defaultdict(lambda: {"reviewed": 0, "with_artifacts": 0, "artifact_run_flaws": 0.0, "run_ids": []})
    for r in runs:
        p = f"{base}/runs/{r['run_id']}/review/patch.reviewed.diff"
        if not os.path.exists(p):
            continue
        a = art[r["arm"]]
        a["reviewed"] += 1
        paths = re.findall(r"^diff --git a/(\S+)", open(p, errors="replace").read(), re.M)
        if any(ARTIFACT.search(x) for x in paths):
            a["with_artifacts"] += 1
            a["run_ids"].append(r["run_id"])
            a["artifact_run_flaws"] += float(r["flaws"] or 0)
    res["reviewer_artifacts"] = dict(art)
    bad = set(art["enforced"]["run_ids"]) if "enforced" in art else set()
    for scope, arms in (("enforced", {"enforced"}), ("enforced + intellij-enforced", {"enforced", "intellij-enforced"})):
        v = [float(r["flaws"]) for r in runs if r["arm"] in arms and r["flaws"] != ""]
        v2 = [float(r["flaws"]) for r in runs if r["arm"] in arms and r["flaws"] != "" and r["run_id"] not in bad]
        res.setdefault("enforced_without_artifacts", []).append(
            {"scope": scope, "mean": mean_or_none(v), "reviewed": len(v), "mean_without": mean_or_none(v2), "reviewed_without": len(v2)})

    # 5. The task that drives the difference: was the JSDoc updated, and what did the reviewer count?
    rows = []
    for r in runs:
        if r["task"] != top.split("/")[-1] or r["flaws"] == "":
            continue
        d = open(f"{base}/runs/{r['run_id']}/review/patch.reviewed.diff", errors="replace").read()
        rows.append({"run_id": r["run_id"], "arm": r["arm"], "model": r["model"], "lsp_calls": r["lsp_calls"],
                     "jsdoc_param_lines_changed": len(re.findall(r"^[+-]\s*\*\s*@param", d, re.M)), "flaws": float(r["flaws"])})
    res["driver_task"] = {"task": top, "runs": sorted(rows, key=lambda x: (x["jsdoc_param_lines_changed"] > 0, x["flaws"]))}

    json.dump(res, open(out_path, "w"), indent=1, default=dict)
    print(f"wrote {out_path}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(__file__), "..", "data", "flaws_audit.json"))
