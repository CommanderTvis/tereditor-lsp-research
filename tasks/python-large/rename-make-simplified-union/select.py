# funcimports.py <root> <pkg> [lo hi]: top-level functions of <pkg> modules (non-test) imported by name in lo..hi other
# .py files and whose name is also defined elsewhere (another function, method or class of that name in the tree).
# Output: importing-files other-definitions path:line name
import ast, os, sys, collections
root, pkg = sys.argv[1], sys.argv[2]
lo, hi = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (0, 10**9)
def modname(rel):
    p = rel[:-3].replace(os.sep, '.')
    return p[:-9] if p.endswith('.__init__') else p
trees = {}
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.')]
    for f in fs:
        if f.endswith('.py'):
            rel = os.path.relpath(os.path.join(d, f), root)
            try: trees[rel] = ast.parse(open(os.path.join(root, rel), encoding='utf-8', errors='replace').read())
            except (SyntaxError, ValueError): pass
funcs = {}; names = collections.Counter()
for f, t in trees.items():
    for n in ast.walk(t):
        if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)): names[n.name] += 1
    if not f.startswith(pkg + '/') or '/test' in '/' + f: continue
    for n in t.body:
        if isinstance(n, ast.FunctionDef) and not n.name.startswith('_'): funcs[(modname(f), n.name)] = f'{f}:{n.lineno}'
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
                if (m, a.name) in funcs and m != me: users[(m, a.name)].add(f)
for k, loc in sorted(funcs.items(), key=lambda kv: (kv[1].split(':')[0], int(kv[1].split(':')[1]))):
    u = len(users[k]); o = names[k[1]] - 1
    if lo <= u <= hi and o >= 1: print(u, o, loc, k[1])
