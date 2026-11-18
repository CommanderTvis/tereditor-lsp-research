# Oracle: refs of RawSqlString

Not derived from a language server. Exhaustive whole-word text candidate list over the whole repository at the pinned commit
(`rg -nw RawSqlString .`), then classified by hand: kept are the lines whose first non-blank characters are not `//`
(declaration, constructor, two implicit operators, parameter and `typeof`/`nameof`/cast uses, lambdas in tests); dropped are the
`///` doc-comment mentions, one regular comment in Tests/Linq/UserTests/Issue5154Tests.cs, and the lines of the API listing
Source/LinqToDB/PublicAPI/PublicAPI.Shipped.txt (not C#). The name is declared once and no other symbol of that name exists.
