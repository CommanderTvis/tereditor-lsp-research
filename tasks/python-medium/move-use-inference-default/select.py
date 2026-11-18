# classimports.py <root> <pkg>: top-level classes of <pkg> modules (non-test), with the number of other .py files that
# import them by name (from <module> import Name, absolute or relative). Output: files path:line Name
import ast, os, sys, collections
root, pkg = sys.argv[1], sys.argv[2]
def modname(rel):
    p = rel[:-3].replace(os.sep, '.')
    return p[:-9] if p.endswith('.__init__') else p
files = []
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.')]
    files += [os.path.relpath(os.path.join(d, f), root) for f in fs if f.endswith('.py')]
trees = {}
for f in files:
    try: trees[f] = ast.parse(open(os.path.join(root, f), encoding='utf-8', errors='replace').read())
    except SyntaxError: pass
classes = {}
for f, t in trees.items():
    if not f.startswith(pkg + '/') or '/tests/' in '/' + f or os.path.basename(f).startswith('test'): continue
    for n in t.body:
        if isinstance(n, ast.ClassDef): classes[(modname(f), n.name)] = f'{f}:{n.lineno}'
users = collections.defaultdict(set)
for f, t in trees.items():
    me = modname(f); base = me if f.endswith('__init__.py') else me.rpartition('.')[0]
    for n in ast.walk(t):
        if isinstance(n, ast.ImportFrom):
            if n.level:
                b = base
                for _ in range(n.level - 1): b = b.rpartition('.')[0]
                m = (b + '.' + n.module) if n.module else b
            else: m = n.module or ''
            for a in n.names:
                if (m, a.name) in classes and m != me: users[(m, a.name)].add(f)
for k, loc in sorted(classes.items(), key=lambda kv: kv[1]):
    print(len(users[k]), loc, k[1])
