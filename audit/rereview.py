"""Exploratory: re-review a stratified sample of edit runs with a second reviewer (Opus 5.5) and a control (Haiku 5.5),
both on the same rebuilt trees, with the study's reviewer prompt. Not part of the pre-registered analysis.

The original reviews ran in the study's Linux sandbox; here the tree is rebuilt on the operator's machine:
the project at the task's commit (shallow fetch, agent-instruction files stripped as harness/env/project.sh does,
without the server-side prepare.sh), the task's setup.patch, then the exact diff the original reviewer saw
(review/patch.reviewed.diff). The reviewer gets Read, Grep and Glob only (no Bash), runs with
--setting-sources project, no MCP servers and no session persistence, and the prompt's /workspace and /in/... paths
are replaced by the rebuilt paths. Nothing else in the prompt changes. The Haiku control on the same trees separates
the reviewer from the environment change.

Usage (standard library only):
  python audit/rereview.py sample  <study checkout> <results/main>          -> data/rereview_sample.csv
  python audit/rereview.py run     <study checkout> <results/main> <model> [--limit N] [--budget USD]
  python audit/rereview.py summary                                          -> data/rereview_summary.json
"""

import collections
import csv
import json
import os
import random
import re
import secrets
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "data")
SAMPLE = os.path.join(DATA, "rereview_sample.csv")
OUT = os.path.join(DATA, "rereview.csv")
WORK = os.environ.get("REREVIEW_WORK", "/tmp/lspl/rr/work")
KINDS = ["leftover", "unrelated", "churn", "naming", "dead"]
STRIP = ["CLAUDE.md", "AGENTS.md", "GEMINI.md", ".claude", ".cursor", ".cursorrules", "copilot-instructions.md",
         ".windsurfrules", ".tereditor", ".mcp.json", ".vscode", ".idea", ".junie", ".continue", ".clinerules"]
ARTIFACT = re.compile(r"(^|/)(\.project|\.classpath|\.factorypath|\.settings/)")
DRIVER_TASK = "signature-create-check-constraint"


def runs_csv(results):
    return list(csv.DictReader(open(os.path.join(results, "runs.csv"), newline="", encoding="utf-8")))


def has_artifacts(results, rid):
    p = os.path.join(results, "runs", rid, "review", "patch.reviewed.diff")
    return any(ARTIFACT.search(x) for x in re.findall(r"^diff --git a/(\S+)", open(p, errors="replace").read(), re.M))


def sample(study, results, cells_per_kind=10, seed=20261124):
    runs = [r for r in runs_csv(results) if r["flaws"] != ""]
    by_cell = collections.defaultdict(lambda: collections.defaultdict(list))
    for r in runs:
        by_cell[(r["project"], r["task"], r["model"])][r["arm"]].append(r)
    rng = random.Random(seed)
    picked = []
    for kind in ("syn", "pr"):
        for i, model in enumerate(["claude-haiku-5-5", "claude-sonnet-5-5", "claude-opus-5-5"]):
            want = cells_per_kind // 3 + (1 if i < cells_per_kind % 3 else 0)
            cands = sorted(k for k, v in by_cell.items() if k[2] == model and k[1] != DRIVER_TASK
                           and ((v["baseline"] and v["baseline"][0]["task_type"] == "pr") == (kind == "pr"))
                           and all(v[a] for a in ("baseline", "optional", "enforced")))
            rng.shuffle(cands)
            used_tasks = {(c[0], c[1]) for c, _ in picked}
            n = 0
            for c in cands:
                if n == want:
                    break
                if (c[0], c[1]) in used_tasks:
                    continue
                arms = {a: sorted(by_cell[c][a], key=lambda r: int(r["rep"]))[0] for a in ("baseline", "optional", "enforced")}
                if any(has_artifacts(results, r["run_id"]) for r in arms.values()):
                    continue
                picked.append((c, [("random " + kind, r) for r in arms.values()]))
                n += 1
    # The task that drives the optional-vs-baseline gap, on purpose: all its Haiku and Sonnet baseline and optional runs.
    for c, v in sorted(by_cell.items()):
        if c[1] == DRIVER_TASK and c[2] in ("claude-haiku-5-5", "claude-sonnet-5-5"):
            picked.append((c, [("driver task", r) for a in ("baseline", "optional") for r in v[a]]))
    rows = []
    for c, items in picked:
        for stratum, r in items:
            rows.append({"run_id": r["run_id"], "stratum": stratum, "project": r["project"], "task": r["task"],
                         "model": r["model"], "arm": r["arm"], "rep": r["rep"], "kind": "pr" if r["task_type"] == "pr" else "syn",
                         "haiku_flaws": r["flaws"], "token": secrets.token_hex(6)})
    rng.shuffle(rows)
    with open(SAMPLE, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"sampled {len(rows)} runs in {len(picked)} cells -> {SAMPLE}")


