# Problem with 302 redirect and Auth on initial (but not redirected) link

I am downloading a file with Guzzle 6.2.0. The original url, via https, requires Digest authorization, then returns a 302 redirect to another url on a different domain (http) that does NOT require authorization.

When I try to use Guzzle to download the file following redirects automatically, Guzzle makes the initial connection, gets back a 401, sends again with the correct authorization headers, gets back the 302 redirect--all good. 

Then it tries to send the same exact Authorization headers with the request to the new url, which gets back a 400 bad request, I assume because the redirected URL does not expect authorization.

I have gotten around this by capturing the redirect url via an `on_stats` function, setting `allow_redirects` to false, and creating a completely separate request for the redirected url. But it seems that there should be a better way to handle this.

This is not my area of expertise--does it EVER make sense to send the same auth headers for a 302 redirect to a separate domain?

