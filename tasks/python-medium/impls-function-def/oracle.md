# Oracle: transitive subclasses of astroid FunctionDef

Derived without a language server: an ast walk over every .py file of the repository collecting `class` statements whose
bases (a name, an attribute such as `nodes.FunctionDef`, or a subscript of either) lead to `FunctionDef`, followed to a
fixed point (python3 select.py <snapshot> astroid; the same walk restricted to FunctionDef), then checked by hand with

    grep -rnE "^\s*class .*FunctionDef" . --include='*.py'
    grep -rnE "class \w+\(.*(UnboundMethod|PartialFunction|Property|BoundMethod).*\)" . --include='*.py'

Direct subclasses: `PartialFunction` (astroid/objects.py:281), `Property` (astroid/objects.py:355), `AsyncFunctionDef`
(astroid/nodes/scoped_nodes/scoped_nodes.py:1725) and the two `PropertyFuncAccessor` classes defined inside functions of
astroid/interpreter/objectmodel.py (:992 and :1043). No class subclasses any of these five, and no class names
`FunctionDef` through an alias.

Excluded: `UnboundMethod` and `BoundMethod` (astroid/bases.py) and the bound-method classes of the object model and of
brain_functools, which inherit from `Proxy` and not from `FunctionDef`, even though they also define `infer_call_result`.

Judgement calls: the two `PropertyFuncAccessor` classes are kept (they inherit from `nodes.FunctionDef` inside method bodies).
