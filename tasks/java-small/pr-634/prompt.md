# Improve Error Handling with malformed json

Currently Jackson and Jsonb Exception Mappers return responses, which contain detailed information about the malformed request object. From a consumer point of view this makes sense and improves developer expierence.

Example:
`{
  "status": 400,
  "title": "Bad Request",
  "detail": "Internal error: Invalid token=STRING at (line no=3, column no=11, offset=52). Expected tokens are: [COMMA]",
  "instance": "/token"
}`

But the responses also contain implementation details, which from a security point of view is not so good. Especially if your service is a an external public API.
https://owasp.org/www-community/Improper_Error_Handling
Example:
`{
  "status": 400,
  "title": "Bad Request",
  "detail": "Unable to deserialize property 'token' because of: Problem adapting object of type interface org.example.entity.Token to class java.lang.String in class class org.example.enity.TokenTypeAdapter",
  "instance": "/token"
}`

**Solution**

What could help is an option to control the output to return a more generic response and log the detailed error message in the backend.
Example:
`{
  "status": 400,
  "title": "Bad Request",
  "detail": "Syntax Error: malformed json",
  "instance": "/token"
}`
