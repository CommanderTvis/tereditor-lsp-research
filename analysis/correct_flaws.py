"""Corrected quality-flaw counts (docs/ANALYSIS_PLAN.md, "Flaw counts re-checked"). Standard library only.

The Haiku reviewer's counts were re-checked and found to be inflated in two mechanical ways, corrected here:
  1. Flaws about something the task's prompt declares optional (for example "Updating the documentation is optional",
     or KotlinPoet's public API dump) are not flaws of the change.
  2. One defect pattern listed once per file (the same stale JSDoc in ten query runners, the same import-order note in
     53 files) counts once per run.

Reads results/<plan>/runs/*/review/result.json (restored archives) and results/<plan>/runs.csv; rewrites runs.csv
with the corrected count in `flaws` and the reviewer's own count in `flaws_raw`, and writes results/<plan>/flaws.csv
with every reported flaw and whether it is counted (`counted`, `dropped_by`).

Usage:  python3 analysis/correct_flaws.py <plan>     (then analysis/report.py <plan> as usual)
"""

import collections
import csv
import json
import os
import re
import sys

DOC = re.compile(r"(^|/)(docs?|documentation)/|\.(md|rst|txt|adoc)$|(^|/)CHANGELOG|(^|/)UPGRADE", re.I)
COMMENT = re.compile(r"comment|docblock|phpdoc|@param|@return|@see", re.I)

# What each task's prompt declares optional (the exact sentence is quoted), as a test on one reported flaw.
OPTIONAL = {
    # "Updating the public API dump (kotlinpoet/api/kotlinpoet.api) and the documentation is welcome but not required."
    "kotlin-medium/move-parameterspec": lambda f: bool(DOC.search(f["file"])) or f["file"].endswith(".api"),
    # "Updating the changelog or other documentation is optional."
    "php-large/move-translation-loader": lambda f: bool(DOC.search(f["file"])),
    # "Updating documentation files and comments is optional."
    "php-medium/rename-class-definition-get-data": lambda f: bool(DOC.search(f["file"])) or bool(COMMENT.search(f["reason"])),
    # "Updating documentation files is optional."
    "php-small/move-utilities-request": lambda f: bool(DOC.search(f["file"])),
    # "Updating the documentation files is optional."
    "python-medium/move-use-inference-default": lambda f: bool(DOC.search(f["file"])),
    # "Updating the documentation is optional."
    "typescript-large/signature-create-check-constraint": lambda f: bool(DOC.search(f["file"])),
}

STOP = r"\b(before|after|between|follow|follows|precede|should|now|still|line|lines|at|the|a|an|its|it|is|in|of|and|to)\b"


def pattern(reason):
    """A defect pattern: the reason without what changes from file to file (quoted names, paths, identifiers, numbers)."""
    r = reason.lower()
    r = re.sub(r"`[^`]*`|'[^']*'|\"[^\"]*\"", " ", r)
    r = re.sub(r"[\w./-]*[._/\d][\w./-]*", " ", r)
    r = re.sub(STOP, " ", r)
    return " ".join(r.split())[:60]


def main(plan):
    base = os.path.join(os.environ.get("STUDY_ROOT", "."), "results", plan)
    with open(os.path.join(base, "runs.csv"), newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        fields = list(reader.fieldnames or [])
        runs = list(reader)
    if "flaws_raw" not in fields:
        fields.insert(fields.index("flaws") + 1, "flaws_raw")
    out_flaws, stats = [], collections.Counter()
    for r in runs:
        raw = r.get("flaws_raw") if r.get("flaws_raw") not in (None, "") else r["flaws"]
        r["flaws_raw"] = raw
        if raw == "":
            continue
        p = os.path.join(base, "runs", r["run_id"], "review", "result.json")
        if not os.path.exists(p):
            sys.exit(f"no {p}: restore the archives first (./study restore {plan})")
        items = json.load(open(p)).get("items") or []
        task = f'{r["project"]}/{r["task"]}'
        seen, counted = set(), 0
        for f in items:
            f = {k: str(f.get(k, "")) for k in ("kind", "file", "line", "reason")}
            why = ""
            if OPTIONAL.get(task, lambda _: False)(f):
                why = "optional in the task"
            elif (f["kind"], pattern(f["reason"])) in seen:
                why = "same defect, another file"
            else:
                seen.add((f["kind"], pattern(f["reason"])))
                counted += 1
            stats[why or "counted"] += 1
            out_flaws.append({"run_id": r["run_id"], **f, "counted": "no" if why else "yes", "dropped_by": why})
        r["flaws"] = str(counted)
    with open(os.path.join(base, "runs.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(runs)
    with open(os.path.join(base, "flaws.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=["run_id", "kind", "file", "line", "reason", "counted", "dropped_by"])
        w.writeheader()
        w.writerows(out_flaws)
    print(f"{plan}: {sum(stats.values())} reported flaws; " + ", ".join(f"{k}: {v}" for k, v in stats.items()))


if __name__ == "__main__":
    main(sys.argv[1])
