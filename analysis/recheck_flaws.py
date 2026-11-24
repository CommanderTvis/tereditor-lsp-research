"""Post-check of every flaw the quality reviewer reported (docs/ANALYSIS_PLAN.md, "Flaw counts re-checked").

The reviewer (Haiku 5.5, harness/judge/prompt.md) over-reports: flaws about what the task declares optional,
formatting of lines the change had to touch (which none of its five kinds covers), one defect listed once per file,
and claims the diff contradicts. Here a second model (Opus 5.5 by default) rules on each reported flaw, given the task
prompt, the reviewed diff and the reviewer's definitions; it sees neither the arm nor the model of the run. Only flaws
ruled `valid` are counted (analysis/correct_flaws.py).

Writes results/<plan>/flaw_recheck.csv (run_id, index, verdict, note); resumable, runs in parallel, waits out usage
limits. Runs on the operator's machine with `claude -p`, no tools, --setting-sources project, no MCP servers.

Usage:  python3 analysis/recheck_flaws.py <plan> [--model M] [--jobs N] [--limit N] [--budget USD]
"""

import concurrent.futures
import csv
import json
import os
import re
import subprocess
import sys
import threading
import time

VERDICTS = ["valid", "optional", "formatting_changed_line", "duplicate", "not_introduced", "wrong"]
PROMPT = """You check another reviewer's findings about a code change. The reviewer looked only for non-functional damage
that tests cannot see, of exactly these kinds:
- leftover: an old name, path or signature the change should have updated but did not, in code comments, docstrings,
  string literals, documentation or configuration;
- unrelated: edits to places that have nothing to do with the task;
- churn: formatting or whitespace changes to lines the task did not need to touch;
- naming: names introduced by the change that are inconsistent with the task or with the surrounding code;
- dead: code, imports or files that the change left dead or unused.

Rule on every finding below with one verdict:
- valid: a real defect of one of the five kinds above, caused or left by this change, and not something the task makes
  optional;
- optional: it concerns something the task itself declares optional or not required (for example documentation);
- formatting_changed_line: formatting of a line the change had to touch anyway (import order after a rename or move,
  line length or wrapping of a rewritten comment); not churn as defined above, and not naming;
- duplicate: the same defect as an earlier finding in this list (the same mistake repeated in another file or line);
  the earliest one stays valid;
- not_introduced: it existed before the change, or concerns code the change did not touch;
- wrong: the claim is false given the diff or the task (for example the task requires exactly that, or the diff does
  update what it says was left).
Judge from the task and the diff; when a claim cites a place outside the diff that you cannot see, accept it as valid
only if it is plausible from the diff and the task.

THE TASK:
{task}

THE DIFF:
{diff}

THE FINDINGS:
{findings}

End your reply with exactly one line that contains only a JSON object, and nothing after it:
{{"verdicts": [{{"i": 1, "verdict": "valid|optional|formatting_changed_line|duplicate|not_introduced|wrong", "note": "short reason"}}]}}
with one entry per finding, in order."""


def diff_for(path, files, cap=60_000):
    """The reviewed diff; above `cap` bytes, only the file sections the findings name, plus the list of files."""
    text = open(path, errors="replace").read()
    if len(text) <= cap:
        return text
    parts = re.split(r"(?m)^(?=diff --git )", text)
    names = [m.group(1) for p in parts if (m := re.match(r"diff --git a/(\S+)", p))]
    keep = [p for p in parts if p.startswith("diff --git") and any(f and f in p.split("\n", 1)[0] for f in files)]
    out = "".join(keep)[:cap]
    return f"(diff of {len(names)} files, {len(text)} bytes; shown: the sections of the files the findings name)\n" \
           f"files: {', '.join(names[:300])}\n\n{out}"


def parse(text):
    """The last {"verdicts": [...]} object anywhere in the answer, as {index: verdict}."""
    for m in reversed(list(re.finditer(r'\{\s*"verdicts"\s*:', text))):
        depth = 0
        for j in range(m.start(), len(text)):
            depth += {"{": 1, "}": -1}.get(text[j], 0)
            if depth == 0:
                try:
                    return {int(v["i"]): v for v in json.loads(text[m.start():j + 1])["verdicts"]}
                except (ValueError, KeyError, TypeError):
                    break
    return {}


