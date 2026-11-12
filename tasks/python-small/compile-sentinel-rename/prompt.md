We renamed the "no default" sentinel in `toolz/utils.py` from `no_default` to `NO_DEFAULT`, and only that line was
changed. The package is now broken. Update the rest of the code base, library and tests, to use the new name so that
everything works again. Keep the new name; do not add an alias for the old one.
