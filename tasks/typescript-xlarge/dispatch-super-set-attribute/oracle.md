# Oracle: the definition that runs for super.setAttribute at dom_renderer.ts:734

Derived without a language server, by reading the class chain in
`packages/platform-browser/src/dom/dom_renderer.ts` at the pinned commit (found by a syntactic scan of `super.`
calls, then checked by hand):

- `EmulatedEncapsulationDomRenderer2 extends NoneEncapsulationDomRenderer` (line 696);
- `NoneEncapsulationDomRenderer extends DefaultDomRenderer2` (line 654) and declares no `setAttribute`
  (`grep -n 'setAttribute' dom_renderer.ts`: the only declaration in the file is on line 403);
- `DefaultDomRenderer2 implements Renderer2` (line 304) declares `setAttribute(el, name, value, namespace?)` on
  line 403. `Renderer2.setAttribute` (packages/core/src/render/api.ts:173) is abstract and is not what runs.

`super.` binds statically to the base class prototype, so subclass overrides cannot intervene.
Judgement calls: none.
