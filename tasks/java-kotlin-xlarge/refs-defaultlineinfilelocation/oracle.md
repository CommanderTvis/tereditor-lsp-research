# Oracle: refs-defaultlineinfilelocation

Derived from the pinned source by listing every whole-word occurrence of the name in Java, Kotlin and Groovy files (24
lines in 9 files) and classifying each by the declaring package and the imports of its file: the other two types of that
name (`org.gradle.internal.build.event.types` in daemon-messaging and `org.gradle.tooling.events.problems.internal` in
tooling-api) account for their own files and for the use through a fully qualified name in `ProblemsProgressEventUtils.java`
and the import in `BuildProgressListenerAdapter.java`. The two declaration lines (class, line 23, and private constructor, line 29,
of the declaring file) are excluded as the prompt says; 14 locations remain, in 5 files. No language server is involved; the
names do not occur in other kinds of files. Judgement call: the `import` lines count as uses.
