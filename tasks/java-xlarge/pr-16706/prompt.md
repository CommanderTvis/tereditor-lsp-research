Improvements to the sandboxed de-duplicating vector format

### Description

With a goal of supporting multiple HNSW graphs backed by the same vectors (#14758), we added sandboxed vector formats (`DedupHnswVectorsFormat`, `DedupHnswScalarQuantizedVectorsFormat`) that internally de-duplicate vectors _across_ fields and documents.

If the user wants an HNSW graph on a subset of vectors, they can create a new vector field with the same vectors as the "main" field, for the smaller set of documents -- and Lucene only stores one unique copy per vector!

I like to think of this scheme as "index-time filtering" of vector fields, trading off indexing time and size for [better search performance](https://github.com/mikemccand/luceneutil/pull/468#issuecomment-3313919339) than query-time filtering.

Opening this issue for improvements to this vector format (identified from #15979 and #16506):

- [x] Use fewer bits to write off-heap field ord -> group ord mapping (from https://github.com/apache/lucene/pull/15979#discussion_r3665648034)
	- The per-field mapping of field ord -> group ord is maintained off-heap, [using a `DirectWriter`](https://github.com/apache/lucene/blob/fb0ca7cd29d68af00a39fda410852d4eccd066ad/lucene/sandbox/src/java/org/apache/lucene/sandbox/codecs/dedup/DedupUtil.java#L124-L125).
	- Each value in the mapping uses [32 bits](https://github.com/apache/lucene/blob/fb0ca7cd29d68af00a39fda410852d4eccd066ad/lucene/sandbox/src/java/org/apache/lucene/sandbox/codecs/dedup/DedupUtil.java#L51) today, evaluate using fewer bits for smaller index size (possibly at the tradeoff of additional work during search).
- [x] Implement scalar quantization support for `FP16` vectors (recently added in https://github.com/apache/lucene/pull/16473)
- [ ] Evaluate de-duplicating _only_ within a document (see https://github.com/apache/lucene/pull/15979#discussion_r3691313762)
	- This makes each stored vector attributable to a single document, making it easier to sort vectors inside a group. If we use the index sort order, we can speed up merges by advising a sequential access pattern.
	- Merges are also faster because there are no repeat reads from the index on hash collisions.
- [ ] Allow dropping full-precision raw vectors from the index? (the format has a data-blind assumption)
- [ ] Expose useful de-duplication metrics (see https://github.com/apache/lucene/pull/15979#discussion_r3691217160)
	- One interesting metric is the number of unique vectors per-field. This can be found today by counting the unique group ords present across all field ords (from the underlying [vector values](https://github.com/apache/lucene/blob/fb0ca7cd29d68af00a39fda410852d4eccd066ad/lucene/sandbox/src/java/org/apache/lucene/sandbox/codecs/dedup/DedupVectorValues.java#L67-L68)).
	- Can we add a static utility method to expose this count? Long-term, could / should it be added to something like `CheckIndex`?
- [ ] Implement an HNSW format to make use of de-dup information (some suggestions in https://github.com/apache/lucene/pull/15979#discussion_r3665528522)
- [ ] Long-term model for off-heap accounting? (see https://github.com/apache/lucene/pull/15979#discussion_r3648030933)
	- [`KnnVectorsReader#getOffHeapByteSize`](https://github.com/apache/lucene/blob/fb0ca7cd29d68af00a39fda410852d4eccd066ad/lucene/core/src/java/org/apache/lucene/codecs/KnnVectorsReader.java#L188-L218) assumes that each byte can be attributed to a single field. This assumption breaks for the de-duplicating vector format, which shares vectors across compatible fields. Today it [returns an over-estimate](https://github.com/apache/lucene/blob/fb0ca7cd29d68af00a39fda410852d4eccd066ad/lucene/sandbox/src/java/org/apache/lucene/sandbox/codecs/dedup/DedupFlatVectorsReader.java#L366-L370) for each field.
	- As far as I can tell, this function is only provided as a helper for the user, and not used by Lucene internally.
	- How can we better model a scenario where field-level attribution is not possible?

Please feel free to add more!
