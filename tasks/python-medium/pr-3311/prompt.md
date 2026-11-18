`TypeError: Instance.__init__() missing 1 required positional argument: 'proxied'` in random brain

### Steps to reproduce

The following code triggers a `TypeError` in astroid:

```python
from random import sample

a = list({list(None)}) * 1
b = sample(a, 1)
```

This bug was discovered by OSS-Fuzz:
https://issues.oss-fuzz.com/issues/566825426 (report not public yet)

### Current behavior
```python-traceback
Traceback (most recent call last):
  File "pylint/pylint/checkers/utils.py", line 1378, in safe_infer
    value = next(infer_gen)
  File "astroid/astroid/nodes/node_ng.py", line 140, in infer
    for result in self._explicit_inference(
                  ~~~~~~~~~~~~~~~~~~~~~~~~^
        self,  # type: ignore[arg-type]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        context,
        ^^^^^^^^
    ):
    ^
  File "astroid/astroid/inference_tip.py", line 67, in inner
    raise e from None
  File "astroid/astroid/inference_tip.py", line 64, in inner
    result = _cache[func, node, context] = list(func(node, context))
                                                ~~~~^^^^^^^^^^^^^^^
  File "astroid/astroid/brain/brain_random.py", line 92, in infer_random_sample
    _clone_node_with_lineno(elt, parent=new_node, lineno=new_node.lineno)
    ~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "astroid/astroid/brain/brain_random.py", line 45, in _clone_node_with_lineno
    new_node = cls(**init_params)
TypeError: Instance.__init__() missing 1 required positional argument: 'proxied'

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
aec13fb60
