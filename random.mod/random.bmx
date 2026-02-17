
SuperStrict

Rem
bbdoc: Random numbers - Default implementation
End Rem
Module BRL.Random

ModuleInfo "Version: 1.11"
ModuleInfo "Author: Mark Sibly, Floyd"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.11"
ModuleInfo "History: Improved range of Rand()"
ModuleInfo "History: 1.10"
ModuleInfo "History: Added GetName()."
ModuleInfo "History: 1.09"
ModuleInfo "History: Refactored back to BRL.Random."
ModuleInfo "History: 1.08"
ModuleInfo "History: Changed to default random number generator."
ModuleInfo "History: 1.07"
ModuleInfo "History: Added support for multiple generators"
ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Rand() with negative min value bug"

Import Random.Core

Private
Const RND_A:Int=48271,RND_M:Int=2147483647,RND_Q:Int=44488,RND_R:Int=3399
Const SIGNBIT_64:ULong = $8000000000000000:ULong
Public

Rem
bbdoc: Random number generator
about:
By creating multiple TRandom objects, multiple independent
random number generators can be used in parallel.
End Rem
Type TRandomDefault Extends TRandom
	
	Private
	
	Field rnd_state:Int=$1234
	
	Public
	
	Rem
	bbdoc: Create a new random number generator
	End Rem
	Method New()
		SeedRnd(GenerateSeed())
	End Method
	
	Rem
	bbdoc: Create a new random number generator with the specified seed
	End Rem
	Method New(seed:Int)
		SeedRnd seed
	End Method

	Method NextState:Int()
		rnd_state = RND_A * (rnd_state Mod RND_Q) - RND_R * (rnd_state / RND_Q)
		If rnd_state < 0 Then rnd_state :+ RND_M
		Return rnd_state
	End Method

	Method NextULong:ULong()
		' 31-bit rnd_state; avoid low bits by shifting right.
		' harvest 22 + 22 + 20 = 64 bits total.

		Local a:ULong = ULong((NextState() Shr 9)  & $003FFFFF) ' top-ish 22 bits
		Local b:ULong = ULong((NextState() Shr 9)  & $003FFFFF) ' 22 bits
		Local c:ULong = ULong((NextState() Shr 11) & $000FFFFF) ' 20 bits

		Return (a Shl 42) | (b Shl 20) | c
	End Method
	
	Rem
	bbdoc: Generate random float
	returns: A random float in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndFloat:Float()
		Local state:Int = NextState()
		Return (rnd_state & $ffffff0) / 268435456#  'divide by 2^28
	End Method
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndDouble:Double()
		Const TWO27! = 134217728.0		'2 ^ 27
		Const TWO29! = 536870912.0		'2 ^ 29
	
		Local state:Int = NextState()
		Local r_hi! = state & $1ffffffc
	
		state = NextState()
		Local r_lo! = state & $1ffffff8
	
		Return (r_hi + r_lo/TWO27)/TWO29
	End Method
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range min (inclusive) to max (exclusive)
	about: 
	The optional parameters allow you to use Rnd in 3 ways:
	
	[ @Format | @Result
	* `Rnd()` | Random double in the range 0 (inclusive) to 1 (exclusive)
	* `Rnd(x)` | Random double in the range 0 (inclusive) to n (exclusive)
	* `Rnd(x,y)` | Random double in the range x (inclusive) to y (exclusive)
	]
	End Rem
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
		If maxValue>minValue Return RndDouble()*(maxValue-minValue)+minValue
		Return RndDouble()*(minValue-maxValue)+maxValue
	End Method

	Method RandomInt:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Long=Long(maxValue)-minValue
		If Range>0 Return Long( RndDouble()*(1+Range) )+minValue
		Return Long( RndDouble()*(1-Range) )+maxValue
	End Method

	Method RandomLong:Long(minValue:Long, maxValue:Long = 1)
		Local lo:Long = minValue
		Local hi:Long = maxValue
		If lo > hi Then
			Local t:Long = lo
			lo = hi
			hi = t
		End If

		' Map signed -> order-preserving unsigned
		Local ulo:ULong = (ULong(lo) ~ SIGNBIT_64)
		Local uhi:ULong = (ULong(hi) ~ SIGNBIT_64)

		' Draw uniformly in that unsigned interval
		Local u:ULong = RandomULongRange(ulo, uhi)

		' Map back unsigned -> signed
		Return Long(u ~ SIGNBIT_64)
	End Method

	Method RandomLongInt:LongInt(minValue:LongInt, maxValue:LongInt = 1)
		Return LongInt(RandomLong(minValue, maxValue))
	End Method

	Method RandomULongRange:ULong(lo:ULong, hi:ULong)
		If lo > hi Then
			Local t:ULong = lo
			lo = hi
			hi = t
		End If

		Local span:ULong = hi - lo + 1:ULong

		' span==0 means full 0..2^64-1
		If span = 0:ULong Then
			Return NextULong()
		End If

		Local max:ULong = $FFFFFFFFFFFFFFFF:ULong
		Local limit:ULong = (max / span) * span - 1:ULong

		Local r:ULong
		Repeat
			r = NextULong()
		Until r <= limit

		Return lo + (r Mod span)
	End Method

	Method RandomULong:ULong(minValue:ULong, maxValue:ULong = 1)
		Return RandomULongRange(minValue, maxValue)
	End Method

	Method RandomByte:Byte(minValue:Byte, maxValue:Byte = 1)
		Return Byte(RandomULongRange(ULong(minValue), ULong(maxValue)))
	End Method

	Method RandomShort:Short(minValue:Short, maxValue:Short = 1)
		Return Short(RandomULongRange(ULong(minValue), ULong(maxValue)))
	End Method

	Method RandomUInt:UInt(minValue:UInt, maxValue:UInt = 1)
		Return UInt(RandomULongRange(ULong(minValue), ULong(maxValue)))
	End Method

	Method RandomULongInt:ULongInt(minValue:ULongInt, maxValue:ULongInt = 1)
		Return ULongInt(RandomULongRange(ULong(minValue), ULong(maxValue)))
	End Method

	Method RandomSizeT:Size_T(minValue:Size_T, maxValue:Size_T = 1)
		Return Size_T(RandomULongRange(ULong(minValue), ULong(maxValue)))
	End Method
	
	Rem
	bbdoc: Generate random integer
	returns: A random integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #Rand in 2 ways:
	
	[ @Format | @Result
	* `Rand(x)` | Random integer in the range 1 to x (inclusive)
	* `Rand(x,y)` | Random integer in the range x to y (inclusive)
	]
	End Rem
	Method Rand:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Long=Long(maxValue)-minValue
		If Range>0 Return Long( RndDouble()*(1+Range) )+minValue
		Return Long( RndDouble()*(1-Range) )+maxValue
	End Method
	
	Rem
	bbdoc: Set random number generator seed
	End Rem
	Method SeedRnd(seed:Int)
		rnd_state=seed & $7fffffff             				'enforces rnd_state >= 0
		If rnd_state=0 Or rnd_state=RND_M rnd_state=$1234	'disallow 0 and M
	End Method
	
	Rem
	bbdoc: Get random number generator seed
	returns: The current random number generator seed
	about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
	numbers.
	End Rem
	Method RndSeed:Int()
		Return rnd_state
	End Method

	Method GetName:String()
		Return "Random"
	End Method
End Type

Private
Type TRandomDefaultFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "Random"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TRandomDefault(seed)
	End Method

	Method Create:TRandom()
		Return New TRandomDefault()
	End Method
		
End Type

New TRandomDefaultFactory
