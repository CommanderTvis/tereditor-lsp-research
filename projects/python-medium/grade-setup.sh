#!/bin/sh
# Grading dependencies of rich, fetched once per commit with network: a virtual environment in the grading home with
# rich's runtime and test dependencies at the versions of v15.0.0's poetry.lock, plus commonmark (what rich used before
# markdown-it-py) and pprintpp (a dependency of rich 3.x), for the base commits of mined pull requests, and a pinned pytest.
set -e
python -m venv "$HOME/venv"
"$HOME/venv/bin/python" -m pip install -q --disable-pip-version-check --no-input \
  pytest==8.3.5 pygments==2.19.2 markdown-it-py==3.0.0 mdurl==0.1.2 attrs==21.4.0 typing-extensions==4.13.2 \
  commonmark==0.9.1 colorama==0.4.6 pprintpp==0.4.0
