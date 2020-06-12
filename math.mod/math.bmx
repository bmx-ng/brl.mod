
SuperStrict

Rem
bbdoc: Math/Math
End Rem
Module BRL.Math

ModuleInfo "Version: 1.08"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.08"
ModuleInfo "History: Inlined math functions."
ModuleInfo "History: 1.07"
ModuleInfo "History: Added Round and Trunc."
ModuleInfo "History: 1.06"
ModuleInfo "History: Added Float versions."
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added IsNan and IsInf"

Import "bbMath.h"
Import "math.c"

Extern

Rem
bbdoc: Check if a value is NAN
returns: True if @x is 'not a number' (eg: Sqr(-1))
End Rem
Function IsNan:Int( x:Double )="int bbIsNan(double)!"

Rem
bbdoc: Check if a value is infinite (eg: 1.0/0.0)
returns: True if @x is infinite
End Rem
Function IsInf:Int( x:Double )="int bbIsInf(double)!"

Rem
bbdoc: Square root of @x
End Rem
Function Sqr:Double( x:Double )="double bbSqr(double)!"

Rem
bbdoc: Sine of @x degrees
End Rem
Function Sin:Double( x:Double )="double bbSin(double)!"

Rem
bbdoc: Cosine of @x degrees
End Rem
Function Cos:Double( x:Double )="double bbCos(double)!"

Rem
bbdoc: Tangent of @x degrees
End Rem
Function Tan:Double( x:Double )="double bbTan(double)!"

Rem
bbdoc: Inverse Sine of @x 
End Rem
Function ASin:Double( x:Double )="double bbASin(double)!"

Rem
bbdoc: Inverse Cosine of @x
End Rem
Function ACos:Double( x:Double )="double bbACos(double)!"

Rem
bbdoc: Inverse Tangent of @x
End Rem
Function ATan:Double( x:Double )="double bbATan(double)!"

Rem
bbdoc: Inverse Tangent of two variables @x , @y
End Rem
Function ATan2:Double( y:Double,x:Double )="double bbATan2(double,double)!"

Rem
bbdoc: Hyperbolic sine of @x
End Rem
Function Sinh:Double( x:Double )="double bbSinh(double)!"

Rem
bbdoc: Hyperbolic cosine of @x
End Rem
Function Cosh:Double( x:Double )="double bbCosh(double)!"

Rem
bbdoc: Hyperbolic tangent of @x
End Rem
Function Tanh:Double( x:Double )="double bbTanh(double)!"

Rem
bbdoc: Exponential function
end rem
Function Exp:Double( x:Double )="double bbExp(double)!"

Rem
bbdoc: Natural logarithm
End Rem
Function Log:Double( x:Double )="double bbLog(double)!"

Rem
bbdoc: Base 10 logarithm
End Rem
Function Log10:Double( x:Double )="double bbLog10(double)!"

Rem
bbdoc: Smallest integral value not less than @x
End Rem
Function Ceil:Double( x:Double )="double bbCeil(double)!"

Rem
bbdoc: Largest integral value not greater than @x
End Rem
Function Floor:Double( x:Double )="double bbFloor(double)!"

Rem
bbdoc: Nearest integral value to @x.
End Rem
Function Round:Double( x:Double )="double bbRound(double)!"

Rem
bbdoc: Nearest integral not greater in magnitude than @x.
End Rem
Function Trunc:Double( x:Double )="double bbTrunc(double)!"


Rem
bbdoc: Square root of @x
End Rem
Function SqrF:Float( x:Float )="float bbSqrf(float)!"

Rem
bbdoc: Sine of @x degrees
End Rem
Function SinF:Float( x:Float )="float bbSinf(float)!"

Rem
bbdoc: Cosine of @x degrees
End Rem
Function CosF:Float( x:Float )="float bbCosf(float)!"

Rem
bbdoc: Tangent of @x degrees
End Rem
Function TanF:Float( x:Float )="float bbTanf(float)!"

Rem
bbdoc: Inverse Sine of @x 
End Rem
Function ASinF:Float( x:Float )="float bbASinf(float)!"

Rem
bbdoc: Inverse Cosine of @x
End Rem
Function ACosF:Float( x:Float )="float bbACosf(float)!"

Rem
bbdoc: Inverse Tangent of @x
End Rem
Function ATanF:Float( x:Float )="float bbATanf(float)!"

Rem
bbdoc: Inverse Tangent of two variables @x , @y
End Rem
Function ATan2F:Float( y:Float,x:Float )="float bbATan2f(float,float)!"

Rem
bbdoc: Hyperbolic sine of @x
End Rem
Function SinhF:Float( x:Float )="float bbSinhf(float)!"

Rem
bbdoc: Hyperbolic cosine of @x
End Rem
Function CoshF:Float( x:Float )="float bbCoshf(float)!"

Rem
bbdoc: Hyperbolic tangent of @x
End Rem
Function TanhF:Float( x:Float )="float bbTanhf(float)!"

Rem
bbdoc: Exponential function
end rem
Function ExpF:Float( x:Float )="float bbExpf(float)!"

Rem
bbdoc: Natural logarithm
End Rem
Function LogF:Float( x:Float )="float bbLogf(float)!"

Rem
bbdoc: Base 10 logarithm
End Rem
Function Log10F:Float( x:Float )="float bbLog10f(float)!"

Rem
bbdoc: Smallest integral value not less than @x
End Rem
Function CeilF:Float( x:Float )="float bbCeilf(float)!"

Rem
bbdoc: Largest integral value not greater than @x
End Rem
Function FloorF:Float( x:Float )="float bbFloorf(float)!"

Rem
bbdoc: Nearest integral value to @x.
End Rem
Function RoundF:Float( x:Float )="float bbRoundf(float)!"

Rem
bbdoc: Nearest integral not greater in magnitude than @x.
End Rem
Function TruncF:Float( x:Float )="float bbTruncf(float)!"

End Extern
