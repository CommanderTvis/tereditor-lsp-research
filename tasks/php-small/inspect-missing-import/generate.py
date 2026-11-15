# inspect_imports.py <repo> <srcdir> <k>: candidates and edits for an inspect task "which files lost a needed import".
# Candidate: a file under srcdir declaring a class or trait, with at least one `use A\B\Name;` import (no alias, no
# function/const import) whose short name occurs as a whole word in the body after the imports and is not declared in
# the file's own namespace directory. The subject import of a file is the first such import. Prints the candidates
# (sorted by path) to stdout; with --apply <file>... applies: the first half (defect) delete the import, the second
# half (decoy) delete it and write every use of the short name fully qualified.
import os, re, sys
repo, src = sys.argv[1], sys.argv[2]
os.chdir(repo)
use_re = re.compile(r'^use ([A-Za-z_\\]+\\(\w+));\n', re.M)
def subject(path):
    t = open(path).read()
    if not re.search(r'^(?:(?:final|abstract|readonly)\s+)*(class|trait)\s', t, re.M): return None
    imports = list(use_re.finditer(t))
    if not imports: return None
    body = t[imports[-1].end():]
    d = os.path.dirname(path)
    for m in imports:
        fq, name = m.group(1), m.group(2)
        if os.path.exists(os.path.join(d, name + '.php')): continue
        if re.search(r'(?<![\\\w$])' + name + r'\b', body): return m, fq, name, t
    return None
if sys.argv[3] == '--apply':
    files = sys.argv[4:]; half = len(files) // 2
    for i, f in enumerate(files):
        m, fq, name, t = subject(f)
        rest = t[m.end():]
        if i >= half:  # decoy: fully qualify
            rest = re.sub(r'(?<![\\\w$>:])' + name + r'\b', lambda _: '\\' + fq, rest)
        open(f, 'w').write(t[:m.start()] + rest)
        print(('DEFECT ' if i < half else 'DECOY  ') + f + ' ' + fq)
else:
    for root, _, fs in os.walk(src):
        for fn in sorted(fs):
            p = os.path.join(root, fn)
            if p.endswith('.php'):
                s = subject(p)
                if s: print(p + '\t' + s[1])