def ask(prompt, model, cwd):
    args = ["claude", "-p", prompt, "--model", model, "--output-format", "stream-json", "--verbose",
            "--setting-sources", "project", "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}',
            "--no-session-persistence", "--tools", "", "--max-turns", "3", "--max-budget-usd", "1"]
    while True:
        p = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=1200)
        ev = [json.loads(x) for x in p.stdout.splitlines() if x.startswith("{")]
        res = [e for e in ev if e.get("type") == "result"]
        limited = any(e.get("api_error") == "usage_limit_reached" or e.get("api_error_status") == 429 for e in res)
        if limited:
            resets = [e.get("error_params", {}).get("rate_limit_info", {}).get("resetsAt") for e in ev]
            resets = [r for r in resets if r] or [time.time() + 1800]
            time.sleep(max(300, max(resets) - time.time() + 120))
            continue
        cost = sum(e.get("total_cost_usd") or 0 for e in res)
        text = "\n".join(str(e.get("result") or "") for e in res)
        return text, cost


def main(plan, model="claude-opus-5-5", jobs=6, limit=None, budget=60.0):
    root = os.environ.get("STUDY_ROOT", ".")
    base = os.path.join(root, "results", plan)
    runs = {r["run_id"]: r for r in csv.DictReader(open(os.path.join(base, "runs.csv"), newline="", encoding="utf-8"))}
    out_path = os.path.join(base, "flaw_recheck.csv")
    done, spent = set(), 0.0
    if os.path.exists(out_path):
        for r in csv.DictReader(open(out_path)):
            done.add(r["run_id"])
            spent += float(r.get("cost_usd") or 0) if r["index"] == "1" else 0.0
    todo = []
    for rid in sorted(runs):
        p = os.path.join(base, "runs", rid, "review", "result.json")
        if rid in done or not os.path.exists(p):
            continue
        items = json.load(open(p)).get("items") or []
        if items:
            todo.append((rid, items))
    if limit is not None:
        todo = todo[:limit]
    lock = threading.Lock()
    new = not os.path.exists(out_path)
    fh = open(out_path, "a", newline="")
    w = csv.DictWriter(fh, fieldnames=["run_id", "index", "verdict", "note", "cost_usd"])
    if new:
        w.writeheader()
    tmp = os.path.join("/tmp", "flaw-recheck")
    os.makedirs(tmp, exist_ok=True)

    def one(job):
        nonlocal spent
        rid, items = job
        if spent >= budget:
            return
        r = runs[rid]
        task = open(os.path.join(root, "tasks", r["project"], r["task"], "prompt.md")).read()
        diff = diff_for(os.path.join(base, "runs", rid, "review", "patch.reviewed.diff"), [str(i.get("file", "")) for i in items])
        findings = "\n".join(f'{n}. [{i.get("kind")}] {i.get("file")}:{i.get("line")}: {i.get("reason")}' for n, i in enumerate(items, 1))
        verdicts, cost = {}, 0.0
        for _ in range(2):  # one retry when the answer has no parsable verdicts
            text, c = ask(PROMPT.format(task=task, diff=diff, findings=findings), model, tmp)
            cost += c
            verdicts = parse(text)
            if verdicts:
                break
        with lock:
            spent += cost
            for n in range(1, len(items) + 1):
                v = verdicts.get(n, {})
                verdict = v.get("verdict") if v.get("verdict") in VERDICTS else "unparsed"
                w.writerow({"run_id": rid, "index": n, "verdict": verdict, "note": str(v.get("note", ""))[:300],
                            "cost_usd": round(cost, 5) if n == 1 else ""})
            fh.flush()
            print(f"{rid} {len(items)} findings, {sum(1 for n in range(1, len(items) + 1) if verdicts.get(n, {}).get('verdict') == 'valid')} valid, ${cost:.3f}, total ${spent:.2f}", flush=True)

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        list(ex.map(one, todo))
    fh.close()
    print(f"spent ${spent:.2f}")


if __name__ == "__main__":
    a = sys.argv[2:]
    opt = lambda k, d: type(d)(a[a.index(k) + 1]) if k in a else d
    main(sys.argv[1], model=opt("--model", "claude-opus-5-5"), jobs=opt("--jobs", 6),
         limit=opt("--limit", 0) or None, budget=opt("--budget", 60.0))
