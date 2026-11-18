RangeBulkScorer calls collectRange with an empty range

## Description

`RangeBulkScorer` can call `LeafCollector.collectRange(min, max)` with `min == max` when it is wrapped by `ReqExclBulkScorer`. The default `LeafCollector.collectRange` implementation constructs a `RangeDocIdStream`, which rejects an empty range with `IllegalArgumentException`.

This is reproducible with the official Lucene 10.5.1 artifacts from Maven Central. It does not depend on a downstream fork.

The call sequence is:

1. `ReqExclBulkScorer` reaches the end of a scoring window and calls `req.score(collector, acceptDocs, upTo, upTo)` to obtain the next-match estimate.
2. When `req` is a `RangeBulkScorer` and `upTo` is within its doc-ID interval, `filteredMin` and `filteredMax` are equal.
3. `RangeBulkScorer` unconditionally calls `collector.collectRange(filteredMin, filteredMax)`.
4. This violates the `LeafCollector.collectRange` contract that `max` is greater than `min` and causes `RangeDocIdStream` to throw.

`RangeBulkScorer` was introduced by https://github.com/apache/lucene/pull/16080, and the same code path is still present on `main`.

This also affects Elasticsearch downstream. Elasticsearch 9.5 currently uses Lucene 10.5.1, and its aggregation `LeafBucketCollector` inherits the default `collectRange` implementation. In Elasticsearch, the exception surfaces as an HTTP 400 for a Boolean query with a dense required range, a high-exclusion `MUST_NOT` clause, and an aggregation.

## Reproducer

Dependencies:

- `org.apache.lucene:lucene-core:10.5.1`
- `org.apache.lucene:lucene-analysis-common:10.5.1`
- Java 21

```java
import java.util.ArrayList;
import java.util.List;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.SortedDocValuesField;
import org.apache.lucene.document.StringField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.BulkScorer;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.LeafCollector;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Scorable;
import org.apache.lucene.search.ScoreMode;
import org.apache.lucene.search.Sort;
import org.apache.lucene.search.SortField;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.store.ByteBuffersDirectory;
import org.apache.lucene.store.Directory;
import org.apache.lucene.util.BytesRef;

public class EmptyRangeRepro {
  public static void main(String[] args) throws Exception {
    String sliceField = "slice";
    Query query =
        new BooleanQuery.Builder()
            .add(
                SortedDocValuesField.newSlowExactQuery(sliceField, new BytesRef("src")),
                BooleanClause.Occur.FILTER)
            .add(
                new TermQuery(new Term("excluded", "yes")), BooleanClause.Occur.MUST_NOT)
            .build();

    try (Directory directory = new ByteBuffersDirectory()) {
      IndexWriterConfig config = new IndexWriterConfig(new StandardAnalyzer());
      config.setIndexSort(new Sort(new SortField(sliceField, SortField.Type.STRING)));
      try (IndexWriter writer = new IndexWriter(directory, config)) {
        for (int i = 0; i < 128; i++) {
          addDocument(writer, "aaa", "no");
        }
        for (int i = 0; i < 8192; i++) {
          addDocument(writer, "src", i % 819 == 818 ? "no" : "yes");
        }
        for (int i = 0; i < 128; i++) {
          addDocument(writer, "zzz", "no");
        }
        writer.forceMerge(1);
      }

      try (DirectoryReader reader = DirectoryReader.open(directory)) {
        IndexSearcher searcher = new IndexSearcher(reader);
        Query rewritten = searcher.rewrite(query);
        BulkScorer scorer =
            searcher
                .createWeight(rewritten, ScoreMode.COMPLETE_NO_SCORES, 1f)
                .bulkScorer(reader.leaves().get(0));

        List<Integer> collected = new ArrayList<>();
        LeafCollector collector =
            new LeafCollector() {
              @Override
              public void setScorer(Scorable scorer) {}

              @Override
              public void collect(int doc) {
                collected.add(doc);
              }
            };

        scorer.score(collector, null, 0, 4096);
        scorer.score(collector, null, 4096, 8192);
        scorer.score(collector, null, 8192, reader.maxDoc());
        if (collected.size() != 10) {
          throw new AssertionError("expected 10 but got " + collected.size());
        }
      }
    }
  }

  private static void addDocument(IndexWriter writer, String slice, String excluded)
      throws Exception {
    Document document = new Document();
    document.add(SortedDocValuesField.indexedField("slice", new BytesRef(slice)));
    document.add(new StringField("excluded", excluded, Field.Store.NO));
    writer.addDocument(document);
  }
}
```

Actual result:

```text
java.lang.IllegalArgumentException: min = 4096 >= max = 4096
    at org.apache.lucene.search.RangeDocIdStream.<init>(RangeDocIdStream.java:29)
    at org.apache.lucene.search.LeafCollector.collectRange(LeafCollector.java:105)
    at org.apache.lucene.document.RangeBulkScorer.score(RangeBulkScorer.java:78)
    at org.apache.lucene.search.ReqExclBulkScorer.score(ReqExclBulkScorer.java:74)
```

Expected result: empty scoring windows do not collect anything, and the query completes with 10 collected documents.

A possible fix is to avoid calling `collectRange` unless `filteredMin < filteredMax`, while preserving the iterator advancement and return-value semantics. A regression test combining `RangeBulkScorer` with `ReqExclBulkScorer` would cover this case.

## Version and environment details

- Lucene 10.5.1 official Maven Central artifacts
- OpenJDK 21.0.2
- macOS