def sh(args, cwd=None, check=True):
    return subprocess.run(args, cwd=cwd, check=check, capture_output=True, text=True)


def toml_val(path, key):
    m = re.search(rf'^{key}\s*=\s*"?([^"\n]*)"?\s*$', open(path).read(), re.M) if os.path.exists(path) else None
    return m.group(1) if m else ""


def snapshot(study, project, commit):
    """The project at a commit, instruction files stripped (cached per project and commit)."""
    dst = os.path.join(WORK, "snap", f"{project}-{commit[:12]}")
    if os.path.exists(os.path.join(dst, ".done")):
        return dst
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst)
    repo = toml_val(os.path.join(study, "projects", project, "project.toml"), "repo")
    sh(["git", "init", "-q", "."], cwd=dst)
    sh(["git", "remote", "add", "origin", repo], cwd=dst)
    sh(["git", "fetch", "-q", "--depth", "1", "origin", commit], cwd=dst)
    sh(["git", "checkout", "-q", "FETCH_HEAD"], cwd=dst)
    shutil.rmtree(os.path.join(dst, ".git"))
    for root, dirs, files in os.walk(dst):
        if "node_modules" in dirs:
            dirs.remove("node_modules")
        for name in list(dirs) + files:
            if name in STRIP or name.startswith(".aider"):
                p = os.path.join(root, name)
                shutil.rmtree(p) if os.path.isdir(p) and not os.path.islink(p) else os.remove(p)
                if name in dirs:
                    dirs.remove(name)
    open(os.path.join(dst, ".done"), "w").close()
    return dst


def build_tree(study, results, row):
    """Rebuilt tree and input files for one review; the directory name is a random token, never the run id."""
    td = os.path.join(study, "tasks", row["project"], row["task"])
    commit = toml_val(os.path.join(td, "task.toml"), "base_commit") or toml_val(os.path.join(study, "projects", row["project"], "project.toml"), "commit")
    snap = snapshot(study, row["project"], commit)
    base = os.path.join(WORK, "trees", row["token"])
    tree, inp = os.path.join(base, "repo"), os.path.join(base, "in")
    shutil.rmtree(base, ignore_errors=True)
    os.makedirs(inp)
    shutil.copytree(snap, tree, symlinks=True)
    os.remove(os.path.join(tree, ".done"))
    sh(["git", "init", "-q", "-b", "main", "."], cwd=tree)
    if os.path.exists(os.path.join(td, "setup.patch")) and os.path.getsize(os.path.join(td, "setup.patch")):
        sh(["git", "apply", "--whitespace=nowarn", os.path.join(td, "setup.patch")], cwd=tree)
    diff = os.path.join(results, "runs", row["run_id"], "review", "patch.reviewed.diff")
    sh(["git", "apply", "--whitespace=nowarn", "--binary", diff], cwd=tree)
    shutil.rmtree(os.path.join(tree, ".git"))
    shutil.copy(diff, os.path.join(inp, "patch.diff"))
    shutil.copy(os.path.join(td, "prompt.md"), os.path.join(inp, "task.md"))
    return tree, inp


