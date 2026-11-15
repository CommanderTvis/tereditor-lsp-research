# Hardcoded line separator bug

The bug occurs when the Javadoc text formed with Windows `\r\n` line separator.

For example, we have the comment `A\r\n\r\nB\r\n`. Because `JavaPoet` uses hardcoded line separator, `CodeWriter#emitAndIndent(String)` splits the comment on the next lines: `A\r`, `\r`, `B\r`. As the second line is not empty, indentation emitted.

It's a problem, if someone wants to test generation of Javadoc, that uses `JavaPoet`. Generated Javadoc depends on a platform (Windows or Unix). On Unix the Javadoc empty lines are really empty, but on Windows they are indented. In reason of this unreal to test generation of a Javadoc on different platforms.

Hardcoded line separator may cause and others bugs also.
