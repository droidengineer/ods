/*******************************************************************************
 ** Name: ringbuf                                                             **
 ** Description: Basic support for a finite cyclic buffer                     **
 **                                                                           **
 ** Open Source Initiative (OSI) Approved License: CDDL                       **
 **                                                                           **
 ** The contents of this file are subject to the terms of the                 **
 ** Common Development and Distribution License, Version 1.0 only             **
 ** (the "License").  You may not use this file except in compliance          **
 ** with the License.                                                         **
 **                                                                           **
 ** You can find a copy of the license in the license.txt within              **
 ** this distribution or at http://opensource.org/licenses/CDDL-1.0.          **
 ** Software distributed under the License is distributed on an "AS IS"       **
 ** basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.           **
 ** See the License for the specific language governing permissions           **
 ** and limitations under the License.                                        **
 **                                                                           **
 ** When distributing Covered Code, include this CDDL header in each          **
 ** file and include the License file at license.{pdf|rtf|otf}.               **
 ** If applicable, add the following below this header, with the indicated    **
 ** fields enclosed by brackets "[]" replaced with your own identifying       **
 ** information: Portions Copyright [yyyy] [name of copyright owner]          **
 **                                                                           **
 ** Copyright (c) 2009-2010  Barry Gian James <bjames@avr-firmware.net>       **
 ** All rights reserved.                                                      **
 **                                                                           **
 ** Ref: $HeadURL: https://munix.svn.codeplex.com/svn/trunk/libmunix/common.h $
 ******************************************************************************/
 // Portions (C) 2011-13 Open Design Strategies, LLC.
 // All Rights Reserved

module ods.ringbuff;

class RingBuff (T)
{
public:	
	this(int ds = 32) {
		_sz = 0;
		_head = _tail = 0;
		_capacity = ds;
		_buff = new T[_sz]();
	}
	void put(T c) {
		_buff[_tail++] = c;
		if (_tail >= _capacity) _tail = 0;
		++_sz;
	}
	T get() {
		if (_sz == 0) return null;
		T c = _buff[_head++];
		if (_head >= _capacity) _head = 0;
		--_sz;
		return c;
	}

	@property bool empty() const { return (_head == _tail); }
	@property int size() const { return _sz; }
	@property int capacity() const { return _capacity; }
	T []  data() { return _buff; }
	void erase() {
		for(int i = 0; i < _sz; i++)
			_buff[i] = null;
	}
	@property int head() const { return _head; }
	@property int tail() const { return _tail; }

private:
	T [] _buff;
	int	_sz;
	int _head, _tail;
	int _capacity;
}
