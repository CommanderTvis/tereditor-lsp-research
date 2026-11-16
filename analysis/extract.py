"""Turns every finished run of a plan into one row of results/<plan>/runs.csv.

Sources per run directory (results/<plan>/runs/<run_id>/): stream.jsonl (Claude Code stream-json), exit.json,
grade/result.json, lsplog/*.jsonl (tereditor's call log), patch.diff. Also checks each run's system/init event
against what its arm must offer (the contamination check, docs/DESIGN.md).
"""
from __future__ import annotations

import csv
import glob
import json
import os
import re
import sys
from collections import Counter

LSP_TOOLS = {f"mcp__tereditor__{t}" for t in
             ("lsp_navigate", "lsp_diagnostics", "lsp_status", "lsp_code_actions", "lsp_rename", "lsp_format")}
# Exactly these built-in tools in every arm (harness/env/run.sh and the entrypoint pass them with --tools).
BUILTIN_TOOLS = {"Bash", "Read", "Edit", "Write", "Task", "ToolSearch"}
SEARCH_CMD = re.compile(r"(^|[|;&\s(])(grep|egrep|fgrep|rg|ag|ack|git\s+grep)(\s|$)")
READ_CMD = re.compile(r"(^|[|;&\s(])(cat|head|tail|sed\s+-n|less|awk)(\s|$)")
FIND_CMD = re.compile(r"(^|[|;&\s(])(find|ls|tree|fd)(\s|$)")


def load_jsonl(path: str) -> list[dict]:
    rows = []
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    rows.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    except FileNotFoundError:
        pass
    return rows


def contamination(arm: str, init: dict | None) -> list[str]:
    """Problems with the run's configuration, or [] when it is exactly what the arm should be."""
    if init is None:
        return ["no system/init event"]
    problems = []
    tools = set(init.get("tools") or [])
    mcp_tools = {t for t in tools if t.startswith("mcp__")}
    servers = {s.get("name"): s.get("status") for s in init.get("mcp_servers") or []}
    builtins = {t for t in tools if not t.startswith("mcp__")}
    if builtins != BUILTIN_TOOLS:
        problems.append(f"built-in tools {sorted(builtins)} != {sorted(BUILTIN_TOOLS)}")
    if arm in ("baseline", "baseline-review"):
        if mcp_tools:
            problems.append(f"baseline has MCP tools {sorted(mcp_tools)}")
        if servers:
            problems.append(f"baseline has MCP servers {servers}")
    else:
        if mcp_tools != LSP_TOOLS:
            problems.append(f"MCP tools {sorted(mcp_tools)} != the six lsp tools")
        if servers != {"tereditor": "connected"}:
            problems.append(f"MCP servers {servers}")
    # Claude Code's own builtin plugins load in every arm; anything else means outside configuration leaked in.
    foreign = [p for p in init.get("plugins") or [] if not str(p.get("source", "")).endswith("@builtin")]
    if foreign:
        problems.append(f"plugins {foreign}")
    agents = set(init.get("agents") or [])
    if agents - {"general-purpose", "statusline-setup", "Explore", "Plan", "output-style-setup", "claude-code-guide",
                 "web-fetch", "claude"}:
        problems.append(f"custom agents {sorted(agents)}")
    for key in ("memory_paths", "memoryFiles", "claude_md"):
        if init.get(key):
            files = init[key]
            # Claude Code's auto-memory directory in the run's fresh HOME starts empty in every run and every arm.
            if isinstance(files, dict):
                files = [v for k, v in files.items() if not (k == "auto" and str(v).startswith("/home/agent/.claude/"))]
                if not files:
                    continue
            if arm != "enforced" or any("/workspace/CLAUDE.md" not in str(f) for f in (files if isinstance(files, list) else [files])):
                problems.append(f"memory files {files}")
    return problems


