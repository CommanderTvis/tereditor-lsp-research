# HTTP PUT requests retain a reference to the caller’s content-type string

### What happens?

`PutRequestInfo` stores `content_type` as `const string &`. Modifying the caller's string after constructing a request changes the request's content type. If that string is destroyed, the request retains a dangling reference. The request should own its content type, as it already owns its URL.

### To Reproduce

Add this regression to `test/common/test_http_transport_manager.cpp`:

```cpp
TEST_CASE("PUT requests retain their content type", "[http_transport_manager]") {
    HTTPUtil http;
    HTTPParams params(http);
    string content_type = "application/json";
    PutRequestInfo request("http://localhost/upload", HTTPHeaders(), params, nullptr, 0, content_type);
    content_type = "text/plain";
    CHECK(request.content_type == "application/json");
}
```

Run the test using the built C++ test executable:

```sh
build/release/test/unittest "PUT requests retain their content type"
```

The old implementation reads `"text/plain"`; the expected value is `"application/json"`. This checks a live string, so no undefined behavior or external HTTP service is needed. SQL does not expose this request object.

### OS:

Amazon Linux 2023.12.20260817, Linux 6.18.41, aarch64. Built with Clang 15.0.7.

### DuckDB Version:

Reproduced with v2.1.0-dev90066 (`1641475ef1`), using the unmodified HTTP request definition. The same definition is present on current `main` (`0ccee9a0870a795232b84d90ebf3de3f3c221419`).

### DuckDB Client:

C++ HTTP request API / native test runner.

### Hardware:

Not performance-related.

### Full Name:

Rusty Conover

### Affiliation:

[Query.Farm](https://query.farm)

### Did you include all relevant configuration (e.g., CPU architecture, Linux distribution) to reproduce the issue?

- [x] Yes, I have

### Did you include all code required to reproduce the issue?

- [x] Yes, I have

### Did you include all relevant data sets for reproducing the issue?

Not applicable - the reproduction does not require a data set
