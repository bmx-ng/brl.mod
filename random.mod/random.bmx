
SuperStrict

Rem
bbdoc: Math/Random numbers
End Rem
Module BRL.Random

ModuleInfo "Version: 1.08"
ModuleInfo "Author: Mark Sibly, Floyd"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.08"
ModuleInfo "History: New API to enable custom random number generators."
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

Global GlobalRandom:TRandom

Global random_factories:TRandomFactory

Public

Type TRandomFactory
	Field _succ:TRandomFactory
	
	Method New()
		If random_factories <> Null Then
			Throw "Random already installed : " + random_factories.GetName()
		End If
		_succ=random_factories
		random_factories=Self
	End Method
	
	Method Init()
		GlobalRandom = Create()
	End Method
	
	Method GetName:String() Abstract
	
	Method Create:TRandom(seed:Int) Abstract

	Method Create:TRandom() Abstract
		
End Type

Private
Global LastNewMs:Int = MilliSecs()
Global SimultaneousNewCount:Int = 0
? Threaded
Global NewRandomMutex:TMutex = TMutex.Create()
?
Public

Function GenerateSeed:Int()
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
	Return currentMs ~ ReverseBits(auxSeed Shl 1)
End Function

Rem
bbdoc: Random number generator
about:
By creating multiple TRandom objects, multiple independent
random number generators can be used in parallel.
End Rem
Type TRandom
	
	Rem
	bbdoc: Generate random float
	returns: A random float in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndFloat:Float() Abstract
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndDouble:Double() Abstract
	
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
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0) Abstract
	
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
	Method Rand:Int(minValue:Int, maxValue:Int = 1) Abstract
	
	Rem
	bbdoc: Set random number generator seed
	End Rem
	Method SeedRnd(seed:Int) Abstract
	
	Rem
	bbdoc: Get random number generator seed
	returns: The current random number generator seed
	about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
	numbers.
	End Rem
	Method RndSeed:Int() Abstract

End Type

Rem
bbdoc: Creates a new TRandom instance.
End Rem
Function CreateRandom:TRandom()
	If GlobalRandom Then
		Return random_factories.Create()
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

Rem
bbdoc: Creates a new TRandom instance with the given @seed.
End Rem
Function CreateRandom:TRandom(seed:Int)
	If GlobalRandom Then
		Return random_factories.Create(seed)
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

Rem
bbdoc: Generate random float
returns: A random float in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndFloat:Float()
	If GlobalRandom Then
		Return GlobalRandom.RndFloat()
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

Rem
bbdoc: Generate random double
returns: A random double in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndDouble:Double()
	If GlobalRandom Then
		Return GlobalRandom.RndDouble()
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

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
Function Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
	If GlobalRandom Then
		Return GlobalRandom.Rnd(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

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
Function Rand:Int(minValue:Int, maxValue:Int = 1)
	If GlobalRandom Then
		Return GlobalRandom.Rand(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

Rem
bbdoc: Set random number generator seed
End Rem
Function SeedRnd(seed:Int)
	If GlobalRandom Then
		GlobalRandom.SeedRnd seed
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function

Rem
bbdoc: Get random number generator seed
returns: The current random number generator seed
about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
numbers.
End Rem
Function RndSeed:Int()
	If GlobalRandom Then
		Return GlobalRandom.RndSeed()
	Else
		Throw "No Random installed. Maybe Import BRL.RandomDefault ?"
	End If
End Function
