module newint;

class Integer24
{
public:
	this() { _a[0] = _a[1] = _a[2] = 0x00; }
	this(int i) {_a[0] = i; _a[1] = (i>>8); _a[2] = (1>>16); }
	
	int	toInteger() {
		int res = (
					(int)(a[2]*0x10000)
					| (int)(a[1] * 0x100)
					| (int)(a[0])
					);
		return res;
	}

	string toString() {
		return cast(string) toInteger().stringof;
	}

	ref Integer24 opUnary(string op)() if (op == "++") {

		return this;
	}


	string opCast(T) if (is(T == string)) {
		return toString();
	}

	int opCast(T) if (is(T == int)) {
		return toInteger();
	}

private:
	uchar [2] _a;	

}

alias Integer24 int24_t;
alias Integer24 faddr_t;
alias Integer24 raddr_t;
