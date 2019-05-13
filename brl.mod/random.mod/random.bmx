
SuperStrict

Rem
bbdoc: Math/Random numbers
End Rem
Module BRL.Random

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly, Floyd"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Rand() with negative min value bug"

Private
Global	rnd_state:Int=$1234
Const	RND_A:Int=48271,RND_M:Int=2147483647,RND_Q:Int=44488,RND_R:Int=3399
Public

Rem
bbdoc: Generate random float
returns: A random float in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndFloat#()
	rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
	If rnd_state<0 rnd_state=rnd_state+RND_M
	Return (rnd_state & $ffffff0) / 268435456#  'divide by 2^28
End Function

Rem
bbdoc: Generate random double
returns: A random double in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndDouble!()
	Const TWO27! = 134217728.0		'2 ^ 27
	Const TWO29! = 536870912.0		'2 ^ 29

	rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
	If rnd_state<0 rnd_state=rnd_state+RND_M
	Local r_hi! = rnd_state & $1ffffffc

	rnd_state=RND_A*(rnd_state Mod RND_Q)-RND_R*(rnd_state/RND_Q)
	If rnd_state<0 rnd_state=rnd_state+RND_M
	Local r_lo! = rnd_state & $1ffffff8

	Return (r_hi + r_lo/TWO27)/TWO29
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
Function Rnd!( min_value!=1,max_value!=0 )
	If max_value>min_value Return RndDouble()*(max_value-min_value)+min_value
	Return RndDouble()*(min_value-max_value)+max_value
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
Function Rand:Int( min_value:Int,max_value:Int=1 )
	Local Range:Int=max_value-min_value
	If Range>0 Return Int( RndDouble()*(1+Range) )+min_value
	Return Int( RndDouble()*(1-Range) )+max_value
End Function

Rem
bbdoc: Set random number generator seed
End Rem
Function SeedRnd( seed:Int )
	rnd_state=seed & $7fffffff             				'enforces rnd_state >= 0
	If rnd_state=0 Or rnd_state=RND_M rnd_state=$1234	'disallow 0 and M
End Function

Rem
bbdoc: Get random number generator seed
returns: The current random number generator seed
about: Use in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
numbers.
End Rem
Function RndSeed:Int()
	Return rnd_state
End Function