def review(study, tree, inp, model):
    prompt = open(os.path.join(study, "harness", "judge", "prompt.md")).read()
    prompt = prompt.replace("/in/task.md", os.path.join(inp, "task.md")).replace("/in/patch.diff", os.path.join(inp, "patch.diff"))
    prompt = prompt.replace("/workspace", tree)
    args = ["claude", "-p", prompt, "--model", model, "--output-format", "stream-json", "--verbose",
            "--setting-sources", "project", "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}',
            "--no-session-persistence", "--tools", "Read,Grep,Glob", "--disallowedTools", "Bash,WebFetch,WebSearch",
            "--add-dir", inp, "--max-budget-usd", "1", "--max-turns", "60"]
    p = subprocess.run(args, cwd=tree, capture_output=True, text=True, timeout=1500)
    events = [json.loads(x) for x in p.stdout.splitlines() if x.startswith("{")]
    init = next((e for e in events if e.get("type") == "system" and e.get("subtype") == "init"), {})
    hooks = sum(1 for e in events if e.get("type") == "system" and str(e.get("subtype", "")).startswith("hook_"))
    res = [e for e in events if e.get("type") == "result"]
    cost = sum(e.get("total_cost_usd") or 0 for e in res)
    text = "\n".join(str(e.get("result") or "") for e in res)
    obj = [x for x in text.splitlines() if re.match(r'^\s*\{.*"flaws"', x)]
    items, parsed = None, False
    if obj:
        try:
            items = json.loads(obj[-1])["flaws"]
            parsed = isinstance(items, list)
        except ValueError:
            pass
    return {"parsed": parsed, "items": items if parsed else [], "cost": cost, "tools": init.get("tools"),
            "mcp_servers": init.get("mcp_servers"), "hooks": hooks, "error": "" if res else p.stderr[-300:]}


def run(study, results, model, limit=None, budget=20.0):
    rows = list(csv.DictReader(open(SAMPLE)))
    done = {}
    if os.path.exists(OUT):
        for r in csv.DictReader(open(OUT)):
            done[(r["run_id"], r["reviewer"])] = r
    spent = sum(float(r["cost_usd"] or 0) for r in done.values())
    fields = ["run_id", "reviewer", "parsed", "flaws"] + KINDS + ["cost_usd", "tools", "mcp_servers", "hooks", "items", "error"]
    new = not os.path.exists(OUT)
    fh = open(OUT, "a", newline="")
    w = csv.DictWriter(fh, fieldnames=fields)
    if new:
        w.writeheader()
    n = 0
    for row in rows:
        if (row["run_id"], model) in done:
            continue
        if limit is not None and n >= limit:
            break
        if spent >= budget:
            print(f"stopped: spent ${spent:.2f} >= budget ${budget:.2f}")
            break
        tree, inp = build_tree(study, results, row)
        r = review(study, tree, inp, model)
        spent += r["cost"]
        n += 1
        counts = collections.Counter(str(i.get("kind", "")) for i in r["items"])
        w.writerow({"run_id": row["run_id"], "reviewer": model, "parsed": r["parsed"],
                    "flaws": len(r["items"]) if r["parsed"] else "", **{k: counts.get(k, 0) for k in KINDS},
                    "cost_usd": round(r["cost"], 5), "tools": ",".join(r["tools"] or []), "mcp_servers": len(r["mcp_servers"] or []),
                    "hooks": r["hooks"], "items": json.dumps(r["items"]), "error": r["error"]})
        fh.flush()
        shutil.rmtree(os.path.dirname(tree), ignore_errors=True)
        print(f"{n:>3} {model} parsed={r['parsed']} flaws={len(r['items'])} cost=${r['cost']:.4f} total=${spent:.2f}", flush=True)
    fh.close()


def agreement(xs, ys):
    """Exact agreement, mean absolute difference, Spearman-free Pearson correlation and presence agreement."""
    n = len(xs)
    if n == 0:
        return {}
    mx, my = sum(xs) / n, sum(ys) / n
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sx = sum((x - mx) ** 2 for x in xs) ** 0.5
    sy = sum((y - my) ** 2 for y in ys) ** 0.5
    return {"n": n, "exact": round(sum(x == y for x, y in zip(xs, ys)) / n, 3),
            "presence": round(sum((x > 0) == (y > 0) for x, y in zip(xs, ys)) / n, 3),
            "mean_abs_diff": round(sum(abs(x - y) for x, y in zip(xs, ys)) / n, 3),
            "pearson": round(sxy / (sx * sy), 3) if sx and sy else None, "mean_x": round(mx, 3), "mean_y": round(my, 3)}


