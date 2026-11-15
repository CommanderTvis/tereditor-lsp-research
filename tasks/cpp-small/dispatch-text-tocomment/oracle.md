# Oracle: the definition `p->ToComment()` runs for a `const XMLNode*` pointing to an `XMLText`

Derived without a language server, in two independent ways.

1. clang's AST (`select.py`, Apple clang 21 on the host, `clang++ -std=c++17 -Xclang -ast-dump=json` of the three
   translation units): `XMLText` declares no `ToComment`; its only base is `XMLNode`, which defines both
   `XMLComment* ToComment()` (tinyxml2.h:696) and `const XMLComment* ToComment() const` (tinyxml2.h:718). A call
   through a pointer to const selects the const overload, so the final overrider for `XMLText` is `XMLNode`'s, at
   tinyxml2.h:718. `XMLComment` overrides both (tinyxml2.h:1037 and 1040), which is why the function counts as
   dispatched.
2. Run time: a copy of the tree with `fputs("HIT tinyxml2.h:<line>")` added at the start of all four bodies, and a
   driver `XMLDocument doc; XMLText* t = doc.NewText("x"); const XMLNode* p = t; p->ToComment();`, built with
   `c++ -std=c++17` and run: it prints exactly `HIT tinyxml2.h:718`.

Judgement calls: none.
