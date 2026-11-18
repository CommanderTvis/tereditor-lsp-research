# Detect truncated or malformed license keys and log a clear message

Sub-issue of LuckyPennySoftware/AutoMapper#4659.

## Problem

In 3 support cases the key was missing its last few characters, from copy/paste or email formatting. Validation fails with `IDX10511: Signature validation failed` (or IDX14100/IDX14102 for badly malformed values). That tells the user nothing useful, and each case needed a round trip with support to diagnose.

Stripping whitespace doesn't help here: the key is simply incomplete.

## Fix

Before calling `ValidateTokenAsync` in `src/AutoMapper/Licensing/LicenseAccessor.cs` (after whitespace is stripped), run a cheap structural check:
- The key has exactly 3 dot-separated segments.
- Each segment contains only base64url characters.
- The signature segment is the expected length for RS256 with the 2048-bit Lucky Penny key: 256 bytes, which is 342 base64url characters.

If the check fails, skip validation and log a clear message at error level, not critical. For example:

> The Lucky Penny software license key appears to be incomplete or corrupted (it may have been truncated when copied). Copy the full key again from https://luckypennysoftware.com/account.

Do **not** include the key itself in the log.

Also, when validation does fail with `SecurityTokenInvalidSignatureException`, add a hint about copy/paste corruption to the existing message, which today is just "Error validating the Lucky Penny software license key".

## Tests

- A key missing 1, 5 or 20 trailing characters → the "incomplete or corrupted" message, and no IDX exception is logged.
- A key with 2 segments or 4 segments → the same message.
- A valid key → unaffected.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