def summary():
    sample_rows = {r["run_id"]: r for r in csv.DictReader(open(SAMPLE))}
    rev = collections.defaultdict(dict)
    for r in csv.DictReader(open(OUT)):
        if r["parsed"] == "True":
            rev[r["run_id"]][r["reviewer"]] = r
    orig = {}
    # The original Haiku review per kind comes from data/flaws.csv.
    per_kind = collections.defaultdict(collections.Counter)
    for f in csv.DictReader(open(os.path.join(DATA, "flaws.csv"))):
        per_kind[f["run_id"]][f["kind"]] += 1
    for rid, s in sample_rows.items():
        orig[rid] = {"flaws": float(s["haiku_flaws"]), **{k: per_kind[rid].get(k, 0) for k in KINDS}}
    H, O = "claude-haiku-5-5", "claude-opus-5-5"
    out: dict = {"cost_usd": round(sum(float(x["cost_usd"] or 0) for r in rev.values() for x in r.values()), 2)}
    pairs = {"original Haiku vs re-run Haiku (environment + test-retest)": ("orig", H),
             "re-run Haiku vs Opus (reviewer)": (H, O), "original Haiku vs Opus": ("orig", O)}
    for strat in ("random", "driver task", "all"):
        ids = [rid for rid, s in sample_rows.items() if strat == "all" or s["stratum"].startswith(strat)]
        res = {}
        for label, (a, b) in pairs.items():
            both = [rid for rid in ids if (a == "orig" or a in rev[rid]) and b in rev[rid]]

            def val(rid, who, k):
                return float(orig[rid][k]) if who == "orig" else float(rev[rid][who][k])
            res[label] = {"total": agreement([val(i, a, "flaws") for i in both], [val(i, b, "flaws") for i in both]),
                          **{k: agreement([val(i, a, k) for i in both], [val(i, b, k) for i in both]) for k in KINDS}}
        out[strat] = res
    # Optional minus baseline under each reviewer, paired by cell (random stratum only).
    diffs = {}
    for who in ("orig", H, O):
        cells = collections.defaultdict(dict)
        for rid, s in sample_rows.items():
            if not s["stratum"].startswith("random") or s["arm"] not in ("baseline", "optional", "enforced"):
                continue
            if who != "orig" and who not in rev[rid]:
                continue
            cells[(s["project"], s["task"], s["model"])][s["arm"]] = orig[rid]["flaws"] if who == "orig" else float(rev[rid][who]["flaws"])
        d_opt = [c["optional"] - c["baseline"] for c in cells.values() if "optional" in c and "baseline" in c]
        d_enf = [c["enforced"] - c["baseline"] for c in cells.values() if "enforced" in c and "baseline" in c]
        rng = random.Random(7)

        def ci(d):
            if not d:
                return None
            b = sorted(sum(rng.choice(d) for _ in d) / len(d) for _ in range(4000))
            return [round(sum(d) / len(d), 3), round(b[99], 3), round(b[3899], 3), len(d)]
        diffs["original Haiku" if who == "orig" else ("re-run Haiku" if who == H else "Opus")] = {"optional - baseline": ci(d_opt), "enforced - baseline": ci(d_enf)}
    out["paired_differences_random_stratum"] = diffs
    drv = []
    for rid, s in sample_rows.items():
        if s["stratum"] == "driver task":
            drv.append({"run_id": rid, "arm": s["arm"], "model": s["model"], "original_haiku": orig[rid]["flaws"],
                        "rerun_haiku": float(rev[rid][H]["flaws"]) if H in rev[rid] else None,
                        "opus": float(rev[rid][O]["flaws"]) if O in rev[rid] else None})
    out["driver_task"] = sorted(drv, key=lambda x: (x["model"], x["arm"]))
    json.dump(out, open(os.path.join(DATA, "rereview_summary.json"), "w"), indent=1)
    print(json.dumps({k: v for k, v in out.items() if k != "driver_task"}, indent=1)[:4000])


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "sample":
        sample(sys.argv[2], sys.argv[3])
    elif cmd == "run":
        a = sys.argv[5:]
        lim = int(a[a.index("--limit") + 1]) if "--limit" in a else None
        bud = float(a[a.index("--budget") + 1]) if "--budget" in a else 20.0
        run(sys.argv[2], sys.argv[3], sys.argv[4], lim, bud)
    elif cmd == "summary":
        summary()
