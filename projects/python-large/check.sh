#!/bin/sh
# Build-and-test for Django (not installed; imported from /work): byte-compile the package (catches syntax errors
# anywhere), import the core modules, then run Django's own test runner on SQLite for a subset of test modules.
# The full suite takes far longer than the grading budget, so each task's grade.sh exports DJANGO_TEST_MODULES with
# the test modules (tests/<module>) that exercise the code it touches; the default below is a broad smoke subset.
# The tests run as the unprivileged user "grader" (some assert that file permissions are enforced, which root bypasses).
set -e
export PYTHONPATH=/work PYTHONDONTWRITEBYTECODE=1 HOME=/home/grader
python -m compileall -q -j 0 django > /dev/null
python -c "import django, django.db.models, django.forms, django.template, django.views.generic, django.test"
chown -R grader:grader /work
cd /work/tests
setpriv --reuid=grader --regid=grader --init-groups \
  python -W error::SyntaxWarning runtests.py --settings=test_sqlite --parallel 3 --noinput \
  ${DJANGO_TEST_MODULES:-utils_tests template_tests forms_tests model_fields generic_views}
