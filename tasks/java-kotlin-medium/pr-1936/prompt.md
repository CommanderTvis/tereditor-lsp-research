# Custom HTTP headers not passed in all Provider calls

# Environment tested against
- Pact JVM version: `au.com.dius.pact.provider:spring7:4.7.5`
- Pact Broker: `3.0.0-pactbroker2.121.2`

# Description
- The Pact JVM library provides the ability to add custom HTTP headers to all requests to the Pact Broker via the attribute `customHeaders` like so:
  ```java
  @PactBroker(
      url = "http://localhost:9292",
      authentication = @PactBrokerAuth(
          username = "pact",
          password = "pact"
      ),
      customHeaders = {
          @PactBrokerHttpHeader(name = "X-Pact-Broker-Client-Id", value = "local-id"),
          @PactBrokerHttpHeader(name = "X-Pact-Broker-Client-Secret", value = "local-secret")
      }
  )
  ```  
- These headers are not passed on all calls to the broker
- [this appears partially related to this issue](https://github.com/pact-foundation/pact-jvm/issues/1917)

# Steps to reproduce
- I have created a project using Docker Compose, nginx, Pact JVM provider lib with Spring Boot test. This project runs the entire stack locally and shows the issue when the pact provider test is run. https://github.com/nick-m-b/pact-jvm-custom-header-issue

1. Configure a Provider test with `@PactBroker` including `customHeaders`, as shown above
2. Run the provider verification against a broker with at least one published pact
3. Inspect the HTTP requests received by the Pact Broker (e.g. broker access logs, or a proxy in front of it)

# Observed behaviour
- The initial call(s) used to discover/navigate to the pact(s) (e.g. fetching consumers, following HAL links) include the configured custom headers
- The follow-up call that fetches the actual pact JSON content from its source URL does **not** include the custom headers

# Expected behaviour
- Custom headers configured via `customHeaders` should be sent on every request made to the Pact Broker during a verification run, including the request that retrieves the pact content itself

# Real-world impact
- Any Pact Broker deployment/gateway that requires these headers on all endpoints (e.g. a proxy enforcing a client id/secret, or a WAF rule) will reject the pact-content request, causing provider verification to fail even though broker discovery succeeds
