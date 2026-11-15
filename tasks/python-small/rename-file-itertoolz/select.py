# modimports.py <root> <pkg-dir> : for each non-__init__, non-test module of the package, the files that import it
# by module path (import a.b.c / from a.b import c / from a.b.c import x / relative forms). Output: count path
import ast, os, sys
root, pkg = sys.argv[1], sys.argv[2]
def modname(path):
    p = os.path.relpath(path, root)[:-3].replace(os.sep, '.')
    return p[:-9] if p.endswith('.__init__') else p
files = []
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.') and x not in ('node_modules',)]
    files += [os.path.join(d, f) for f in fs if f.endswith('.py')]
mods = {modname(f): f for f in files}
imports = {}
for f in files:
    try: tree = ast.parse(open(f, encoding='utf-8', errors='replace').read())
    except SyntaxError: continue
    me = modname(f); ispkg = f.endswith('__init__.py')
    base = me if ispkg else me.rpartition('.')[0]
    got = set()
    for n in ast.walk(tree):
        if isinstance(n, ast.Import):
            for a in n.names:
                parts = a.name.split('.')
                for i in range(1, len(parts) + 1): got.add('.'.join(parts[:i]))
        elif isinstance(n, ast.ImportFrom):
            if n.level:
                b = base
                for _ in range(n.level - 1): b = b.rpartition('.')[0]
                m = (b + '.' + n.module) if n.module else b
            else: m = n.module or ''
            got.add(m)
            for a in n.names: got.add(m + '.' + a.name)
    for g in got:
        if g in mods and g != me: imports.setdefault(g, set()).add(os.path.relpath(f, root))
for m, f in sorted(mods.items()):
    rel = os.path.relpath(f, root)
    if not rel.startswith(pkg + '/') or rel.endswith('__init__.py'): continue
    if '/tests/' in '/' + rel or os.path.basename(rel).startswith('test'): continue
    print(len(imports.get(m, ())), rel)
