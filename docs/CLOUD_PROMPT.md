# The cloud prompt

The message that starts the study in a Claude Code cloud session (network access Full, no repository, no environment
variables, no setup script). Attach JetBrains' offline activation code to it: the zip from "Download a code for
offline activation", or the `... - for 2018.2 or later.txt` file inside it. To resume a run whose VM was lost, also
attach the latest `study-<date>.bundle` the previous session sent.

```text
Run the study per docs/CLOUD_RUN.md in https://github.com/CommanderTvis/tereditor-lsp-research.

Clone it to /root/study, read AGENTS.md and docs/CLOUD_RUN.md, and follow the runbook from Phase 0 to Phase D without
stopping: this message is the owner's go for the confirmatory run, within the runbook's budget. The attached JetBrains
activation code is the licence (save it as license.zip, or license.txt for the bare code; never print or commit it).
If a study-<date>.bundle is attached, resume from it as Phase 0 describes.

Send the git bundle after every project and every phase, keep the session busy until the final downloads are sent,
and stop and report instead of working around a refused permission or a harness failure you cannot fix within the
harness.
```
