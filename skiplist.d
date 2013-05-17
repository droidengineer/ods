module skiplist;

import std.random;
import std.exception;

public class SkipListException : Exception
{
	enum ExceptionCause { UnknownError, InvariantError, InvalidNext }

	this(ExceptionCause c, string s) { _cause = c; this(s); }
	this(string s) { super(s); }

	public int Why() const { return _cause; }

	private ExceptionCause _cause = ExceptionCause.UnknownError;
}

class SkipList(T)
{
	private struct Node
	{
		this(T d, int l, double p = DEFAULT_PVAL) { 
			data = d; lvl = l; _p = p;
			next = new Node * [lvl];
			for (int i = 0; i < lvl; i++)
				next[i] = null;
		}
		~this() { if (next) clear(next); }

		@property T * contents() { return &data; }

		T		data;
		Node ** next;
		int		lvl;
	}
public:

	@property T* head(int idx) { return _head[idx]; }
	@property bool empty() const { return _head is null; }

	void		insert(const T d) {
	}
	void		remove(const T d) {
	}
	T *			query(const T d) {
	}
	void		print() const {
	}
	Node *		queryNode(const T n) {
	}


private:
	int	_randLevel() const {
		auto i = uniform(DEFAULT_MIN_LVL, DEFAULT_MAX_LVL);
		return i;
	}

	void	_checkInvariant() const {

	}

	void opAssign(SkipList!T rhs) { assert(false); }

	int	_p;
	int	_lvl;
	int	_maxLvl;
	Node!T ** _head;
}
	
