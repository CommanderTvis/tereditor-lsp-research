# SETBIT and BITFIELD can leave the KEYSIZES histogram inconsistent

SETBIT and BITFIELD can corrupt the KEYSIZES histogram in two pre-existing string write paths.

1. Both commands use `strOldSize > 0` as a proxy for an existing key. An existing empty string therefore remains counted in the zero-size bin after it grows:

```
SET k ""
SETBIT k 100000 1
DEL k
```

With `DEBUG_ASSERTIONS`, the final DEL detects a negative histogram bin. Production builds silently retain incorrect KEYSIZES counts. BITFIELD has the same guard.

2. Both commands update the histogram after `notifyKeyspaceEvent()`. A module callback that deletes or mutates the key on the `setbit` notification observes the new string length before its histogram entry has moved, so the nested operation decrements the wrong bin.

The write helper should explicitly report whether it created the key, and existing-key length changes should update the histogram before notification callbacks run.

This was found while reviewing #15331.
