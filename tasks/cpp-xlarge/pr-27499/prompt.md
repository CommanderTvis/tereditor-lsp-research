# `EXPORT DATABASE … (FORMAT CSV)` in upper case still loses empty strings on `IMPORT DATABASE` (follow-up to #25501 / #26582)

### What happens?


#26582 fixed #25501: `EXPORT DATABASE 'exp' (FORMAT csv)` now writes `allow_quoted_nulls false` (plus
`quote`/`delimiter`/`header`) into `load.sql`, so empty strings come back as empty strings. The fix only works for
the **lower-case** spelling. With `(FORMAT CSV)`, the spelling used in most examples, `load.sql` contains just
`(FORMAT 'CSV')`. `IMPORT DATABASE` then turns every `''` of `VARCHAR`, `BLOB` and `ENUM` columns into NULL. A
`NOT NULL` column holding `''` makes the import fail.

The CSV data files are the same for both spellings. Only the generated `load.sql` differs.

Cause: the export keeps the format name as typed, and two places compare it case-sensitively:
- `src/execution/operator/persistent/physical_export.cpp:69`, `if (info.format == "csv")`. This guards the
  `force_not_null` list and the `allow_quoted_nulls false` option from #26582.
- `src/planner/binder/statement/bind_export.cpp:288`, `if (format == "csv")`. This adds the default `header`,
  `delimiter` and `quote` options.

The `COPY` binder lower-cases its own copy of the format, but the export's `CopyInfo` is not lower-cased.
Lower-casing the format once in the export binder (or comparing case-insensitively) fixes both.


### To Reproduce


```bash
duckdb src.db "CREATE TYPE mood AS ENUM ('', 'ok');
               CREATE TABLE t(id INT, v VARCHAR, b BLOB, e mood);
               INSERT INTO t VALUES (1, '', ''::BLOB, ''), (2, NULL, NULL, NULL), (3, 'x', 'x'::BLOB, 'ok');
               EXPORT DATABASE 'exp' (FORMAT CSV);"
grep COPY exp/load.sql
duckdb dst.db -csv "IMPORT DATABASE 'exp';
                    SELECT id, v IS NULL AS v_null, b IS NULL AS b_null, e IS NULL AS e_null FROM t ORDER BY id;"
```

Actual with `(FORMAT CSV)`:

```
COPY t FROM 'exp/t.csv' (FORMAT 'CSV');
id,v_null,b_null,e_null
1,true,true,true         <-- were '', ''::BLOB, ''
2,true,true,true
3,false,false,false
```

With `(FORMAT csv)` (correct):

```
COPY t FROM 'exp/t.csv' (FORMAT 'csv', allow_quoted_nulls false, quote '"', delimiter ',', header 1);
id,v_null,b_null,e_null
1,false,false,false
2,true,true,true
3,false,false,false
```

With a `NOT NULL` column that holds `''`, `(FORMAT CSV)` gives:

```
IMPORT DATABASE 'exp';
Constraint Error: NOT NULL constraint failed: t.v
```

Expected: `(FORMAT CSV)` behaves exactly like `(FORMAT csv)`.

### OS:

Ubuntu 22.04.2 LTS, x86_64

### DuckDB Version:

v2.1.0-dev89158 (main, 1b4c3e54ba, built from source)

### DuckDB Client:

CLI

### Hardware:

_No response_

### Full Name:

Ke Han

### Affiliation:

Purdue University

### Did you include all relevant configuration (e.g., CPU architecture, Linux distribution) to reproduce the issue?

- [x] Yes, I have

### Did you include all code required to reproduce the issue?

- [x] Yes, I have

### Did you include all relevant data sets for reproducing the issue?

Yes
