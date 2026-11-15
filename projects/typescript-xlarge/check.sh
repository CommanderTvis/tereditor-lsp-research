#!/bin/sh
# angular is built and tested with Bazel, which the grading toolchain does not have and which cannot fetch its
# toolchains without network; the project's tasks are answer tasks, graded against oracle.txt without a build.
true
