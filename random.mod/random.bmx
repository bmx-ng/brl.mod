
SuperStrict

Rem
bbdoc: Math/Random numbers
End Rem
Module BRL.Random

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly, Floyd"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07"
ModuleInfo "History: Added support for multiple generators"
ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Rand() with negative min value bug"

? Threaded
Import BRL.Threads
?

Private
Const RND_A:Int=48271,RND_M:Int=2147483647,RND_Q:Int=44488,RND_R:Int=3399
Global LastNewMs:Int = MilliSecs()
Global SimultaneousNewCount:Int = 0
? Threaded
Global NewRandomMutex:TMutex = TMutex.Create()
?
Global GlobalRandom:TRandom = New TRandom
Public

Rem
bbdoc: Random number generator
about:
By creating multiple TRandom objects, multiple independent
random number generators can be used in parallel.
End Rem
Type TRandom
	
	Private
	
	Field rnd_state:Int=$1234
	
	Public
	
	Rem
	bbdoc: Create a new random number generator
	End Rem
	Method New()
		? Threaded
		NewRandomMutex.Lock
		?
		Local currentMs:Int = MilliSecs()
		Local auxSeed:Int
		If currentMs = LastNewMs Then
			SimultaneousNewCount :+ 1
			auxSeed = SimultaneousNewCount
		Else
			LastNewMs = currentMs
			SimultaneousNewCount = 0
			auxSeed = 0
		End If
		? Threaded
		NewRandomMutex.Unlock
		?
		
		Function ReverseBits:Int(i:Int)
			If i = 0 Then Return 0
			Local r:Int
			For Local b:Int = 0 Until 8 * SizeOf i
				r :Shl 1
				r :| i & 1
				i :Shr 1
			Next
			Return r
		End Function
		' left-shift before reversing because SeedRnd ignores the most significant bit
		Local seed:Int = currentMs ~ ReverseBits(auxSeed Shl 1)
		SeedRnd seed
	End Method
	
	Rem
	bbdoc: Create a new random number generator with the specified seed
	End Rem
	Method New(seed:Int)
		SeedRnd seed
	End Method
	
	Rem
	bbdoc: Generate random float
	returns: A random float in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndFloat:Float()
		rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
		If rnd_state<0 rnd_state=rnd_state+RND_M
		Return (rnd_state & $ffffff0) / 268435456#  'divide by 2^28
	End Method
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndDouble:Double()
		Const TWO27! = 134217728.0		'2 ^ 27
		Const TWO29! = 536870912.0		'2 ^ 29
	
		rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
		If rnd_state<0 rnd_state=rnd_state+RND_M
		Local r_hi! = rnd_state & $1ffffffc
	
		rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
		If rnd_state<0 rnd_state=rnd_state+RND_M
		Local r_lo! = rnd_state & $1ffffff8
	
		Return (r_hi + r_lo/TWO27)/TWO29
	End Method
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range min (inclusive) to max (exclusive)
	about: 
	The optional parameters allow you to use Rnd in 3 ways:
	
	[ @Format | @Result
	* &Rnd() | Random double in the range 0 (inclusive) to 1 (exclusive)
	* &Rnd(_x_) | Random double in the range 0 (inclusive) to n (exclusive)
	* &Rnd(_x,y_) | Random double in the range x (inclusive) to y (exclusive)
	]
	End Rem
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
		If maxValue>minValue Return RndDouble()*(maxValue-minValue)+minValue
		Return RndDouble()*(minValue-maxValue)+maxValue
	End Method
	
	Rem
	bbdoc: Generate random integer
	returns: A random integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #Rand in 2 ways:
	
	[ @Format | @Result
	* &Rand(x) | Random integer in the range 1 to x (inclusive)
	* &Rand(x,y) | Random integer in the range x to y (inclusive)
	]
	End Rem
	Method Rand:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Int=maxValue-minValue
		If Range>0 Return Int( RndDouble()*(1+Range) )+minValue
		Return Int( RndDouble()*(1-Range) )+maxValue
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

End Type

Rem
bbdoc: Generate random float
returns: A random float in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndFloat:Float()
	Return GlobalRandom.RndFloat()
End Function

Rem
bbdoc: Generate random double
returns: A random double in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndDouble:Double()
	Return GlobalRandom.RndDouble()
End Function

Rem
bbdoc: Generate random double
returns: A random double in the range min (inclusive) to max (exclusive)
about: 
The optional parameters allow you to use Rnd in 3 ways:

[ @Format | @Result
* &Rnd() | Random double in the range 0 (inclusive) to 1 (exclusive)
* &Rnd(_x_) | Random double in the range 0 (inclusive) to n (exclusive)
* &Rnd(_x,y_) | Random double in the range x (inclusive) to y (exclusive)
]
End Rem
Function Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
	Return GlobalRandom.Rnd(minValue, maxValue)
End Function

Rem
bbdoc: Generate random integer
returns: A random integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #Rand in 2 ways:

[ @Format | @Result
* &Rand(x) | Random integer in the range 1 to x (inclusive)
* &Rand(x,y) | Random integer in the range x to y (inclusive)
]
End Rem
Function Rand:Int(minValue:Int, maxValue:Int = 1)
	Return GlobalRandom.Rand(minValue, maxValue)
End Function

Rem
bbdoc: Set random number generator seed
End Rem
Function SeedRnd(seed:Int)
	GlobalRandom.SeedRnd seed
End Function

Rem
bbdoc: Get random number generator seed
returns: The current random number generator seed
about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
numbers.
End Rem
Function RndSeed:Int()
	Return GlobalRandom.RndSeed()
End Function

