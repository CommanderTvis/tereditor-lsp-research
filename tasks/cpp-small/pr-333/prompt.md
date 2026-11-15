# XML Declarations should only occur at the beginning of an XML Document.

We know that XML Declarations should only occur at the beginning of an XML Document.

For example, the XML Strings given below in the test cases should give parsing errors.

``` C
 {
    // Check that declarations are parsed only as the FirstChild
    const char* xml1 =  "<?xml version=\"1.0\" ?>"
            "   <?xml version=\"1.1\" ?>"
            "<first />";
    const char* xml2 =  "<first />"
            "<?xml version=\"1.0\" ?>";
    XMLDocument doc;
    doc.Parse(xml1);^M
    XMLTest("Test that the second declaration throws an error", doc.Error(), true);
    doc.Parse(xml2);
    XMLTest("Test that declaration after a child throws an error", doc.Error(), true);
 }
```

