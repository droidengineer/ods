module ods.enumflag;


struct EnumFlag (E, T)
{
public:

	// Numer of native bytes back this EnumFlag
	//@property const size_t dim() { return (_len + (_bps-1))/_bps; }
	@property const uint dim() { return _flags.sizeof; }

	// The number of bits in the EnumFlag
	@property const size_t length() { return _len; }

	// subclass T without binding
	// will act like a T when needed
	@property T get() { return _flags; }
	alias get this;

	// Copy/duplicate
	@property EnumFlag dup() const
	{
		EnumFlag!(E,T) ef;
		ef._flags = _flags;
		ef._type = _type;
		ef._bps = _bps;
		ef._len = _len;

		return ef;
	}

	void set(E f) { _flags |= (1<<cast(T)f); }
	void clr(E f) { _flags &= ~(1<<cast(T)f); }
	void toggle(E f) { _flags ^= (1<<cast(T)f); }
	void zero() { _flags &= cast(T)0; }
	
	bool isset(E f) const { return (cast(bool)(_flags & (1<<cast(T)f))); }

	// operator overloading
	// Uses [idx] to index enum flag bits
	bool opIndex(E i) const
	in
	{
		// this is superfluous since passing enum guarantees range
		assert(i <= _len);
	}
	body
	{
		return isset(i);
	}

	bool opIndexAssign(bool b, E i)
	{
		if (b) set(i);
		else clr(i);
		return b;
	}

	int opApply(scope int delegate(ref bool) dg)
	{
		int res;
		for (E e = E.min; e <= E.max; e++)
		{
			bool b = opIndex(e);
			res = dg(b);
			this[e] = b;
			if (res) break;
		}
		return res;
	}

	

protected:
	T 	_flags;
	E	_type;
	size_t _len = E.max;
	size_t _bps = T.sizeof * 8;

}
