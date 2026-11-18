# Oracle: rename-indexeddisi

`gold.patch` is a rename of the declaration, its file and every reference that resolves to it, made by a script that
rewrites `IndexedDISI` only in files of the declaring package or that name its fully qualified class (the same simple name
is declared by other types in other packages), then checked by the compiler: `./gradlew compileTestJava` succeeds
for every module with the patch applied and the held-out test (`hidden/`) and the type's own tests pass. No language
server is involved. Judgement calls: the new name was chosen by hand; documentation outside Java files was not renamed
(none refers to the class); the same-named types in other packages are deliberately left alone and the prompt says so.