def summarize(run_dir: str, plan_row: dict) -> dict:
    row = dict(plan_row)
    events = load_jsonl(os.path.join(run_dir, "stream.jsonl"))
    # baseline-review: the second prompt is a second `claude -p --resume` process with its own stream and result.
    review_events = load_jsonl(os.path.join(run_dir, "stream-review.jsonl")) if os.path.exists(os.path.join(run_dir, "stream-review.jsonl")) else []
    review_result = next((e for e in reversed(review_events) if e.get("type") == "result"), None)
    init = next((e for e in events if e.get("type") == "system" and e.get("subtype") == "init"), None)
    result = next((e for e in reversed(events) if e.get("type") == "result"), None)
    row["init_tools"] = len((init or {}).get("tools") or [])
    row["claude_version"] = (init or {}).get("claude_code_version", "")
    row["model_reported"] = (init or {}).get("model", "")
    problems = contamination(plan_row["arm"], init)
    row["contaminated"] = bool(problems)
    row["contamination"] = "; ".join(problems)
    # The egress proxy logs every connection the agent tried; anything denied is an attempt to leave (docs/DESIGN.md).
    egress = os.path.join(run_dir, "egress.log")
    denied = [l.strip() for l in open(egress)] if os.path.exists(egress) else []
    denied = [l for l in denied if " DENY " in l]
    row["egress_denied"] = len(denied)
    row["egress_denied_hosts"] = "; ".join(sorted({l.split(" DENY ", 1)[1] for l in denied}))[:300]

    # Tool use, counted over the main conversation and subagents alike.
    tools: Counter[str] = Counter()
    bash_kinds: Counter[str] = Counter()
    lsp_ops: Counter[str] = Counter()
    first_lsp_turn = None
    assistant_turns = 0
    edited_files: set[str] = set()
    hook_blocks = 0
    for e in events + review_events:
        if e.get("type") == "assistant":
            assistant_turns += 1
            for c in (e.get("message") or {}).get("content") or []:
                if c.get("type") != "tool_use":
                    continue
                name = c.get("name", "")
                tools[name] += 1
                inp = c.get("input") or {}
                if name == "Bash":
                    cmd = inp.get("command", "")
                    if SEARCH_CMD.search(cmd):
                        bash_kinds["search"] += 1
                    if READ_CMD.search(cmd):
                        bash_kinds["read"] += 1
                    if FIND_CMD.search(cmd):
                        bash_kinds["find"] += 1
                if name in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
                    edited_files.add(inp.get("file_path", ""))
                if name in LSP_TOOLS:
                    lsp_ops[f"{name.rsplit('__', 1)[1]}:{inp.get('operation', '')}"] += 1
                    if first_lsp_turn is None:
                        first_lsp_turn = assistant_turns
        if e.get("type") == "system" and "hook" in str(e.get("subtype", "")) and "block" in json.dumps(e):
            hook_blocks += 1
    lsp_calls = sum(v for k, v in tools.items() if k in LSP_TOOLS)
    row.update({
        "tool_calls": sum(tools.values()),
        "lsp_calls": lsp_calls,
        "lsp_used": lsp_calls > 0,
        "first_lsp_turn": first_lsp_turn if first_lsp_turn is not None else "",
        "lsp_ops": json.dumps(dict(lsp_ops), sort_keys=True),
        "grep_tool": tools["Grep"], "glob_tool": tools["Glob"], "read_tool": tools["Read"],
        "bash_tool": tools["Bash"], "bash_search": bash_kinds["search"], "bash_read": bash_kinds["read"],
        "bash_find": bash_kinds["find"],
        "edit_tool": tools["Edit"] + tools["MultiEdit"], "write_tool": tools["Write"],
        "task_tool": tools["Task"] + tools["Agent"], "todo_tool": tools["TodoWrite"],
        "files_edited": len(edited_files - {""}),
        "hook_blocks": hook_blocks,
        "tools_json": json.dumps(dict(tools), sort_keys=True),
    })

    # Cost, tokens, time, termination.
    r = result or {}
    usage = r.get("usage") or {}
    rr = review_result or {}
    ru = rr.get("usage") or {}

    def add(a, b):  # sum of the two turns; blank stays blank when the run produced no number
        return (a or 0) + (b or 0) if a != "" or b != "" else ""
    row.update({
        "result_subtype": r.get("subtype", "missing"),
        "is_error": r.get("is_error", True),
        "cost_usd": add(r.get("total_cost_usd", ""), rr.get("total_cost_usd", "")),
        "num_turns": add(r.get("num_turns", ""), rr.get("num_turns", "")),
        "duration_ms": add(r.get("duration_ms", ""), rr.get("duration_ms", "")),
        "duration_api_ms": add(r.get("duration_api_ms", ""), rr.get("duration_api_ms", "")),
        "input_tokens": add(usage.get("input_tokens", ""), ru.get("input_tokens", "")),
        "output_tokens": add(usage.get("output_tokens", ""), ru.get("output_tokens", "")),
        "cache_read_tokens": add(usage.get("cache_read_input_tokens", ""), ru.get("cache_read_input_tokens", "")),
        "cache_write_tokens": add(usage.get("cache_creation_input_tokens", ""), ru.get("cache_creation_input_tokens", "")),
    })
    try:
        with open(os.path.join(run_dir, "exit.json")) as f:
            ex = json.load(f)
        row["exit_code"] = ex.get("exit")
        row["wall_s"] = round(float(ex["end"]) - float(ex["start"]), 2)
    except (FileNotFoundError, KeyError, ValueError):
        row["exit_code"], row["wall_s"] = "", ""
    row["timed_out"] = row["exit_code"] in (124, 137)
    row["capped"] = row["result_subtype"] in ("error_max_turns", "error_max_budget_usd", "error_max_budget") or row["timed_out"]
    row["reached_model"] = any(e.get("type") == "assistant" for e in events)

    # tereditor's own call log: errors, initializing answers, time in tools.
    calls = [c for p in glob.glob(os.path.join(run_dir, "lsplog", "*.jsonl")) for c in load_jsonl(p) if c.get("ev") == "call"]
    row["lsp_log_calls"] = len(calls)
    row["lsp_log_errors"] = sum(1 for c in calls if c.get("isError"))
    row["lsp_log_ms"] = sum(c.get("durationMs") or 0 for c in calls)
    row["lsp_result_chars"] = sum(c.get("resultChars") or 0 for c in calls)

    # The grade.
    try:
        with open(os.path.join(run_dir, "grade", "result.json")) as f:
            g = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        g = {}
    row["graded"] = bool(g)
    row["success"] = bool(g.get("success")) if g else ""
    for k in ("precision", "recall", "f1", "tp", "fp", "fn", "check_exit", "patch_applied"):
        row[f"grade_{k}"] = g.get(k, "")
    try:
        row["patch_bytes"] = os.path.getsize(os.path.join(run_dir, "patch.diff"))
    except OSError:
        row["patch_bytes"] = ""
    return row


