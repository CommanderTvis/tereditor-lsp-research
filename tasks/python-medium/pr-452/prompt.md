[REQUEST] Add max_length to RichHandler

Have you checked the issues for a similar suggestions?

Yes

**How would you improve Rich?**

Pretty recently got the `max_length` keyword to abbreviate printing of long lists. The same issue occurs in tracebacks, but there the `max_length` keyword is not available when printing locals. Tracing the issue, the `render_scope` function uses `Pretty` but does not take or pass the `max_length` option. 

I wonder if making a global option or a console option (similar to a theme) would be a possibility without having to introduce yet another parameter to the logging handler (and in the code pass it down lots of levels).

**What problem does it solved for you?**

The problem it solves is very long tracebacks in certain contexts where errors are thrown with local variables consisting of long lists or dictionaries.

And thank you - rich is awesome!
