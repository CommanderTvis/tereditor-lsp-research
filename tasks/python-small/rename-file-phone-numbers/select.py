# an.py <root> <pkg> <kind>: candidate subjects for synthetic tasks, by an ast walk (no language server).
#  symbols: top-level public functions/classes of <pkg> (non-test): defs-with-the-name in the repo, files referencing it in code
#           (Name, Attribute attr, import alias), occurrences of the word outside code (comments, docstrings, strings, docs)
#  modules: non-__init__ public modules of <pkg> with the number of other .py files importing them by module path
import ast, os, sys, re, collections
root, pkg, kind = sys.argv[1], sys.argv[2], sys.argv[3]
files=[]
for d, ds, fs in os.walk(root):
    ds[:] = [x for x in ds if not x.startswith('.') and x not in ('node_modules','venv','.venv')]
    files += [os.path.relpath(os.path.join(d, f), root) for f in fs]
py=[f for f in files if f.endswith('.py')]
txt={f:open(os.path.join(root,f),encoding='utf-8',errors='replace').read() for f in files if f.endswith(('.py','.md','.rst','.txt','.toml','.cfg','.ini','.yml','.yaml'))}
trees={}
for f in py:
    try: trees[f]=ast.parse(txt[f])
    except SyntaxError: pass
def istest(f): return '/tests/' in '/'+f or os.path.basename(f).startswith('test') or f.startswith('tests/')
def modname(rel):
    p=rel[:-3].replace(os.sep,'.'); return p[:-9] if p.endswith('.__init__') else p
if kind=='symbols':
    defs=collections.defaultdict(list)
    for f,t in trees.items():
        for n in ast.walk(t):
            if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef,ast.ClassDef)): defs[n.name].append(f'{f}:{n.lineno}')
    top=[]
    for f,t in trees.items():
        if not f.startswith(pkg+'/') or istest(f): continue
        for n in t.body:
            if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef,ast.ClassDef)) and not n.name.startswith('_'): top.append((f,n.lineno,n.name))
    for f,l,name in sorted(top):
        refs=collections.Counter(); nlines=0
        for g,t in trees.items():
            c=0
            for n in ast.walk(t):
                if isinstance(n,ast.Name) and n.id==name: c+=1
                elif isinstance(n,ast.Attribute) and n.attr==name: c+=1
                elif isinstance(n,(ast.ImportFrom,ast.Import)) and any(a.name.split('.')[-1]==name for a in n.names): c+=1
            if g==f: c=max(0,c-1)
            if c: refs[g]=c
        total=0
        for g,s in txt.items(): total+=len(re.findall(r'\b'+re.escape(name)+r'\b',s))
        code=sum(refs.values())+1
        print(f'{f}:{l}\t{name}\tdefs={len(defs[name])}\tcodefiles={len(refs)}\tcoderefs={sum(refs.values())}\tother={total-code}')
else:
    mods={modname(f):f for f in trees if f.startswith(pkg+'/') and not istest(f) and not f.endswith('__init__.py') and not os.path.basename(f).startswith('_')}
    users=collections.defaultdict(set)
    for f,t in trees.items():
        me=modname(f); base=me if f.endswith('__init__.py') else me.rpartition('.')[0]
        for n in ast.walk(t):
            if isinstance(n,ast.ImportFrom):
                if n.level:
                    b=base
                    for _ in range(n.level-1): b=b.rpartition('.')[0]
                    m=(b+'.'+n.module) if n.module else b
                else: m=n.module or ''
                if m in mods and m!=me: users[m].add(f)
                for a in n.names:
                    if m+'.'+a.name in mods and m+'.'+a.name!=me: users[m+'.'+a.name].add(f)
            elif isinstance(n,ast.Import):
                for a in n.names:
                    if a.name in mods and a.name!=me: users[a.name].add(f)
    for m,f in sorted(mods.items(), key=lambda kv: kv[1]): print(f'{f}\t{m}\tusers={len(users[m])}')
