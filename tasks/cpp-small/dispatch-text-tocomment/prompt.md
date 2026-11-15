In this code base, `p` is a `const tinyxml2::XMLNode*` that points to a `tinyxml2::XMLText` object (for example one
created with `XMLDocument::NewText`). Which function definition runs for the call `p->ToComment()`?

Write the answer to `ANSWER.txt` in the repository root as a single line `relative/path:LINE`, where LINE is the
1-based line on which the function's name appears in the definition that runs (the one with the body), for example
`tinyxml2.cpp:120`.
