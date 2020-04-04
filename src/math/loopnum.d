module math.loopnum; 

import std.traits;


/// Inclusing min and exclusive max.  Effectively max will equal min, min & max will be the joining number in the loop, 360deg = 0deg, `LoopNum(int,360)(360)==LoopNum(int,360)(0)`.
alias LoopNum(T, T max) = LoopNum!(T, 0, max);
struct LoopNum(T, T min, T max) // For signed integrals: `max == T.min` is interpreted as `max == T.max+1`.
if (min<max || isIntegral!T && isSigned!T && max==T.min)
{
	static assert (!(isIntegral!T && isSigned!T && min==T.min), "For signed integrals: `min` cannot be `T.min` because `max-min` must fit in UT and `max==T.min` is interpreted as `T.max+1`.");
	
	alias This = typeof(this);
	static if (isIntegral!T)
		alias UT = Unsigned!T;
	else
		alias UT = T;
	
	T num=min;
	
	T opCast(T:T)() {
		return num;
	}
	
	this (T init) {
		num = fix(init);
	}
	
	static T fix(T n) {
		if (n >= min)
			return min + (cast(UT) n-min) % (cast(UT) max-min);
		else
			return max - (cast(UT) min-n) % (cast(UT) max-min);
	}
	
	This opBinary(string op:"+")(T rhs) {
		static if (isIntegral!T && isSigned!T)
			assert(rhs!=T.min);
		if (rhs < 0)
			return this - (-rhs);
		if (rhs < cast(UT) max-num)
			return This(num+rhs);
		else
			return This(min + (rhs - (cast(UT) max-num)) % (cast(UT) max-min));
	}
	This opBinary(string op:"-")(T rhs) {
		static if (isIntegral!T && isSigned!T)
			assert(rhs!=T.min);
		if (rhs < 0)
			return this + (-rhs);
		if (rhs <= cast(UT) num-min)
			return This(num-rhs);
		else
			return This(max - (rhs - (cast(UT) num-min)) % (cast(UT) max-min));
	}
	
	bool opEquals(This rhs) {
		return num == rhs.num;
	}
}

