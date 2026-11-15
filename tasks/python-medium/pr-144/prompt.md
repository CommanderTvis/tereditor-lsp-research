Request: do not use WT_SESSION to detect Windows Terminal

There's a small handful of issues with detecting `WT_SESSION` and using that as an indicator that you can use advanced VT:

* `WT_SESSION` is not an API, and it was my greatest fear when we introduced it that people would use it for feature detection
   * This is why I (so far) refuse to add support for `TERM_PROGRAM` or `TERM_PROGRAM_VERSION`, and would rather us standardize on `TERM` :smile:
* It _will not_ be set by other terminal emulators using the pseudoconsole API (like Visual Studio's terminal, which is built on the WT renderer and where they're considering shipping a copy of OpenConsole down to Windows 10 RS4)
* Everything WT supports is supported by the conhost instance that it uses to back every tab
* Every change to conhost (and therefore WT's VT support) flows back out through the Windows insider program and eventually lands for all console users in the stable builds

It's safer to use feature detection for the console. If you can enable `ENABLE_VIRTUAL_TERMINAL_PROCESSING`, VT is supported; version detection is required for _some things_, unfortunately: if you're beyond 10.0.15063 24-bit color is supported.
