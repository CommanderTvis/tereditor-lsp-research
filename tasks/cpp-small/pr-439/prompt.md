# Difference between MD4C and cmark output for CDATA tags

Input:
```
<![CDATA[ text ]]>
<![cdata[ text ]]>
<PrE>text</pRe>
<foo>text</foo>
```

cmark output:
```
<![CDATA[ text ]]>
<p>&lt;![cdata[ text ]]&gt;</p>
<pre>text</pre>
<p><foo>text</foo></p>
```

md4c output:
```
<![CDATA[ text ]]>
<!cdata[ text ]>
<pre>text</pre>
<p><foo>text</foo></p>
```
