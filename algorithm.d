module algorithm;

/** toString(Enum)
  ** Facility to check the value of an enumerator against its text representation
  ** @Example: enum MyEnum { gold, blue, bird }; MyEnum e = MyEnum.blue;
  **  if (e == "blue") dosomething();
  ** Taken courtesy Andrei Alexandrescu in The D Programming Language p273
**/
string toString(E)(E value) if (is(E == enum))
{
	foreach (s; __traits(allMembers,E)) {
		if (value == mixin("E." ~ s))
			return s;
	}
	return null;
}

string hexToString()
{

}
