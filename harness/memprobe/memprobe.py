#!/usr/bin/env python3
"""memprobe.py [-m MODEL ...] [--out FILE] TASK_DIR...  (docs/MEMORIZATION.md)

For each mined task, give each model only the repository and the issue text (prompt.md), no tools, and ask it to
reproduce the upstream fix from memory; score the answer against the task's gold.patch (read only to score). Prints one
line per task and model and a final line per task: SCORE (the worst verbatim share over the models; a covariate, never
a reason to drop a task) and, when the gold patch has at least 15 added lines and any model reproduces >= 25% of them,
CUTOFF-CHECK, the sign that a task presumed unseen may have been (docs/MEMORIZATION.md). Verbatim = added lines of
>= 25 characters, whitespace-normalised, not already in the issue text.
Spends model money (about USD 0.01 to 0.05 per task and model); run it from the host, outside the study's sandboxes.
"""
import argparse, json, os, re, subprocess, sys, tempfile

MODELS = ["claude-haiku-5-5", "claude-sonnet-5-5", "claude-opus-5-5"]
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
norm = lambda s: re.sub(r"\s+", " ", s.strip())


def added(patch):
    return {norm(l[1:]) for l in patch.splitlines() if l.startswith("+") and not l.startswith("+++") and len(norm(l[1:])) >= 25}


def files(patch):
    return set(re.findall(r"^\+\+\+ b/(.+)$", patch, re.M))


def repo_of(task_dir):
    proj = os.path.basename(os.path.dirname(os.path.abspath(task_dir)))
    for line in open(os.path.join(ROOT, "projects", proj, "project.toml")):
        m = re.match(r'repo\s*=\s*"(.*)"', line)
        if m:
            return m.group(1)
    raise SystemExit(f"no repo in projects/{proj}/project.toml")


def ask(model, repo, issue):
    prompt = (f"Repository: {repo}\n\nThe following issue was fixed by a merged upstream pull request.\n\n--- issue ---\n{issue}\n--- end ---\n\n"
              "You have no tools and no access to the repository. From memory only: reproduce the upstream fix as a unified diff "
              "of the NON-test source files (file paths as in the repository, hunks as the real commit had them). If you do not "
              "remember it, give your best guess. Output only the diff.")
    with tempfile.TemporaryDirectory() as cwd:
        r = subprocess.run(["claude", "-p", prompt, "--model", model, "--tools", "", "--setting-sources", "project",
                            "--strict-mcp-config", "--no-session-persistence", "--output-format", "json", "--max-budget-usd", "1"],
                           cwd=cwd, capture_output=True, text=True, stdin=subprocess.DEVNULL, timeout=300)
    try:
        o = json.loads(r.stdout)
    except ValueError:
        return "", 0.0
    return o.get("result") or "", o.get("total_cost_usd") or 0.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-m", "--model", dest="models", action="append")
    ap.add_argument("--out")
    ap.add_argument("tasks", nargs="+")
    a = ap.parse_args()
    a.models = a.models or MODELS
    out = open(a.out, "a") if a.out else None
    for t in a.tasks:
        gold = open(os.path.join(t, "gold.patch")).read()
        issue = open(os.path.join(t, "prompt.md")).read()[:6000]
        g, gf, p = added(gold), files(gold), norm(issue)
        fresh = {x for x in g if x not in p}
        worst = 0.0; named_all = False
        for m in a.models:
            ans, cost = ask(m, repo_of(t), issue)
            o, of = added(ans), files(ans)
            share = len(fresh & o) / len(fresh) if fresh else 0.0
            names = bool(gf) and all(f in of or any(x.endswith(os.path.basename(f)) for x in of) for f in gf)
            worst = max(worst, share); named_all = named_all or (names and share >= 0.10)
            row = {"task": t, "model": m, "answered": bool(ans), "gold_lines": len(g), "fresh_lines": len(fresh),
                   "verbatim_share": round(share, 3), "names_all_files": names, "cost_usd": cost}
            print(json.dumps(row)); out and out.write(json.dumps(row) + "\n")
        flag = "  CUTOFF-CHECK" if len(g) >= 15 and worst >= 0.25 else ""
        print(f"SCORE {t} worst verbatim share {worst:.2f} (gold lines {len(g)}){flag}")


if __name__ == "__main__":
    main()
