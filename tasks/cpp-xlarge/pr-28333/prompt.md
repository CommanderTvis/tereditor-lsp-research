# max_temp_directory_size is not enforced for ORDER BY, DISTINCT or GROUP BY spill: the temp directory grows 10-30x past it and the query completes

### What happens?

With `max_temp_directory_size` set, a sort, a DISTINCT or a hash aggregate that spills writes far more than the limit to `temp_directory` and completes normally. I expected the query to fail with an out-of-memory / temp-directory-full error once the limit is reached, as the setting's description says ("The maximum amount of data stored inside the 'temp_directory' (when set)").

DuckDB's own accounting shows it: `duckdb_temporary_files()`, read from a second cursor while the sort runs, peaks at about 1,060 MB against `max_temp_directory_size = 95.3 MiB`.

Measured on macOS (arm64), Python, `memory_limit = 256MB`, `threads = 2`, `max_temp_directory_size = 100MB`. "Peak temp" is the allocated size of the temp directory, sampled every 50 ms:

| query | 1.2.2 | 1.5.6 | 2.0.0 |
|---|---|---|---|
| `ORDER BY` | 2,904 MB | 1,090 MB | 1,071 MB |
| `DISTINCT` | 1,950 MB | 1,256 MB | 1,770 MB |
| `GROUP BY` | 1,885 MB | 1,278 MB | 1,522 MB |

Every query completed. `duckdb_temporary_files()` peak during the ORDER BY: 1,061 MB on 1.5.6 and 1,055 MB on 2.0.0 (it reported 0 on 1.2.2).

We use `memory_limit` and `max_temp_directory_size` as the bound on what one query may take, so for now we enforce the disk bound ourselves (a thread sums the temp directory and calls `interrupt()` past the limit).

### To Reproduce

```python
import os, shutil, tempfile, threading, time
import duckdb

QUERIES = {
    "ORDER BY": "SELECT i, md5(i::VARCHAR) AS h FROM range(20000000) r(i) ORDER BY h DESC",
    "DISTINCT": "SELECT DISTINCT md5(i::VARCHAR) AS h, i FROM range(20000000) r(i)",
    "GROUP BY": "SELECT md5(i::VARCHAR) AS h, count(*) FROM range(20000000) r(i) GROUP BY h",
}

def allocated(folder):
    n = 0
    for root, _, names in os.walk(folder):
        for name in names:
            try:
                n += os.stat(os.path.join(root, name)).st_blocks * 512
            except FileNotFoundError:
                pass
    return n

for label, sql in QUERIES.items():
    tmp = tempfile.mkdtemp(prefix="dd-spill-")
    con = duckdb.connect(config={"memory_limit": "256MB", "threads": "2",
                                 "max_temp_directory_size": "100MB", "temp_directory": tmp})
    probe = con.cursor()
    peak_disk, peak_reported, stop = [0], [0], threading.Event()

    def watch():
        while not stop.is_set():
            peak_disk[0] = max(peak_disk[0], allocated(tmp))
            try:
                n = probe.execute("SELECT coalesce(sum(size), 0) FROM duckdb_temporary_files()").fetchone()[0]
                peak_reported[0] = max(peak_reported[0], n)
            except Exception:
                pass
            time.sleep(0.05)

    th = threading.Thread(target=watch)
    th.start()
    con.execute(sql).fetchmany(1)
    stop.set(); th.join(); con.close(); shutil.rmtree(tmp, ignore_errors=True)
    print(f"{duckdb.__version__} {label}: peak temp dir {peak_disk[0] / 2**20:.0f} MB, "
          f"duckdb_temporary_files() peak {peak_reported[0] / 2**20:.0f} MB, limit 100MB")
```

### OS:

macOS 26 (arm64)

### DuckDB Version:

1.2.2, 1.5.6, 2.0.0

### DuckDB Client:

Python 3.11

### Hardware:

Apple silicon, 14 cores, 36 GB

### Full Name:

Mustafa Kabul

### Affiliation:

Not stated

### Did you include all relevant configuration (e.g., CPU architecture, Linux distribution) to reproduce the issue?

Yes

### Did you include all code required to reproduce the issue?

Yes

### Did you include all relevant data sets for reproducing the issue?

Not applicable: the repro generates its data with `range()`.
