# Starting the cloud run

```sh
git clone https://github.com/CommanderTvis/tereditor-lsp-research && cd tereditor-lsp-research
claude --cloud "Run the study per docs/CLOUD_RUN.md: follow it from Phase 0 to Phase D without stopping. This message is the owner's go for the confirmatory run."
```

The environment it runs in (network access Full, the licence as `STUDY_LICENSE_B64`) is set up once as described in
[CLOUD_RUN.md](CLOUD_RUN.md#starting-it-the-owners-part). The runbook tells the session to keep working until the final
downloads are sent, and to stop and report when a harness failure or a refused permission cannot be fixed within the
harness.
