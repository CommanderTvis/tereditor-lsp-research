# callers_api.py <entry-regex-file> <callgraph-dump>...: like callers.py, with the entry points restricted to the names
# matching one of the regular expressions in the first file (the exported FMT_API functions outside fmt::detail).
import sys, collections, re
pats = [re.compile('^' + l.strip() + '$') for l in open(sys.argv[1]) if l.strip()]
g = collections.defaultdict(set)
for path in sys.argv[2:]:
    for line in open(path):
        m = re.match(r'\s*Function: (.*?) calls: ?(.*)$', line.rstrip('\n'))
        if m: g[m.group(1)].update(m.group(2).split())
nodes = set(g) | {c for v in g.values() for c in v}
entries = sorted(n for n in nodes if any(p.match(n) for p in pats))
reach = {}
for e in entries:
    seen, todo = set(), [e]
    while todo:
        x = todo.pop()
        for c in g.get(x, ()):
            if c not in seen: seen.add(c); todo.append(c)
    reach[e] = seen
print('#entries\t' + str(len(entries)) + '\t' + ' '.join(entries))
for t in sorted(n for n in nodes if n.startswith('fmt::detail::') and '<' not in n and '(' not in n):
    callers = sorted(e for e in entries if t in reach[e] and e != t)
    print(t + '\t' + str(len(callers)) + '\t' + ' '.join(callers))