def main(plan: str) -> None:
    base = os.path.join(os.environ.get("STUDY_ROOT", "."), "results", plan)
    with open(os.path.join(base, "plan.tsv")) as f:
        plan_rows = list(csv.DictReader(f, delimiter="\t"))
    tasks = {}
    rows = []
    for pr in plan_rows:
        run_dir = os.path.join(base, "runs", pr["run_id"])
        if not os.path.exists(os.path.join(run_dir, "exit.json")):
            continue
        key = (pr["project"], pr["task"])
        if key not in tasks:
            tasks[key] = {}
            tt = os.path.join(os.environ.get("STUDY_ROOT", "."), "tasks", pr["project"], pr["task"], "task.toml")
            with open(tt) as f:
                m = re.search(r'^type\s*=\s*"([a-z]+)"', f.read(), re.M)
            tasks[key]["type"] = m.group(1) if m else ""
        row = summarize(run_dir, pr)
        lang, size = pr["project"].rsplit("-", 1)
        row.update({"lang": lang, "size": size, "task_type": tasks[key]["type"], "task_key": f"{pr['project']}/{pr['task']}"})
        rows.append(row)
    if not rows:
        print("no finished runs", file=sys.stderr)
        return
    fields = list(rows[0].keys())
    with open(os.path.join(base, "runs.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)
    bad = [r for r in rows if r["contaminated"]]
    print(f"{len(rows)} runs, {len(bad)} failed the contamination check", file=sys.stderr)
    for r in bad[:20]:
        print(f"  {r['run_id']} {r['arm']}: {r['contamination']}", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv[1])
