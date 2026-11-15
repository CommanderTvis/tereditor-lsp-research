# Declaration inside element is not proper rejected

This xml:

```
<first>
     <?xml version=\"1.0\" ?>
</first>"
```

is not rejected although it contains a declaration inside an element

