#!/bin/sh
# The package's own dependencies and every optional backend its tests import, at the versions of the repository's uv.lock
# (newer pydantic, semver and pytest change JSON schemas, deprecation warnings and equality, which the tests treat as
# errors), into the grading home's virtual environment (CPython 3.12). The package itself is imported from the work tree.
set -e
python -m venv "$HOME/venv"
"$HOME/venv/bin/python" -m pip install -q --disable-pip-version-check --no-input \
  pytest==8.4.2 dirty-equals==0.11 coverage pydantic==2.12.5 pydantic-core==2.41.5 typing-extensions pydantic-settings \
  phonenumbers==9.0.27 pycountry==24.6.1 jsonschema==4.25.1 semver==3.0.4 python-ulid==3.1.0 pendulum==3.2.0 \
  pymongo==4.16.0 pytz==2026.1.post1 tzdata==2025.3 cron-converter==1.3.1 uuid-utils==0.14.1
