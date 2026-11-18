Significant increase in IOPS during segment merge in Lucene 10

### Description

### Summary

We are seeing a significant increase in read-side block I/O during merge-related stored-fields reads after moving from Lucene `9.4.0` (OpenSearch 2.19) to Lucene `10.4.0`(OpenSearch 3.6). Although, the issue was seen in OpenSearch, I am posting it here as I believe the regression may originate from Lucene.

## Benchmark Test

We are running single-node instance of OpenSearch 2.19 vs OpenSearch 3.6 and [OpenSearch Benchmark](https://docs.opensearch.org/latest/benchmark/user-guide/install-and-configure/installing-benchmark/) `geonames` (indexing only) against those. We captured a `perf` trace to identify the source of `block_rq_issue` kernel events which gives us an indication of what causes the high read IOPS.

## Results & Observations

Results show OpenSearch 3.6 (Lucene 10) results in signifcantly higher number of `block_rq_issue` events.

| Metric                       | `2.19` (Lucene 9) | `3.6` (Lucene 10) |
| ---------------------------- | ----------------: | ----------------: |
| `block:block_rq_issue` count |          `42,768` |         `186,344` |

Also, the `block_rq_issue` events originating from `Lucene90CompressingStoredFieldsWriter.merge` has significantly increased.

| Metric                       | `2.19` (Lucene 9) | `3.6` (Lucene 10) |
| ---------------------------- | ----------------: | ----------------: |
| `block:block_rq_issue` count |           `5,076` |         `173,757` |

You can see the flame graphs for results for 2.19 (block-rq-issue-opensearch-2.19-lucene-9.svg) and 3.6 (block-rq-issue-opensearch-3.6-lucene-10.svg) attached.

### Why this looks like a Lucene regression?

The behavior aligns with how the stored-fields reader changed between Lucene `9.4.0` and `10.4.0`.

#### Suspected root cause

Our analysis show that `.fdt` file is opened with `RANDOM` read advise, which prevents the kernel from doing read-aheads, that leads to additional IOPS during a merge operation.

```java
fieldsStream = d.openInput(fieldsStreamFN, context);
```

In `10.4.0`, the `.fdt` stream is opened with a forced `RANDOM` hint:

```java
fieldsStream =
    d.openInput(fieldsStreamFN, context.withHints(FileTypeHint.DATA, DataAccessHint.RANDOM));
```

Based on the current Lucene code:

- merge calls `Lucene90CompressingStoredFieldsWriter.merge`,
- that calls `checkIntegrity()` on source readers,
- `checkIntegrity()` calls `CodecUtil.checksumEntireFile()`,
- `checksumEntireFile()` scans the entire file through `ChecksumIndexInput.seek()` / `skipByReading()`,
- and with `MemorySegmentIndexInput` plus `RANDOM` advice, the scan appears to fault pages in a way that results in many more block I/Os.

The regression appears to be the combination of:

1. `MemorySegmentIndexInput` making read advice effective at the kernel level, and
2. `Lucene90CompressingStoredFieldsReader` forcing `DataAccessHint.RANDOM` even when the caller is merge code that would otherwise use sequential access.

**Note:** Above, was based on my scanning of the codebase and I am not familiar with the Lucene codebase. Hence, above may not be accurate and I would like confirmation someone familiar with the code to confirm above implementation.

## Expected behavior

Lucene 10 should not cause higher IOPS during segment merge operations, when compared to Lucene 9, unless if that's a trade off for certain gain elsewhere. During merge-time integrity scans and stored-fields copying, stored-fields data reads should preserve sequential read behavior so the kernel can use read-ahead effectively.

### Version and environment details

## Test Setup Details

Below are the details of the benchmarking and profiling setup.

### OpenSearch setup

Docker images were built from below versions locally by checking out 2.19 and 3.6 branches in OpenSearch repo.

- OpenSearch `2.19` / Lucene `9.4.0`
- OpenSearch `3.6` / Lucene `10.4.0`

```
docker run --name opensearch \
	--rm \
	-p 9200:9200 \
	-p 9600:9600 \
    --ulimit memlock=-1:-1 \
    --ulimit nofile=65536:65536 \
	--cap-add IPC_LOCK \
	-e "discovery.type=single-node" \
	-e "bootstrap.memory_lock=true" \
	-e "OPENSEARCH_JAVA_OPTS=-Xms3g -Xmx3g -XX:+PreserveFramePointer -XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints" \
	-e "DISABLE_INSTALL_DEMO_CONFIG=true" \
	-e "DISABLE_SECURITY_PLUGIN=true" \
	-v /var/lib/opensearch/data-$VERSION:/usr/share/opensearch/data \
	docker.opensearch.org/opensearch:$VERSION-SNAPSHOT
```

### Benchmark setup

```
docker run --rm --network host \
    -e HOME=/work \
    -v "$OSB_HOME:/work" \
    -v "$RESULTS_DIR:/results" \
    opensearchproject/opensearch-benchmark:latest \
    run \
      --workload=geonames \
      --target-hosts=127.0.0.1:9200 \
      --pipeline=benchmark-only \
      --include-tasks="index-append" \
      --workload-params='{"number_of_shards":3,"number_of_replicas":0,"bulk_size":5000}' \
      --client-options="use_ssl:false,verify_certs:false,basic_auth_user:'xxxx',basic_auth_password:'xxxx'" \
      --results-format=markdown \
      --results-file="/results/geonames-${TASKS}-$(date +%Y%m%d-%H%M%S).md" \
      --show-in-results=all || true

```

### Tracing setup

```
...
perf record \
    -o "/tmp/block-rq-issue.data" \
    -p "$PID" \
    -e "block:block_rq_issue" \
    --call-graph fp
...
```

OpenSearch 2.19 (Lucene 9) Trace flamegraph:
<img width="1200" height="1318" alt="Image" src="https://github.com/user-attachments/assets/a45efe20-6d88-4182-a737-808d8daf56ba" />

OpenSearch 3.6 (Lucene 10) Trace flamegraph:
<img width="1200" height="1142" alt="Image" src="https://github.com/user-attachments/assets/699d22c2-c88e-4ede-945d-f68f1718e652" />
