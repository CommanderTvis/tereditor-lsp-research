"""Corrected quality-flaw counts (docs/ANALYSIS_PLAN.md, "Flaw counts re-checked"). Standard library only.

The quality reviewer (Haiku 5.5) over-reports; every flaw it reported was post-checked by a second model
(analysis/recheck_flaws.py -> results/<plan>/flaw_recheck.csv). A flaw counts only when the post-check rules it
`valid`; the others keep the post-check's verdict as the reason they do not count: optional (the task declared it
optional), formatting_changed_line (formatting of a line the change had to touch, none of the reviewer's five kinds),
duplicate (the same defect in another file), not_introduced (not caused by the change) or wrong (contradicted by the
diff or the task).

Reads results/<plan>/runs/*/review/result.json (restored archives), results/<plan>/flaw_recheck.csv and
results/<plan>/runs.csv; rewrites runs.csv with the corrected count in `flaws` and the reviewer's own count in
`flaws_raw`, and writes results/<plan>/flaws.csv with every reported flaw, `counted` and `dropped_by`.

Usage:  python3 analysis/correct_flaws.py <plan>     (then analysis/report.py <plan> as usual)
"""

import collections
import csv
import json
import os
import sys


def main(plan):
    base = os.path.join(os.environ.get("STUDY_ROOT", "."), "results", plan)
    recheck_path = os.path.join(base, "flaw_recheck.csv")
    if not os.path.exists(recheck_path):
        print(f"{plan}: no flaw_recheck.csv; flaw counts stay as the reviewer gave them (analysis/recheck_flaws.py {plan})")
        return
    verdict = {(r["run_id"], int(r["index"])): (r["verdict"], r["note"]) for r in csv.DictReader(open(recheck_path))}
    with open(os.path.join(base, "runs.csv"), newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        fields = list(reader.fieldnames or [])
        runs = list(reader)
    if "flaws_raw" not in fields:
        fields.insert(fields.index("flaws") + 1, "flaws_raw")
    out, stats, missing = [], collections.Counter(), 0
    for r in runs:
        raw = r.get("flaws_raw") if r.get("flaws_raw") not in (None, "") else r["flaws"]
        r["flaws_raw"] = raw
        if raw == "":
            continue
        p = os.path.join(base, "runs", r["run_id"], "review", "result.json")
        if not os.path.exists(p):
            sys.exit(f"no {p}: restore the archives first (./study restore {plan})")
        items = json.load(open(p)).get("items") or []
        counted = 0
        for n, f in enumerate(items, 1):
            v, note = verdict.get((r["run_id"], n), ("", ""))
            if not v:
                missing += 1
            ok = v == "valid"
            counted += ok
            stats[v or "not re-checked"] += 1
            out.append({"run_id": r["run_id"], **{k: str(f.get(k, "")) for k in ("kind", "file", "line", "reason")},
                        "counted": "yes" if ok else "no", "dropped_by": "" if ok else (v or "not re-checked"), "recheck_note": note})
        r["flaws"] = str(counted)
    if missing:
        sys.exit(f"{missing} reported flaws have no post-check verdict: finish analysis/recheck_flaws.py {plan}")
    with open(os.path.join(base, "runs.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(runs)
    with open(os.path.join(base, "flaws.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=["run_id", "kind", "file", "line", "reason", "counted", "dropped_by", "recheck_note"])
        w.writeheader()
        w.writerows(out)
    print(f"{plan}: {sum(stats.values())} reported flaws; " + ", ".join(f"{k}: {v}" for k, v in stats.most_common()))


if __name__ == "__main__":
    main(sys.argv[1])
