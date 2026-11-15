# callgraph.py <javap -c -p -s output> [--targets | --callers Class.method]
# Call graph from bytecode (javac output read with javap), not a language server.
# Nodes: (class, name, descriptor). Edges: every invoke* instruction; a call on a project type also reaches every
# override of the resolved method in the project's subtypes of the static receiver (class hierarchy analysis); calls
# through JDK types are not followed into project code. A lambda body lambda$m$N is attributed to the methods named m
# of its class (where javac put the invokedynamic).
import re, sys, collections

path = sys.argv[1]
classes = {}        # internal name -> dict(public, super, ifaces, methods{(name,desc): access})
order = []
cur = None; meth = None
calls = collections.defaultdict(set)  # (cls,name,desc) -> set of (owner,name,desc,kind)
hdr = re.compile(r'^(?P<mods>(?:(?:public|private|protected|static|final|abstract|synchronized|native|default|strictfp|volatile|transient|sealed|non-sealed)\s+)*)(?:class|interface|enum)\s+(?P<name>[\w.$]+)(?:<.*?>)?(?:\s+extends\s+(?P<ext>[^{]+?))?(?:\s+implements\s+(?P<impl>[^{]+?))?\s*\{')
mhdr = re.compile(r'^  (?P<mods>(?:(?:public|private|protected|static|final|abstract|synchronized|native|default|strictfp|volatile|transient|bridge|synthetic)\s+)*)(?:<.*?>\s+)?(?:(?P<ret>[\w.$\[\]<>?, ]+?)\s+)?(?P<name>[\w.$<>"]+)\((?P<params>.*)\)(?:\s+throws\s+.*)?;$')
inv = re.compile(r'invoke(virtual|special|static|interface)\s+#\d+\s+// (?:Interface)?Method (?:(?P<owner>[\w/$]+)\.)?(?P<name>"?<?[\w$]+>?"?):(?P<desc>\S+)')
for line in open(path, encoding='utf-8'):
    line = line.rstrip('\n')
    m = hdr.match(line)
    if m:
        name = m.group('name').replace('.', '/')
        def split(s):
            return [x.strip().split('<')[0].replace('.', '/') for x in re.split(r',(?![^<]*>)', s)] if s else []
        ext = split(m.group('ext'))
        isiface = ' interface ' in ' ' + line
        cur = name; order.append(name)
        classes[name] = dict(public='public' in m.group('mods').split(), iface=isiface,
                             sup=(None if isiface else (ext[0] if ext else 'java/lang/Object')),
                             ifaces=(ext if isiface else split(m.group('impl'))), methods={})
        meth = None; continue
    if cur is None: continue
    m = mhdr.match(line)
    if m and '(' in line:
        meth = dict(mods=m.group('mods').split(), name=m.group('name'), desc=None)
        if meth['name'] == cur.replace('/', '.'):
            meth['name'] = '<init>'
        continue
    if meth is not None and line.startswith('    descriptor: ') and meth['desc'] is None:
        meth['desc'] = line.split(': ', 1)[1]
        classes[cur]['methods'][(meth['name'], meth['desc'])] = meth['mods']
        continue
    m = inv.search(line)
    if m and meth is not None:
        owner = m.group('owner') or cur
        calls[(cur, meth['name'], meth['desc'])].add((owner, m.group('name').strip('"'), m.group('desc'), m.group(1)))

def supers(c):
    out = []; todo = [c]
    while todo:
        x = todo.pop()
        if x not in classes: continue
        for s in ([classes[x]['sup']] if classes[x]['sup'] else []) + classes[x]['ifaces']:
            if s and s not in out: out.append(s); todo.append(s)
    return out
subs = collections.defaultdict(set)
for c in classes:
    for s in supers(c): subs[s].add(c)

def resolve(owner, name, desc):
    # declaration found from owner upwards
    for c in [owner] + supers(owner):
        if c in classes and (name, desc) in classes[c]['methods']:
            return (c, name, desc)
    return None

def targets(owner, name, desc, kind):
    if owner not in classes: return set()
    out = set(); r = resolve(owner, name, desc)
    if r: out.add(r)
    if kind in ('virtual', 'interface'):
        for s in subs[owner]:
            if (name, desc) in classes[s]['methods']:
                out.add((s, name, desc))
    return out

graph = collections.defaultdict(set)   # caller -> callees
for caller, cs in calls.items():
    for (o, n, d, k) in cs:
        for t in targets(o, n, d, k):
            graph[caller].add(t)
# lambdas
for c in classes:
    for (n, d) in classes[c]['methods']:
        lm = re.match(r'lambda\$(.+)\$\d+$', n)
        if lm:
            for (n2, d2) in classes[c]['methods']:
                if n2 == lm.group(1):
                    graph[(c, n2, d2)].add((c, n, d))
rev = collections.defaultdict(set)
for a, bs in graph.items():
    for b in bs: rev[b].add(a)

def pubclass(c):
    # public top-level, or nested with every enclosing class public
    parts = c.split('$');
    for i in range(1, len(parts) + 1):
        cc = '$'.join(parts[:i])
        if cc not in classes or not classes[cc]['public']: return False
    return True
def entry(node):
    c, n, d = node
    mods = classes[c]['methods'].get((n, d), [])
    return pubclass(c) and 'public' in mods and n != '<init>' and not n.startswith('lambda$') and 'synthetic' not in mods
def fq(node):
    return node[0].replace('/', '.').replace('$', '.') + '.' + node[1]
def reach(node):
    seen = set(); todo = [node]
    while todo:
        x = todo.pop()
        for p in rev[x]:
            if p not in seen: seen.add(p); todo.append(p)
    return seen

if sys.argv[2] == '--targets':
    lo, hi = int(sys.argv[3]), int(sys.argv[4])
    names = collections.Counter((c, n) for c in classes for (n, d) in classes[c]['methods'])
    for c in sorted(classes):
        for (n, d), mods in sorted(classes[c]['methods'].items()):
            if 'public' in mods or n.startswith('lambda$') or n in ('<init>', '<clinit>') or names[(c, n)] > 1: continue
            if 'synthetic' in mods: continue
            ents = sorted({fq(x) for x in reach((c, n, d)) if entry(x)} - {fq((c, n, d))})
            if lo <= len(ents) <= hi:
                print(f"{fq((c, n, d))}\t{d}\t{len(ents)}")
elif sys.argv[2] == '--callers':
    want = sys.argv[3]
    nodes = [(c, n, d) for c in classes for (n, d) in classes[c]['methods'] if fq((c, n, d)) == want]
    ents = set()
    for x in nodes:
        ents |= {fq(y) for y in reach(x) if entry(y)}
    for e in sorted(ents): print(e)
