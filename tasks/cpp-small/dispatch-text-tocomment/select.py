# dispatch_select.py <root> <tu>...: candidates for a `dispatch` task, from clang's AST (clang++ -Xclang -ast-dump=json),
# not from a language server. A candidate is (D, F): D a non-abstract class defined in the project, F a virtual member
# function signature that D inherits without declaring it, with at least two definitions among D's base classes and
# the classes derived from F's first declarer (so a call through the base can land in more than one place). The answer
# is D's final overrider of F, as path:line of its definition (the line of the function name).
import json, subprocess, sys, os
root = os.path.abspath(sys.argv[1]); tus = sys.argv[2:]
classes = {}   # name -> {'bases': [...], 'methods': {sig: id}}
ids = {}
decl = {}      # (class, sig) -> dict(cls, sig, virtual, pure, file, line, body)
cur = {}
def upd(loc):  # clang prints a file or line only when it changed since the previous location printed
    if not loc: return
    for part in ([loc['spellingLoc'], loc['expansionLoc']] if 'spellingLoc' in loc else [loc]):
        if 'file' in part: cur['file'] = part['file']
        if 'line' in part: cur['line'] = part['line']
def visit(node, cls):
    r = node.get('range', {}); upd(node.get('loc')); f, l = cur.get('file'), cur.get('line'); upd(r.get('begin')); upd(r.get('end'))
    k = node.get('kind'); inner = node.get('inner', [])
    if not f: f = ''
    proj = f and os.path.abspath(os.path.join(root, f) if not os.path.isabs(f) else f).startswith(root + '/')
    if k == 'CXXRecordDecl' and node.get('completeDefinition') and node.get('name') and proj and cls is None:
        c = classes.setdefault(node['name'], {'bases': [], 'methods': {}})
        c['bases'] = [b['type']['qualType'].replace('tinyxml2::', '').split('<')[0] for b in node.get('bases', [])]
        for ch in inner: visit(ch, node['name'])
        return
    if k == 'CXXMethodDecl' and proj:
        body = any(x.get('kind') == 'CompoundStmt' for x in inner)
        rf = os.path.relpath(os.path.abspath(os.path.join(root, f) if not os.path.isabs(f) else f), root)
        if cls not in (None, '?') and not node.get('isImplicit'):
            s = node['name'] + ' ' + node['type']['qualType']
            virt = node.get('virtual', False) or any(x.get('kind') in ('OverrideAttr', 'FinalAttr') for x in inner)
            d = decl.setdefault((cls, s), dict(cls=cls, sig=s, virtual=virt, pure=node.get('pure', False), file=rf, line=l, body=None, bodyline=None))
            if body: d['body'], d['bodyline'] = rf, l
            classes[cls]['methods'][s] = (cls, s); ids[node['id']] = (cls, s)
        elif cls is None and body and node.get('previousDecl') in ids:
            d = decl[ids[node['previousDecl']]]; d['body'], d['bodyline'] = rf, l
    for ch in inner: visit(ch, cls if k != 'CXXRecordDecl' else '?')
for tu in tus:
    out = subprocess.run(['clang++', '-std=c++17', '-fsyntax-only', '-w', '-I' + root, '-Xclang', '-ast-dump=json', os.path.join(root, tu)],
                         capture_output=True, text=True, cwd=root).stdout
    cur.clear(); ids.clear(); visit(json.loads(out), None)
def chain(c):  # c and its bases, nearest first (single inheritance in this project)
    out = [c]
    while classes.get(out[-1], {}).get('bases'): out.append(classes[out[-1]]['bases'][0])
    return out
def virtual_sigs(c):
    return {s for k in chain(c) for s, i in classes.get(k, {}).get('methods', {}).items() if decl[i]['virtual']}
def final(c, s):
    for k in chain(c):
        i = classes.get(k, {}).get('methods', {}).get(s)
        if i is not None: return decl[i]
    raise KeyError((c, s))
def abstract(c): return any(final(c, s)['pure'] for s in virtual_sigs(c))
rows = []
for c in sorted(classes):
    if abstract(c) or not classes[c]['bases']: continue
    for s in sorted(virtual_sigs(c)):
        if s in classes[c]['methods']: continue
        root_cls = [k for k in chain(c) if s in classes.get(k, {}).get('methods', {})][-1]
        family = [k for k in classes if root_cls in chain(k)]
        ndefs = sum(1 for k in family if s in classes[k]['methods'] and decl[classes[k]['methods'][s]]['body'])
        if ndefs < 2: continue
        d = final(c, s)
        rows.append(f"{c}\t{s}\t{d['cls']}\t{d['body']}:{d['bodyline']}\t{ndefs}")
print('\n'.join(rows))
