Move the exception class `UseInferenceDefault` out of `astroid/exceptions.py` into a new module
`astroid/use_inference_default.py`, and update every import and reference so the project continues to work: the brain
plugins, the node classes, the inference tip machinery, the package root (`astroid.UseInferenceDefault` must stay
importable) and the tests. The class must be declared in the new module only: do not leave a copy or a re-export behind in
`astroid/exceptions.py` (remove it from that module's `__all__` as well). Updating the documentation files is optional.
