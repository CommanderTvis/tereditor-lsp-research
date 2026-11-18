# Oracle: rename ParserOptions

No navigation answer. Grading (grade.sh) is the repository-wide check that the old name is gone from the Kotlin sources and the Markdown docs, the compilation of the library modules (check.sh) and a hidden test naming the new class. gold.patch is a scripted whole-word replacement proven by `./study validate`; no language server is involved. Traps: `GlobalParserOptions` and `DateTimeParserOptions` contain the old name and keep theirs; the old name also occurs in KDoc, in the docs under docs/StardustDocs and in sample code.
