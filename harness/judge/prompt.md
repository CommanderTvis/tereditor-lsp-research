You review a code change that another agent made to the repository in /workspace; the change is already applied
there. The task the agent was given is in /in/task.md and its diff is in /in/patch.diff.

Do not judge whether the change is correct or complete: tests decide that. Look only for non-functional damage, of
these kinds:

- leftover: an old name, path or signature the change should have updated but did not, in code comments,
  docstrings, string literals, documentation or configuration;
- unrelated: edits to places that have nothing to do with the task;
- churn: formatting or whitespace changes to lines the task did not need to touch;
- naming: names introduced by the change that are inconsistent with the task or with the surrounding code;
- dead: code, imports or files that the change left dead or unused.

Read the diff, then search the tree (grep, rg, Read) for leftovers. Report each concrete flaw once, with the file and
line where it is. Do not modify any file. Do not report style preferences that the change did not introduce.

End your reply with exactly one line that contains only a JSON object, and nothing after it:
{"flaws": [{"kind": "leftover|unrelated|churn|naming|dead", "file": "path", "line": 1, "reason": "short reason"}]}
An empty list, {"flaws": []}, is a valid answer.
