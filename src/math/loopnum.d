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


unittest {
	import std.meta;
	{
		foreach(T; AliasSeq!(int, uint, float)) {
			alias L = LoopNum!(T,100);
			assert(L(5) + 5 == L(10));
			assert(L(50) + 50 == L(0));
			assert(L(50) + 51 == L(1));
			assert(L(51) + 50 == L(1));
			assert(L(51) - 50 == L(1));
			assert(L(50) - 51 == L(99));
			assert(L(51) + 150 == L(1));
			assert(L(51) - 150 == L(1));
		}
		foreach(T; AliasSeq!(int, float)) {
			alias L = LoopNum!(T,100);
			assert(L(5) - (-5) == L(10));
			assert(L(50) - (-50) == L(0));
			assert(L(50) - (-51) == L(1));
			assert(L(51) - (-50) == L(1));
			assert(L(51) + (-50) == L(1));
			assert(L(50) + (-51) == L(99));
			assert(L(51) - (-150) == L(1));
			assert(L(51) + (-150) == L(1));
		}
	}
	{
		foreach(T; AliasSeq!(int, uint, float)) {
			alias L = LoopNum!(T,10,100);
			assert(L(15) + 5 == L(20));
			assert(L(50) + 50 == L(10));
			assert(L(50) + 51 == L(11));
			assert(L(51) + 50 == L(11));
			assert(L(51) - 40 == L(11));
			assert(L(50) - 41 == L(99));
			assert(L(51) + 140 == L(11));
			assert(L(51) - 130 == L(11));
		}
		foreach(T; AliasSeq!(int, float)) {
			alias L = LoopNum!(T,10,100);
			assert(L(15) - (-5) == L(20));
			assert(L(50) - (-50) == L(10));
			assert(L(50) - (-51) == L(11));
			assert(L(51) - (-50) == L(11));
			assert(L(51) + (-40) == L(11));
			assert(L(50) + (-41) == L(99));
			assert(L(51) - (-140) == L(11));
			assert(L(51) + (-130) == L(11));
		}
	}
	{
		foreach(T; AliasSeq!(int, float)) {
			alias L = LoopNum!(T,-10,100);
			assert(L(-5) + 5 == L(0));
			assert(L(50) + 50 == L(-10));
			assert(L(50) + 51 == L(-9));
			assert(L(51) + 50 == L(-9));
			assert(L(51) - 60 == L(-9));
			assert(L(50) - 61 == L(99));
			assert(L(51) + 160 == L(-9));
			assert(L(51) - 170 == L(-9));
			
			assert(L(-5) - (-5) == L(0));
			assert(L(50) - (-50) == L(-10));
			assert(L(50) - (-51) == L(-9));
			assert(L(51) - (-50) == L(-9));
			assert(L(51) + (-60) == L(-9));
			assert(L(50) + (-61) == L(99));
			assert(L(51) - (-160) == L(-9));
			assert(L(51) + (-170) == L(-9));
		}
	}
	{
		foreach(T; AliasSeq!(int)) {
			alias L = LoopNum!(T, T.min+1, T.max+1);
			assert(L(5) + 1 == L(6));
			assert(L(T.max).num == T.max);
			assert(L(T.min) == L(T.max));
			assert(L(T.min+1) - 1 == L(T.max));
			assert(L(T.max) + 1 == L(T.min+1));
			assert(L(T.min+1) + T.max == L(0));
			assert(L(T.max) - T.max == L(0));
			assert(L(T.min+1) - T.max == L(1));
			assert(L(T.max) + T.max == L(-1));
			assert(L(T.min/2) - T.min/2 == L(0));
		}
	}
}

