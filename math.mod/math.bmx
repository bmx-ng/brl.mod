
SuperStrict

Rem
bbdoc: Math/Math
End Rem
Module BRL.Math

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06"
ModuleInfo "History: Added Float versions."
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added IsNan and IsInf"

Import "math.c"

Extern

Rem
bbdoc: Check if a value is NAN
returns: True if @x is 'not a number' (eg: Sqr(-1))
End Rem
Function IsNan( x:Double )="bbIsNan"

Rem
bbdoc: Check if a value is infinite (eg: 1.0/0.0)
returns: True if @x is infinite
End Rem
Function IsInf( x:Double )="bbIsInf"

Rem
bbdoc: Square root of @x
End Rem
Function Sqr:Double( x:Double )="bbSqr"

Rem
bbdoc: Sine of @x degrees
End Rem
Function Sin:Double( x:Double )="bbSin"

Rem
bbdoc: Cosine of @x degrees
End Rem
Function Cos:Double( x:Double )="bbCos"

Rem
bbdoc: Tangent of @x degrees
End Rem
Function Tan:Double( x:Double )="bbTan"

Rem
bbdoc: Inverse Sine of @x 
End Rem
Function ASin:Double( x:Double )="bbASin"

Rem
bbdoc: Inverse Cosine of @x
End Rem
Function ACos:Double( x:Double )="bbACos"

Rem
bbdoc: Inverse Tangent of @x
End Rem
Function ATan:Double( x:Double )="bbATan"

Rem
bbdoc: Inverse Tangent of two variables @x , @y
End Rem
Function ATan2:Double( y:Double,x:Double )="bbATan2"

Rem
bbdoc: Hyperbolic sine of @x
End Rem
Function Sinh:Double( x:Double )="bbSinh"

Rem
bbdoc: Hyperbolic cosine of @x
End Rem
Function Cosh:Double( x:Double )="bbCosh"

Rem
bbdoc: Hyperbolic tangent of @x
End Rem
Function Tanh:Double( x:Double )="bbTanh"

Rem
bbdoc: Exponential function
end rem
Function Exp:Double( x:Double )="bbExp"

Rem
bbdoc: Natural logarithm
End Rem
Function Log:Double( x:Double )="bbLog"

Rem
bbdoc: Base 10 logarithm
End Rem
Function Log10:Double( x:Double )="bbLog10"

Rem
bbdoc: Smallest integral value not less than @x
End Rem
Function Ceil:Double( x:Double )="bbCeil"

Rem
bbdoc: Largest integral value not greater than @x
End Rem
Function Floor:Double( x:Double )="bbFloor"



Rem
bbdoc: Square root of @x
End Rem
Function Sqr:Float( x:Float )="bbSqrf"

Rem
bbdoc: Sine of @x degrees
End Rem
Function Sin:Float( x:Float )="bbSinf"

Rem
bbdoc: Cosine of @x degrees
End Rem
Function Cos:Float( x:Float )="bbCosf"

Rem
bbdoc: Tangent of @x degrees
End Rem
Function Tan:Float( x:Float )="bbTanf"

Rem
bbdoc: Inverse Sine of @x 
End Rem
Function ASin:Float( x:Float )="bbASinf"

Rem
bbdoc: Inverse Cosine of @x
End Rem
Function ACos:Float( x:Float )="bbACosf"

Rem
bbdoc: Inverse Tangent of @x
End Rem
Function ATan:Float( x:Float )="bbATanf"

Rem
bbdoc: Inverse Tangent of two variables @x , @y
End Rem
Function ATan2:Float( y:Float,x:Float )="bbATan2f"

Rem
bbdoc: Hyperbolic sine of @x
End Rem
Function Sinh:Float( x:Float )="bbSinhf"

Rem
bbdoc: Hyperbolic cosine of @x
End Rem
Function Cosh:Float( x:Float )="bbCoshf"

Rem
bbdoc: Hyperbolic tangent of @x
End Rem
Function Tanh:Float( x:Float )="bbTanhf"

Rem
bbdoc: Exponential function
end rem
Function Exp:Float( x:Float )="bbExpf"

Rem
bbdoc: Natural logarithm
End Rem
Function Log:Float( x:Float )="bbLogf"

Rem
bbdoc: Base 10 logarithm
End Rem
Function Log10:Float( x:Float )="bbLog10f"

Rem
bbdoc: Smallest integral value not less than @x
End Rem
Function Ceil:Float( x:Float )="bbCeilf"

Rem
bbdoc: Largest integral value not greater than @x
End Rem
Function Floor:Float( x:Float )="bbFloorf"

End Extern
