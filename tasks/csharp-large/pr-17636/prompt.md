# WEB-DL release tag remains in metadata search title

## Description of the bug

The video clean-string parser does not recognize the common `WEB-DL` release tag. When a filename contains both `WEB-DL` and a recognized quality tag, cleaning stops at the quality tag and leaves `WEB-DL` in the title sent to metadata providers.

For example, `Last.Call.for.Nowhere.WEB-DL.1080p` becomes `Last.Call.for.Nowhere.WEB-DL`. After punctuation normalization, TMDb receives `Last Call for Nowhere WEB DL` and returns no result, while `Last Call for Nowhere` identifies the 2016 movie correctly.

## Reproduction steps

1. Create the default `NamingOptions`.
2. Call `VideoResolver.TryCleanString("Last.Call.for.Nowhere.WEB-DL.1080p", options, out var name)`.
3. Inspect `name`.

## Current behavior

The result is `Last.Call.for.Nowhere.WEB-DL`.

## Expected behavior

The result is `Last.Call.for.Nowhere`.

## Version

- Jellyfin Server 10.11.11
- Current `master` at `7f3bbd5654516e72e38e49e3316200dca89f91d3`

## Environment

- OS: Linux
- Virtualization: Docker
- Media type: M4V movie in a dedicated folder

## Logs

No relevant log entry is emitted. The behavior is isolated in `VideoResolver.TryCleanString` and can be reproduced with a unit test.

## Additional information

Adding `web-dl` to the existing release-tag alternatives, together with a regression test, should allow metadata providers to receive the intended title.

