/*
 * MIT License
 *
 * Copyright 2017 Broad Institute
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package org.broadinstitute.dropseqrna.utils.readiterators;

import java.util.Iterator;

import org.broadinstitute.dropseqrna.utils.FilteredIterator;

import htsjdk.samtools.SAMRecord;
import htsjdk.samtools.SAMTagUtil;

/**
 * Iterator wrapper that emits a SAMRecord only if *all* the required tags are present.
 */
public class MissingTagFilteringIterator extends FilteredIterator<SAMRecord> {
    final short[] requiredTags;

    public MissingTagFilteringIterator(final Iterator<SAMRecord> underlyingIterator, final String... requiredTags) {
        super(underlyingIterator);
        this.requiredTags = new short[requiredTags.length];
        for (int i = 0; i < requiredTags.length; ++i)
			this.requiredTags[i] = SAMTagUtil.getSingleton().makeBinaryTag(requiredTags[i]);
    }

    @Override
    public boolean filterOut(final SAMRecord rec) {
    	/*
    	if (rec.getReadName().equals("HN7TNBGXX:4:11609:2753:3252"))
			System.out.println("STOP");
		*/
        for (final short tag : requiredTags)
			if (rec.getAttribute(tag) == null)
				return true;
        return false;
    }
}
