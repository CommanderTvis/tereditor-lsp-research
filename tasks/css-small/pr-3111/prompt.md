[BUG] Validation states in input-group-flat broken with input-group-text

**Describe the bug**

Looks broken with any `input-group-text` (gets worse when there is really text instead of an icon):
<img width="694" alt="Bildschirmfoto 2023-08-18 um 16 39 18" src="https://github.com/tabler/tabler/assets/533162/9197370e-0707-4cd0-a44d-3ea79be9282e">
<img width="583" alt="Bildschirmfoto 2023-08-18 um 16 40 40" src="https://github.com/tabler/tabler/assets/533162/1bc692c2-1085-4866-935d-23fe83c6c1a6">

Looks good when I remove the `input-group-text` node:
<img width="688" alt="Bildschirmfoto 2023-08-18 um 16 41 44" src="https://github.com/tabler/tabler/assets/533162/ecd0d654-2a5b-4b72-ad57-4b259c1d197e">

**Expected**

The `input-group-flat` rules should support `input-group-text` nodes in combination with validation states.

issue can be reproduced on the preview page by manipulating the HTML directly.


**Workaround**

Sharing a possible workaround for the next user with the problem:
<img width="687" alt="Bildschirmfoto 2023-08-18 um 16 43 40" src="https://github.com/tabler/tabler/assets/533162/60f4e90b-8077-4900-b464-86cb359d88aa">

Use `is-invalid is-invalid-lite` ... but whether this is possible highly depends on the used framework.
I don't think this is a 100% viable solution, because it is visually rather hidden. 

