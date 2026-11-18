# Strip all whitespace from the license key

Sub-issue of LuckyPennySoftware/AutoMapper#4659.

## Problem

A valid license key that contains whitespace fails with a misleading signature error:

```
Microsoft.IdentityModel.Tokens.SecurityTokenInvalidSignatureException: IDX10511: Signature validation failed. Keys tried: 'Microsoft.IdentityModel.Tokens.RsaSecurityKey, KeyId: 'LuckyPennySoftwareLicenseKey/bbb13acb59904d89b4cb1c85f088ccf9' ...
```

This happens often in practice:
- Resellers deliver keys inside PDFs, and PDF renderers insert newlines. Both confirmed newline cases in support came from PDF delivery.
- Email clients wrap the key across lines. In one case a reseller's email broke the signature after `-` characters.
- Kubernetes secrets created from files (`kubectl create secret --from-file`) and mounted secret files usually keep a trailing newline.
- Config files and environment variables pick up trailing spaces.

Online JWT decoders (jwt.io) quietly ignore the whitespace, so customers check the key there, see that it's valid, and report a bug.

| Key value | Result |
|---|---|
| valid key | OK |
| key + `\n` / `\r\n` / `" "` | IDX10511 |
| key with embedded line breaks | IDX10511 |

## Fix

In `src/MediatR/Licensing/LicenseAccessor.cs` (`ResolveLicenseKey`), remove **all** whitespace characters from each key source, not just leading and trailing ones. This applies to the explicit key(s), the product env var and `LUCKYPENNY_LICENSE_KEY`.

- This is safe: a license key is a JWS in compact form, which contains only base64url characters (`A-Z a-z 0-9 - _`) and `.`, so whitespace is never meaningful.
- A value that is empty after stripping counts as not set, so resolution falls through to the next source.
- Today MediatR already treats a whitespace-only value as not set (`IsNullOrWhiteSpace`), but it passes surrounding or embedded whitespace through unchanged.

## Tests

- Keys with a trailing `\n`, `\r\n`, space or tab, and with embedded line breaks, resolve to the clean key and validate.
- A whitespace-only explicit key falls back to the env vars.
- Whitespace in the env var values is stripped too.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

