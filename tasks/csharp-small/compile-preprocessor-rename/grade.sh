#!/bin/sh
# The interface keeps the new name only, the post-processor interface is unchanged, then build + tests.
set -e
grep -q 'Task PreProcess(TRequest request, CancellationToken cancellationToken);' src/MediatR/Pipeline/IRequestPreProcessor.cs
! grep -qE '\bProcess\(' src/MediatR/Pipeline/IRequestPreProcessor.cs
grep -q 'Task Process(TRequest request, TResponse response, CancellationToken cancellationToken);' src/MediatR/Pipeline/IRequestPostProcessor.cs
sh /project/check.sh
