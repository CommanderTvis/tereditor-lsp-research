# subclasses.py <root> <pkg>: per class defined in <pkg> (non-test), its transitive subclasses across all .py files of
# <root>, resolved by base-class simple name (an over-approximation; the chosen one is checked by hand).
import ast, os, sys, collections
root, pkg = sys.argv[1], sys.argv[2]
defs = collections.defaultdict(list)   # name -> [(file, line)]
bases = []                             # (child name, file, line, [base simple names])
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.')]
    for f in fs:
        if not f.endswith('.py'): continue
        p = os.path.relpath(os.path.join(d, f), root)
        try: t = ast.parse(open(os.path.join(root, p), encoding='utf-8', errors='replace').read())
        except SyntaxError: continue
        for n in ast.walk(t):
            if isinstance(n, ast.ClassDef):
                defs[n.name].append((p, n.lineno))
                bs = []
                for b in n.bases:
                    if isinstance(b, ast.Subscript): b = b.value
                    if isinstance(b, ast.Name): bs.append(b.id)
                    elif isinstance(b, ast.Attribute): bs.append(b.attr)
                bases.append((n.name, p, n.lineno, bs))
children = collections.defaultdict(list)
for c, p, l, bs in bases:
    for b in bs: children[b].append((c, p, l))
def trans(name, seen):
    out = []
    for c, p, l in children.get(name, []):
        if (p, l) in seen: continue
        seen.add((p, l)); out.append((c, p, l)); out += trans(c, seen)
    return out
for name, locs in sorted(defs.items()):
    for p, l in locs:
        if not p.startswith(pkg + '/') or '/tests/' in '/' + p: continue
        s = trans(name, set())
        files = {q for _, q, _ in s}
        print(len(s), len(files), name, f'{p}:{l}', 'dup' if len(defs[name]) > 1 else '')
