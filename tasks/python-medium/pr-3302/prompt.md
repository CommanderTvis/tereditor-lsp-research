`OverflowError: %c arg not in range(0x110000)` with FormattedValue

### Steps to reproduce

The following code triggers an `OverflowError` in astroid:

```python
a = f'{-1:c}'
```

This bug was discovered by OSS-Fuzz:
https://issues.oss-fuzz.com/issues/556293969 (report not public yet)

### Current behavior
```python-traceback
Traceback (most recent call last):
  File "pylint/pylint/checkers/utils.py", line 1378, in safe_infer
    value = next(infer_gen)
  File "astroid/astroid/nodes/node_ng.py", line 160, in infer
    for i, result in enumerate(self._infer(context=context)):
                     ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "astroid/astroid/nodes/node_classes.py", line 4848, in _infer
    yield from self._infer_with_values(context)
  File "astroid/astroid/nodes/node_classes.py", line 4856, in _infer_with_values
    for inferred in self._infer_from_values(self.values, context):
                    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^
  File "astroid/astroid/nodes/node_classes.py", line 4874, in _infer_from_values
    for node in cls._safe_infer_from_node(nodes[0], context):
                ~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^
  File "astroid/astroid/nodes/node_classes.py", line 4895, in _safe_infer_from_node
    yield from node._infer(context)
  File "astroid/astroid/nodes/node_classes.py", line 4764, in _infer
    formatted = format(value_to_format, format_spec.value)
OverflowError: %c arg not in range(0x110000)

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "pylint/pylint/utils/ast_walker.py", line 87, in walk
    callback(astroid)
    ~~~~~~~~^^^^^^^^^
  File "pylint/pylint/checkers/base/name_checker/checker.py", line 487, in visit_assignname
    utils.safe_infer(assign_type.value) if assign_type.value else None
    ~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^
  File "pylint/pylint/checkers/utils.py", line 1382, in safe_infer
    raise AstroidError from e
astroid.exceptions.AstroidError
```

### Expected behavior
No crash

### Version
36aee9b5385
