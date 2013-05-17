module ods.oid;

import std.datetime;

class OID(T)
{
public:
	/** Generate a new OID given the parent OID
	*/
	this(OID * p, ulong i, T v)
	{
		_up = p;
		_down = _next = null;
		_id = i;
		_value = v;
		_maxChild = 0;
		_created = Clock.currTime();
	}
	~this() { if (_next) clear(_next); if (_down) clear(_down); }

	ulong	getNextChildOID() { return ++_maxChild; }
	OID 	addChild(ref T v)
	{
		OID c = new OID(this,getChildOID(),v);
		if (_down == null) _down = c;
		else {
			c.next() = _down;
			_down = c;
		}
		return c;
	}

	/**********************************************************************
	 * Support for sibling OIDs
	 *
	 * getNextOID() for 1.3 return 4.
	 * addNext() for 1.3 adds 1.4
	 * Authors: B. Gian James <gian@objectworks.org>
	 */
	ulong	getNextOID() { return _id + 1; }
	OID		addNext(ref T v)
	{
		OID c = new OID(_up,getNextOID(),v);
		_next = c;
		return c;
	}

	const void	print(FILE * o) const
	{
		//o.writefln("%d:%s",_id,_value.toString());
		o.write(_id,":",_value.toString());
	}
	const void printAll(File * o) const
	{
		print(o);
		if (_down)
			_next.print(o);
	}
	
	void	setName(string n) { _name = n; }
	void	setAuthority(string a) { _authority = n; }
	ref T	getData() { return _value; }
	ulong	numChildren() { return _maxChild; }
	OID *	next() { return _next; }
	@property OID *	parent() { return _up; }
	@property string authority() { return _authority; }
	@property string name() { return _name; }
	@property string creationDate() { return _created.toISOExtString(); }

private:
	ulong	_id;
	T		_value;
	ulong	_maxChild;
	string	_name;
	DateTime _created;
	string	_authority;

	OID *	_up;	// 1.3.1 -> 1.3
	OID *	_down;	// 1.3.1 -> 1.3.1.1
	OID *	_next;	// 1.3.1 -> 1.3.2

	//bool operator == (const OID & o) const { return ; }
}

