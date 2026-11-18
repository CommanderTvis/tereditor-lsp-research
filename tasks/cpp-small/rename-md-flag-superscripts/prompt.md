The parser flag `MD_FLAG_SUPERSCRIPTS` should be called `MD_FLAG_SUPERSCRIPT_SPANS`: its siblings name the construct they enable (`MD_FLAG_LATEXMATHSPANS`, `MD_FLAG_WIKILINKS`) and the plural reads like a list of superscripts rather than the span extension.

Rename it everywhere it is used: the definition, every use in the library and in `md2html`, and every mention in comments and documentation, including the README and the prose of the test specifications. `CHANGELOG.md` is a historical record and stays as it is. Do not keep the old name as an alias.
