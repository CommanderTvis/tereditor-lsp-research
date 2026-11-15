# overrides.py <root> <pkg>: methods (not dunder) of classes defined in <pkg> (non-test) overridden in at least one
# transitive subclass anywhere in <root>; class resolution by simple name. Output: overrides path:line Class.method
import ast, os, sys, collections
root, pkg = sys.argv[1], sys.argv[2]
classes = []  # (name, path, line, bases, methods{name: line})
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.')]
    for f in fs:
        if not f.endswith('.py'): continue
        p = os.path.relpath(os.path.join(d, f), root)
        try: t = ast.parse(open(os.path.join(root, p), encoding='utf-8', errors='replace').read())
        except SyntaxError: continue
        for n in ast.walk(t):
            if isinstance(n, ast.ClassDef):
                bs = []
                for b in n.bases:
                    if isinstance(b, ast.Subscript): b = b.value
                    if isinstance(b, ast.Name): bs.append(b.id)
                    elif isinstance(b, ast.Attribute): bs.append(b.attr)
                ms = {m.name: m.lineno for m in n.body if isinstance(m, (ast.FunctionDef, ast.AsyncFunctionDef))}
                classes.append((n.name, p, n.lineno, bs, ms))
children = collections.defaultdict(list)
for c in classes:
    for b in c[3]: children[b].append(c)
def subs(name, seen):
    out = []
    for c in children.get(name, []):
        if (c[1], c[2]) in seen: continue
        seen.add((c[1], c[2])); out.append(c); out += subs(c[0], seen)
    return out
for name, p, l, bs, ms in classes:
    if not p.startswith(pkg + '/') or '/tests/' in '/' + p or os.path.basename(p).startswith('test'): continue
    s = subs(name, set())
    for m, ml in ms.items():
        if m.startswith('__') and m.endswith('__'): continue
        o = [c for c in s if m in c[4]]
        if o: print(len(o), f'{p}:{ml}', f'{name}.{m}')
