/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */package org.apache.lucene.codecs.lucene90;

import org.apache.lucene.search.DocIdSetIterator;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.IOContext;
import org.apache.lucene.store.IndexInput;
import org.apache.lucene.store.IndexOutput;
import org.apache.lucene.tests.util.LuceneTestCase;
import org.apache.lucene.util.BitSetIterator;
import org.apache.lucene.util.FixedBitSet;

/** Held-out check of the rename task: the class has its new name and still round-trips a bit set. */
public class StudyHiddenRenameDisiTest extends LuceneTestCase {
  public void testRenamedClassRoundTrips() throws Exception {
    FixedBitSet set = new FixedBitSet(1000);
    set.set(3);
    set.set(500);
    int cardinality = set.cardinality();
    byte denseRankPower = JumpTableDISI.DEFAULT_DENSE_RANK_POWER;
    try (Directory dir = newDirectory()) {
      int jumpTableEntryCount;
      long length;
      try (IndexOutput out = dir.createOutput("foo", IOContext.DEFAULT)) {
        jumpTableEntryCount =
            JumpTableDISI.writeBitSet(new BitSetIterator(set, cardinality), out, denseRankPower);
        length = out.getFilePointer();
      }
      try (IndexInput in = dir.openInput("foo", IOContext.DEFAULT)) {
        JumpTableDISI disi =
            new JumpTableDISI(in, 0L, length, jumpTableEntryCount, denseRankPower, cardinality);
        assertEquals(3, disi.nextDoc());
        assertEquals(500, disi.nextDoc());
        assertEquals(DocIdSetIterator.NO_MORE_DOCS, disi.nextDoc());
      }
    }
  }
}
