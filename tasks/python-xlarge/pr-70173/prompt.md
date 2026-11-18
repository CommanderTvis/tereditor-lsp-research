[BUG] mounts.fstab output uses different name for same setting than mounts.mount

we started integrating tracking our fstab/mount entries in salt. for importing we just wanted to run `salt \* mount.fstab` 

the state function expects `pass_num` as parameter but the `mount.fstab` function just gives `pass:` in the output.

it would be nice if the stack is more consistent.
