# Null pointer dereference when fuzzed

Originally filed at https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=780153:

TinyXML-2 crashes when parsing the attached file:

```
$ make prettyprintxml CXXFLAGS="-g -O2 -Wall" LDFLAGS=-ltinyxml2
g++ -g -O2 -Wall  -ltinyxml2  prettyprintxml.cc   -o prettyprintxml
$ ./prettyprintxml crash.xml
Segmentation fault
```

Valgrind output:

```
Valgrind says it's a null pointer dereference:

==2570== Invalid read of size 1
==2570==    at 0x4056C53: tinyxml2::StrPair::GetStr() (tinyxml2.cpp:175)
==2570==    by 0x405C5AD: tinyxml2::XMLPrinter::Visit(tinyxml2::XMLText const&) (tinyxml2.cpp:2219)
==2570==    by 0x4056450: tinyxml2::XMLText::Accept(tinyxml2::XMLVisitor*) const (tinyxml2.cpp:920)
==2570==    by 0x4056418: tinyxml2::XMLDocument::Accept(tinyxml2::XMLVisitor*) const (tinyxml2.cpp:554)
==2570==    by 0x405BAB6: tinyxml2::XMLDocument::Print(tinyxml2::XMLPrinter*) const (tinyxml2.cpp:1830)
==2570==    by 0x8048C6C: main (prettyprintxml.cc:19)
==2570==  Address 0x0 is not stack'd, malloc'd or (recently) free'd
```

gdb backtrace:

```
(gdb) bt full
#0  0x00007ffff7bce286 in tinyxml2::StrPair::GetStr (this=0x603518) at /build/tinyxml2-CUTmG6/tinyxml2-2.2.0/tinyxml2.cpp:175
        p = 0x0
        q = 0x6034e0 "&#0"
#1  0x00007ffff7bce7a9 in tinyxml2::XMLNode::Value (this=<optimised out>) at /build/tinyxml2-CUTmG6/tinyxml2-2.2.0/tinyxml2.cpp:585
No locals.
#2  0x00007ffff7bd38b5 in tinyxml2::XMLPrinter::Visit (this=0x7fffffffd570, text=...) at /build/tinyxml2-CUTmG6/tinyxml2-2.2.0/tinyxml2.cpp:2219
No locals.
#3  0x00007ffff7bcdae5 in tinyxml2::XMLDocument::Accept (this=0x603010, visitor=0x7fffffffd570) at /build/tinyxml2-CUTmG6/tinyxml2-2.2.0/tinyxml2.cpp:554
        node = 0x603500
#4  0x00007ffff7bd2da1 in tinyxml2::XMLDocument::Print (this=0x603010, streamer=0x7fffffffd570) at /build/tinyxml2-CUTmG6/tinyxml2-2.2.0/tinyxml2.cpp:1830
        stdStreamer = {
          <tinyxml2::XMLVisitor> = {
            _vptr.XMLVisitor = 0x6020d0 <vtable for tinyxml2::XMLPrinter+16>
          }, 
          members of tinyxml2::XMLPrinter: 
          _elementJustOpened = false, 
          _stack = {
            _mem = 0x7fffffffd408, 
            _pool = {0x400aa1 "_ZNK8tinyxml211XMLDocument5PrintEPNS_10XMLPrinterE", 0xffffffff <error: Cannot access memory at address 0xffffffff>, 
              0x7ffff7bd2794 <tinyxml2::XMLElement::ParseAttributes(char*)+68> "\205\300\017\205\204", 0x7ffff7bc8fe0 "\002\035", 0x7ffff7ff74d0 "", 
              0x11 <error: Cannot access memory at address 0x11>, 0x2f <error: Cannot access memory at address 0x2f>, 0x6034e5 "a>", 
              0x7ffff769a060 <free@got.plt> "\240\375\065\367\377\177", 0x0}, 
            _allocated = 10, 
            _size = 0
          }, 
          _firstElement = true, 
          _fp = 0x7ffff769b400 <_IO_2_1_stdout_>, 
          _depth = 0, 
          _textDepth = -1, 
          _processEntities = true, 
          _compactMode = false, 
          _entityFlag = {false <repeats 34 times>, true, false, false, false, true, true, false <repeats 20 times>, true, false, true, false}, 
          _restrictedEntityFlag = {false <repeats 38 times>, true, false <repeats 21 times>, true, false, true, false}, 
          _buffer = {
            _mem = 0x7fffffffd508 "", 
            _pool = "\000\204\335\367\377\177\000\000p\325\377\377\377\177\000\000p\325\377\377", 
            _allocated = 20, 
            _size = 1
          }
        }
#5  0x0000000000401282 in main ()
No symbol table info available.
```

