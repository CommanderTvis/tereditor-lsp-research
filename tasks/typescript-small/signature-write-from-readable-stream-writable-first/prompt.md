We want `writeFromReadableStream` (in `src/utils.ts`) to take the destination first and the stream second, so that it
reads `writeFromReadableStream(outgoing, body)`. Change its signature from `writeFromReadableStream(stream, writable)`
to `writeFromReadableStream(writable, stream)` and update every call of it in the code base, including the tests, so
that the type checks and tests pass. Do not keep an overload or fallback for the old argument order.
