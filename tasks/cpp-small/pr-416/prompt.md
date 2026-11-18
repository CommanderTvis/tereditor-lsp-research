# List rendered tight when item directly contains a thematic break and a paragraph separated by a blank line

Difference in output between md4c and cmark involving tight vs loose lists

input:
``` markdown
-
  ---

  b
```

cmark output:
``` html
<ul>
<li>
<hr>
<p>b</p>
</li>
</ul>
```

md4c output:
``` html
<ul>
<li>
<hr>
</li>
</ul>
<p>b</p>
```
