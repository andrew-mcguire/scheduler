/*
 * Streams that have a different close mechanism.
 * Copyright (C) 2003 Stephen Ostermiller
 * http://ostermiller.org/contact.pl?regarding=Java+Utilities
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * See COPYING.TXT for details.
 */
package com.Ostermiller.util;

import java.io.*;

/**
 * A reader which a close method with no effect.
 * More information about this class is available from <a target="_top" href=
 * "http://ostermiller.org/utils/NoCloseStream.html">ostermiller.org</a>.
 * <p>
 * This class is designed to wrap a normal reader
 * so that it can be passed to methods that read from it
 * and may erroneously close it.  This class is a workaround
 * when the method cannot be modified because it is in a
 * library.
 *
 * @author Stephen Ostermiller http://ostermiller.org/contact.pl?regarding=Java+Utilities
 * @since ostermillerutils 1.01.00
 */
public class NoCloseReader extends Reader implements NoCloseStream {

	/**
	 * The reader that is being protected.
	 * All methods should be forwarded to it,
	 * except for the close method, which should
	 * do nothing.  The reallyClose method should
	 * actually close this stream.
	 *
	 * @since ostermillerutils 1.01.00
	 */
	protected Reader in;

	/**
	 * Protect a new reader.
	 *
	 * @param in The reader that is being protected.
	 *
	 * @since ostermillerutils 1.01.00
	 */
	public NoCloseReader(Reader in){
		this.in = in;
	}

	/**
	 * {@inheritDoc}
	 */
	public int read() throws IOException {
		return in.read();
	}

	/**
	 * {@inheritDoc}
	 */
	public int read(char[] cbuf) throws IOException {
		return in.read(cbuf);
	}

	/**
	 * {@inheritDoc}
	 */
	public int read(char[] cbuf, int off, int len) throws IOException {
		return in.read(cbuf, off, len);
	}

	/**
	 * {@inheritDoc}
	 */
	public long skip(long n) throws IOException {
		return in.skip(n);
	}

	/**
	 * {@inheritDoc}
	 */
	public boolean ready() throws IOException {
		return in.ready();
	}

	/**
	 * Has no effect.
	 *
	 * @see #reallyClose()
	 *
	 * @since ostermillerutils 1.01.00
	 */
	public void close() throws IOException {
	}

	/**
	 * {@inheritDoc}
	 */
	public void mark(int readlimit) throws IOException {
		in.mark(readlimit);
	}

	/**
	 * {@inheritDoc}
	 */
	public void reset() throws IOException {
		in.reset();
	}

	/**
	 * {@inheritDoc}
	 */
	public boolean markSupported(){
		return in.markSupported();
	}

	/**
	 * {@inheritDoc}
	 */
	public void reallyClose() throws IOException {
		in.close();
	}
}
