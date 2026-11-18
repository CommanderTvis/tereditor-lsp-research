# Oracle: rename file DataFrameSchema.kt

No navigation answer. Grading (grade.sh) checks the file move, that the old name is gone from the Kotlin sources and the Markdown docs, the compilation of the library modules (check.sh) and a hidden test naming the new type. gold.patch is a scripted `git mv` plus whole-word replacement proven by `./study validate`; no language server is involved.
