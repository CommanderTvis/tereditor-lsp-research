# LMOVEM emits reversed keyspace notification order when source and destination are the same key

### Reproduction

With `notify-keyspace-events` set to `El`, the current event order is:

```
LMOVE k k LEFT RIGHT
rpush, lpop

LMOVEM src dst LEFT RIGHT
rpush (dst), lpop (src)

LMOVEM k k LEFT RIGHT
lpop, rpush
```

The same-key branch in `lmovemMoveAndReply()` explicitly emits the pop event first, while `LMOVE` and the distinct-key `LMOVEM` path emit the destination push event first.

Relevant code:
- LMOVE: https://github.com/redis/redis/blob/unstable/src/t_list.c#L1173-L1254
- same-key LMOVEM: https://github.com/redis/redis/blob/unstable/src/t_list.c#L1614-L1621
- distinct-key LMOVEM: https://github.com/redis/redis/blob/unstable/src/t_list.c#L1630-L1645

The existing same-key test only checks the final list:
https://github.com/redis/redis/blob/unstable/tests/unit/type/list-4.tcl#L93-L98

PR #15405 and the LMOVEM docs say that optionless `LMOVEM` behaves like `LMOVE` except for returning a one-element array:
- https://github.com/redis/redis/pull/15405
- https://redis.io/docs/latest/commands/lmovem/

There is also a documentation conflict: the keyspace notification docs guarantee pop-before-push for `LMOVE`, but the current implementation emits push-before-pop:
https://redis.io/docs/latest/develop/pubsub/keyspace-notifications/

Should the same-key `LMOVEM` branch be changed to match the existing runtime behavior, or should all move paths be changed to follow the documented order?
