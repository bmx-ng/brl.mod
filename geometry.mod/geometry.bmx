' Copyright (c) 2019 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 
'    3. This notice may not be removed or altered from any source
'    distribution.
' 
SuperStrict

Rem
bbdoc: Math/Geometry
End Rem
Module BRL.Geometry

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2019 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Math
Import BRL.StringBuilder

Rem
bbdoc: A 2-element structure that can be used to represent positions and directions in 2D-space.
End Rem
Struct SVec2
	Field x:Float
	Field y:Float
	
	Rem
	bbdoc: Creates a new #SVec2 from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Returns #True if @b is different.
	End Rem
	Method Operator<>:Int(b:SVec2)
		Return x <> b.x Or y <> b.y
	End Method

	Rem
	bbdoc: Returns #True if the vector and @b are aproximately equal.
	End Rem
	Method Operator=:Int(b:SVec2)
		Return (Self - b).LengthSquared() < 0.00000001
	End Method

	Rem
	bbdoc: Adds @b to the vector, returning the new vector.
	End Rem
	Method Operator+:SVec2(b:SVec2)
		Return New SVec2(x + b.x, y + b.y)
	End Method
	
	Rem
	bbdoc: Subtracts @b from the vector, returning the new vector.
	End Rem
	Method Operator-:SVec2(b:SVec2)
		Return New SVec2(x - b.x, y - b.y)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning the vectors.
	End Rem
	Method Operator*:SVec2(b:SVec2)
		Return New SVec2(x * b.x, y * b.y)
	End Method

	Rem
	bbdoc: Divides the vector by @b, returning the new vector.
	End Rem
	Method Operator/:SVec2(b:SVec2)
		Return New SVec2(x / b.x, y / b.y)
	End Method
	
	Rem
	bbdoc: Returns the vector, negated.
	End Rem
	Method Operator-:SVec2()
		Return New SVec2(-x, -y)
	End Method

	Rem
	bbdoc: Scales the vector by @s, returning the new vector.
	End Rem
	Method Operator*:SVec2(s:Float)
		Return New SVec2(x * s, y * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning the new vector.
	End Rem
	Method Operator/:SVec2(s:Float)
		Return New SVec2(x / s, y / s)
	End Method
	
	Rem
	bbdoc: Retrieves the x or y component using [0] or [1] respectively.
	End Rem
	Method Operator[]:Float(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
		End Select
		
		Throw New TArrayBoundsException
	End Method
	
	Rem
	bbdoc: Sets the x or y component using [0] or [1] respectively.
	End Rem
	Method Operator[]=(index:Int, value:Float)
		Select index
			Case 0
				x = value
			Case 1
				y = value
			Default
				Throw New TArrayBoundsException
		End Select
	End Method
	
	Rem
	bbdoc: Returns the unsigned angle between this vector and @b.
	End Rem
	Method Angle:Float(b:SVec2)
		Local d:Float = Sqr(LengthSquared() * b.LengthSquared())

		If d < 1e-15 Then
			Return 0
		End If

		Local dot:Float = ClampF(Self.Dot(b) / d, -1, 1)
		Return _acos(dot) * 57.295779513
	End Method
	
	Rem
	bbdoc: Applies the 2x2 matrix @z to the vector, returning the new vector.
	End Rem
	Method Apply:SVec2(z:SMat2)
		Return New SVec2(z.a * x + z.c * y, z.b * x + z.d * y)
	End Method

	Rem
	bbdoc: Applies the 3x3 matrix to the vector, returning the new vector.
	End Rem
	Method Apply:SVec2(z:SMat3 Var)
		Return New SVec2(z.a * x + z.d * y + z.g, z.b * x + z.e * y + z.h)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix to the vector, returning the new vector.
	End Rem
	Method Apply:SVec2(z:SMat4 Var)
		Return New SVec2(z.a * x + z.e * y + z.m, z.b * x + z.f * y + z.n)
	End Method
	
	Rem
	bbdoc: Returns the vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec2(minv:SVec2, maxv:SVec2)
		Return New SVec2(ClampF(x, minv.x, maxv.x), ClampF(y, minv.y, maxv.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec2(b:SVec2)
		Return New SVec2(MinF(x, b.x), MinF(y, b.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec2(b:SVec2)
		Return New SVec2(MaxF(x, b.x), MaxF(y, b.y))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Lerp:SVec2(b:SVec2, t:Float)
		Return New SVec2(LerpF(x, b.x, t), LerpF(y, b.y, t))
	End Method
	
	Rem
	bbdoc: Returns the vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec2()
		Local length:Float = x * x + y * y
		If length > 0 Then
			length = Sqr(length)
			Return New SVec2(x / length, y / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors #Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Float(b:SVec2)
		Return x * b.x + y * b.y
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Float()
		Return Sqr(LengthSquared())
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Float()
		Return x * x + y * y
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector And @b.
	End Rem
	Method Distance:Float(b:SVec2)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceSquared:Float(b:SVec2)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector perpendicular to the vector.
	End Rem
	Method Perpendicular:SVec2()
		Return New SVec2(-y, x)
	End Method
	
	Rem
	bbdoc: Returns the vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec2(n:SVec2)
		Return n * Dot(n) * 2.0 - Self
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Return x + ", " + y
	End Method

End Struct

Rem
bbdoc: A 3-element structure that can be used to represent positions and directions in 3D-space.
End Rem
Struct SVec3
	Field x:Float
	Field y:Float
	Field z:Float
	
	Rem
	bbdoc: Creates a new #SVec3 from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float, z:Float)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec3(b:SVec3)
		Return New SVec3(x + b.x, y + b.y, z + b.z)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec3(b:SVec3)
		Return New SVec3(x - b.x, y - b.y, z - b.z)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec3(b:SVec3)
		Return New SVec3(x * b.x, y * b.y, z * b.z)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec3(b:SVec3)
		Return New SVec3(x / b.x, y / b.y, z / b.z)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec3()
		Return New SVec3(-x, -y, -z)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning the new vector.
	End Rem
	Method Operator*:SVec3(s:Float)
		Return New SVec3(x * s, y * s, z * s)
	End Method

	Rem
	bbdoc: Retrieves the x, y or z component using [0], [1] or [2] respectively.
	End Rem
	Method Operator[]:Float(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
			Case 2
				Return z
		End Select
		
		Throw New TArrayBoundsException
	End Method

	Rem
	bbdoc: Sets the x, y or z component using [0], [1] or [2] respectively.
	End Rem
	Method Operator[]=(index:Int, value:Float)
		Select index
			Case 0
				x = value
			Case 1
				y = value
			Case 1
				z = value
			Default
				Throw New TArrayBoundsException
		End Select
	End Method
	
	Rem
	bbdoc: Applies the 3x3 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec3(b:SMat3 Var)
		Return New SVec3(x * b.a + y * b.d + z * b.g, x * b.b + y * b.e + z * b.h, x * b.c + y * b.f + z * b.i)
	End Method

	Rem
	bbdoc: Applies the 4x4 metrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec3(b:SMat4 Var)
		Local w:Float = b.d * x + b.h * y + b.l * z + b.p
		If w = 0 Then
			w = 1
		Else
			w = 1 / w
		End If
		Return New SVec3((b.a * x + b.e * y + b.i * z + b.m) * w, ..
			(b.b * x + b.f * y + b.j * z + b.n) * w, ..
			(b.c * x + b.g * y + b.k * z + b.o) * w)
	End Method
	
	Rem
	bbdoc: Returns the vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec3(minv:SVec3, maxv:SVec3)
		Return New SVec3(ClampF(x, minv.x, maxv.x), ClampF(y, minv.y, maxv.y), ClampF(z, minv.z, maxv.z))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec3(b:SVec3)
		Return New SVec3(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec3(b:SVec3)
		Return New SVec3(MinF(x, b.x), MinF(y, b.y), MinF(z, b.z))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec3(b:SVec3)
		Return New SVec3(MaxF(x, b.x), MaxF(y, b.y), MaxF(z, b.z))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Lerp:SVec3(b:SVec3, t:Float)
		Return New SVec3(LerpF(x, b.x, t), LerpF(y, b.y, t), LerpF(z, b.z, t))
	End Method
	
	Rem
	bbdoc: Returns the vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec3()
		Local length:Float = x * x + y * y + z * z
		If length > 0 Then
			length = Sqr(length)
			Return New SVec3(x / length, y / length, z / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Float(b:SVec3)
		Return x * b.x + y * b.y + z * b.z
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Float()
		Return Sqr(LengthSquared())
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Float()
		Return x * x + y * y + z * z
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method Distance:Float(b:SVec3)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceSquared:Float(b:SVec3)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns the vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec3(n:SVec3)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec3(b:SVec3)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z)
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A 2x2 Matrix
End Rem
Struct SMat2
	Field a:Float
	Field b:Float
	Field c:Float
	Field d:Float
	
	Rem
	bbdoc: Creates a new #SMat2 from the supplied arguments.
	End Rem
	Method New(a:Float, b:Float, c:Float, d:Float)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
	End Method
	
	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat2()
		Return New SMat2(1, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat2(z:SMat2)
		Return New SMat2(a + z.a, b + z.b, c + z.c, d + z.d)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat2(z:SMat2)
		Return New SMat2(a - z.a, b - z.b, c - z.c, d - z.d)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat2(z:SMat2)
		Return New SMat2(a * z.a + c * z.b, b * z.a + d * z.b, a * z.c + c * z.d, b * z.c + d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat2()
		Return New SMat2(d, -b, -c, a)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat2(z:SMat2)
		Return New SMat2(a * z.a, b * z.b, c * z.c, d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Det:Float()
		Return a * d - c * b
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat2()
		Local det:Float = a * d - c * b
		If det = 0 Then
			Return New SMat2(0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat2(d * det, -b * det, -c * det, a * det)
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning the rotated matrix.
	End Rem
	Method Rotate:SMat2(angle:Float)
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Return New SMat2(a * ca + c * sa, b * ca + d * sa, a * -sa + c * ca, b * -sa + d * ca)
	End Method
	
	Rem
	bbdoc: Creates a rotated matrix of @angle degrees.
	End Rem
	Function Rotation:SMat2(angle:Float)
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Return New SMat2(ca, sa, -sa, ca)
	End Function
	
	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2(s:SVec2)
		Return New SMat2(a * s.x, b * s.x, c * s.y, d * s.y)
	End Method
	
	Rem
	bbdoc: Creates a scaled matrix of the scale @s.
	End Rem
	Function Scaling:SMat2(s:SVec2)
		Return New SMat2(s.x, 0, 0, s.y)
	End Function
	
	Rem
	bbdoc: Returns the transpose of this matrix.
	End Rem
	Method Transpose:SMat2()
		Return New SMat2(a, c, b, d)
	End Method
	
	Rem
	bbdoc: Returns a #String representation of the matrix.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append(a).Append(", ").Append(c).Append(",~n")
		sb.Append(b).Append(", ").Append(d)
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: A 3x3 matrix.
End Rem
Struct SMat3
	Field a:Float
	Field b:Float
	Field c:Float
	Field d:Float
	Field e:Float
	Field f:Float
	Field g:Float
	Field h:Float
	Field i:Float

	Rem
	bbdoc: Creates a new #SMat3 from the supplied arguments.
	End Rem
	Method New(a:Float, b:Float, c:Float, d:Float, e:Float, f:Float, g:Float, h:Float, i:Float)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
		Self.e = e
		Self.f = f
		Self.g = g
		Self.h = h
		Self.i = i
	End Method
	
	Rem
	bbdoc: Return the 3x3 identity matrix.
	End Rem
	Function Identity:SMat3()
		Return New SMat3(1, 0, 0, 0, 1, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning the new matrix.
	End Rem
	Method Operator+:SMat3(z:SMat3 Var)
		Return New SMat3(a + z.a, b + z.b, c + z.c, d + z.d, e + z.e, f + z.f, g + z.g, h + z.h, i + z.i)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning the new matrix.
	End Rem
	Method Operator-:SMat3(z:SMat3 Var)
		Return New SMat3(a - z.a, b - z.b, c - z.c, d - z.d, e - z.e, f - z.f, g - z.g, h - z.h, i - z.i)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat3(z:SMat3 Var)
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a10:Float = d
		Local a11:Float = e
		Local a12:Float = f
		Local a20:Float = g
		Local a21:Float = h
		Local a22:Float = i
		Local b00:Float = z.a
		Local b01:Float = z.b
		Local b02:Float = z.c
		Local b10:Float = z.d
		Local b11:Float = z.e
		Local b12:Float = z.f
		Local b20:Float = z.g
		Local b21:Float = z.h
		Local b22:Float = z.i
		Return New SMat3(b00 * a00 + b01 * a10 + b02 * a20, ..
			b00 * a01 + b01 * a11 + b02 * a21, ..
			b00 * a02 + b01 * a12 + b02 * a22, ..
			b10 * a00 + b11 * a10 + b12 * a20, ..
			b10 * a01 + b11 * a11 + b12 * a21, ..
			b10 * a02 + b11 * a12 + b12 * a22, ..
			b20 * a00 + b21 * a10 + b22 * a20, ..
			b20 * a01 + b21 * a11 + b22 * a21, ..
			b20 * a02 + b21 * a12 + b22 * a22)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat3()
		Return New SMat3(e * i - f * h, ..
			c * h - b * i, ..
			b * f - c * e, ..
			f * g - d * i, ..
			a * i - c * g, ..
			c * d - a * f, ..
			d * h - e * g, ..
			b * g - a * h, ..
			a * e - b * d)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat3(z:SMat3 Var)
		Return New SMat3(a * z.a, b * z.b, c * z.c, d * z.d, e * z.e, f * z.f, g * z.g, h * z.h, i * z.i)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Det:Float()
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a10:Float = d
		Local a11:Float = e
		Local a12:Float = f
		Local a20:Float = g
		Local a21:Float = h
		Local a22:Float = i
		Return a00 * ( a22 * a11 - a12 * a21) + a01 * (-a22 * a10 + a12 * a20) + a02 * ( a21 * a10 - a11 * a20)
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat3()
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a10:Float = d
		Local a11:Float = e
		Local a12:Float = f
		Local a20:Float = g
		Local a21:Float = h
		Local a22:Float = i
		Local b01:Float =  a22 * a11 - a12 * a21
		Local b11:Float = -a22 * a10 + a12 * a20
		Local b21:Float =  a21 * a10 - a11 * a20
		Local det:Float = a00 * b01 + a01 * b11 + a02 * b21
		If det = 0 Then
			Return New SMat3(0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat3(b01 * det, ..
			(-a22 * a01 + a02 * a21) * det, ..
			( a12 * a01 - a02 * a11) * det,
			b11 * det, ..
			( a22 * a00 - a02 * a20) * det, ..
			(-a12 * a00 + a02 * a10) * det, ..
			b21 * det, ..
			(-a21 * a00 + a01 * a20) * det, ..
			( a11 * a00 - a01 * a10) * det)
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning a new matrix.
	End Rem
	Method Rotate:SMat3(angle:Float)
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Return New SMat3(ca * a + sa * d, ..
			ca * b + sa * e, ..
			ca * c + sa * f, ..
			ca * d - sa * a, ..
			ca * e - sa * b, ..
			ca * f - sa * c, ..
			g, h, i)
	End Method
	
	Rem
	bbdoc: Retrns a rotation matrix of @angle degrees.
	End Rem
	Function Rotation:SMat3(angle:Float)
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Return New SMat3(ca, sa, 0, -sa, ca, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3(s:SVec2)
		Local bx:Float = s.x
		Local by:Float = s.y
		Return New SMat3(a * bx, b * bx, c * bx, d * by, e * by, f * by, g, h, i)
	End Method
	
	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3(s:SVec2)
		Return New SMat3(s.x, 0, 0, 0, s.y, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Returns a transposition of the matrix.
	End Rem
	Method Transpose:SMat3()
		Return New SMat3(a, d, g, b, e, h, c, f, i)
	End Method
	
	Rem
	bbdoc: Applies the quaternion @a to the matrix, returning a new matrix.
	End Rem
	Method Quat:SMat3(a:SQuat)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.z
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local ayx:Float = ay * ax2
		Local ayy:Float = ay * ay2
		Local azx:Float = az * ax2
		Local azy:Float = az * ay2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat3(1 - ayy - azz, ayx + awz, azx - awy, ayx - awz, 1.0 - axx - azz, azy + awx, azx + awy, azy - awx, 1.0 - axx - ayy)
	End Method

	Rem
	bbdoc: Returns a #String representation of the matrix.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append(a).Append(", ").Append(d).Append(", ").Append(g).Append(",~n")
		sb.Append(b).Append(", ").Append(e).Append(", ").Append(h).Append(",~n")
		sb.Append(c).Append(", ").Append(f).Append(", ").Append(i)
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A standard 4x4 transformation matrix.
End Rem
Struct SMat4
	Field a:Float
	Field b:Float
	Field c:Float
	Field d:Float
	Field e:Float
	Field f:Float
	Field g:Float
	Field h:Float
	Field i:Float
	Field j:Float
	Field k:Float
	Field l:Float
	Field m:Float
	Field n:Float
	Field o:Float
	Field p:Float

	Rem
	bbdoc: Creates a new #SMat4 from the supplied arguments.
	End Rem
	Method New(a:Float, b:Float, c:Float, d:Float, e:Float, f:Float, g:Float, h:Float, i:Float, j:Float, k:Float, l:Float, m:Float, n:Float, o:Float, p:Float)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
		Self.e = e
		Self.f = f
		Self.g = g
		Self.h = h
		Self.i = i
		Self.j = j
		Self.k = k
		Self.l = l
		Self.m = m
		Self.n = n
		Self.o = o
		Self.p = p
	End Method
	
	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat4()
		Return New SMat4(1, 0, 0, 0, ..
				0, 1, 0, 0, ..
				0, 0, 1, 0, ..
				0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat4(z:SMat4 Var)
		Return New SMat4(a + z.a, b + z.b, c + z.c, d + z.d, ..
			e + z.e, f + z.f, g + z.g, h + z.h, ..
			i + z.i, j + z.j, k + z.k, l + z.l, ..
			m + z.m, n + z.n, o + z.o, p + z.p)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat4(z:SMat4 Var)
		Return New SMat4(a - z.a, b - z.b, c - z.c, d - z.d, ..
			e - z.e, f - z.f, g - z.g, h - z.h, ..
			i - z.i, j - z.j, k - z.k, l - z.l, ..
			m - z.m, n - z.n, o - z.o, p - z.p)
	End Method

	Rem
	bbdoc: Multiplies the matrix by @z, returnin a new matrix. 
	End Rem
	Method Operator*:SMat4(z:SMat4 Var)
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a03:Float = d
		Local a10:Float = e
		Local a11:Float = f
		Local a12:Float = g
		Local a13:Float = h
		Local a20:Float = i
		Local a21:Float = j
		Local a22:Float = k
		Local a23:Float = l
		Local a30:Float = m
		Local a31:Float = n
		Local a32:Float = o
		Local a33:Float = p
		Local b00:Float = z.a
		Local b01:Float = z.b
		Local b02:Float = z.c
		Local b03:Float = z.d
		Local b10:Float = z.e
		Local b11:Float = z.f
		Local b12:Float = z.g
		Local b13:Float = z.h
		Local b20:Float = z.i
		Local b21:Float = z.j
		Local b22:Float = z.k
		Local b23:Float = z.l
		Local b30:Float = z.m
		Local b31:Float = z.n
		Local b32:Float = z.o
		Local b33:Float = z.p
		Return New SMat4(b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30, ..
			b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31, ..
			b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32, ..
			b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33, ..
			b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30, ..
			b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31, ..
			b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32, ..
			b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33, ..
			b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30, ..
			b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31, ..
			b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32, ..
			b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33, ..
			b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30, ..
			b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31, ..
			b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32, ..
			b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat4()
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a03:Float = d
		Local a10:Float = e
		Local a11:Float = f
		Local a12:Float = g
		Local a13:Float = h
		Local a20:Float = i
		Local a21:Float = j
		Local a22:Float = k
		Local a23:Float = l
		Local a30:Float = m
		Local a31:Float = n
		Local a32:Float = o
		Local a33:Float = p
		Return New SMat4(a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22), ..
			-(a01 * (a22 * a33 - a23 * a32) - a21 * (a02 * a33 - a03 * a32) + a31 * (a02 * a23 - a03 * a22)), ..
			a01 * (a12 * a33 - a13 * a32) - a11 * (a02 * a33 - a03 * a32) + a31 * (a02 * a13 - a03 * a12), ..
			-(a01 * (a12 * a23 - a13 * a22) - a11 * (a02 * a23 - a03 * a22) + a21 * (a02 * a13 - a03 * a12)), ..
			-(a10 * (a22 * a33 - a23 * a32) - a20 * (a12 * a33 - a13 * a32) + a30 * (a12 * a23 - a13 * a22)), ..
			a00 * (a22 * a33 - a23 * a32) - a20 * (a02 * a33 - a03 * a32) + a30 * (a02 * a23 - a03 * a22), ..
			-(a00 * (a12 * a33 - a13 * a32) - a10 * (a02 * a33 - a03 * a32) + a30 * (a02 * a13 - a03 * a12)), ..
			a00 * (a12 * a23 - a13 * a22) - a10 * (a02 * a23 - a03 * a22) + a20 * (a02 * a13 - a03 * a12), ..
			a10 * (a21 * a33 - a23 * a31) - a20 * (a11 * a33 - a13 * a31) + a30 * (a11 * a23 - a13 * a21), ..
			-(a00 * (a21 * a33 - a23 * a31) - a20 * (a01 * a33 - a03 * a31) + a30 * (a01 * a23 - a03 * a21)), ..
			a00 * (a11 * a33 - a13 * a31) - a10 * (a01 * a33 - a03 * a31) + a30 * (a01 * a13 - a03 * a11), ..
			-(a00 * (a11 * a23 - a13 * a21) - a10 * (a01 * a23 - a03 * a21) + a20 * (a01 * a13 - a03 * a11)), ..
			-(a10 * (a21 * a32 - a22 * a31) - a20 * (a11 * a32 - a12 * a31) + a30 * (a11 * a22 - a12 * a21)), ..
			a00 * (a21 * a32 - a22 * a31) - a20 * (a01 * a32 - a02 * a31) + a30 * (a01 * a22 - a02 * a21), ..
			-(a00 * (a11 * a32 - a12 * a31) - a10 * (a01 * a32 - a02 * a31) + a30 * (a01 * a12 - a02 * a11)), ..
			a00 * (a11 * a22 - a12 * a21) - a10 * (a01 * a22 - a02 * a21) + a20 * (a01 * a12 - a02 * a11))
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat4(z:SMat4 Var)
		Return New SMat4(a * z.a, b * z.b, c * z.c, d * z.d, ..
			e * z.e, f * z.f, g * z.g, h * z.h, ..
			i * z.i, j * z.j, k * z.k, l * z.l, ..
			m * z.m, n * z.n, o * z.o, p * z.p)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Det:Float()
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a03:Float = d
		Local a10:Float = e
		Local a11:Float = f
		Local a12:Float = g
		Local a13:Float = h
		Local a20:Float = i
		Local a21:Float = j
		Local a22:Float = k
		Local a23:Float = l
		Local a30:Float = m
		Local a31:Float = n
		Local a32:Float = o
		Local a33:Float = p
		Local b00:Float = a00 * a11 - a01 * a10
		Local b01:Float = a00 * a12 - a02 * a10
		Local b02:Float = a00 * a13 - a03 * a10
		Local b03:Float = a01 * a12 - a02 * a11
		Local b04:Float = a01 * a13 - a03 * a11
		Local b05:Float = a02 * a13 - a03 * a12
		Local b06:Float = a20 * a31 - a21 * a30
		Local b07:Float = a20 * a32 - a22 * a30
		Local b08:Float = a20 * a33 - a23 * a30
		Local b09:Float = a21 * a32 - a22 * a31
		Local b10:Float = a21 * a33 - a23 * a31
		Local b11:Float = a22 * a33 - a23 * a32
		Return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
	End Method

	Rem
	bbdoc: Returns a projection matrix with a viewing frustum defined by the plane coordinates passed in.
	End Rem
	Function Frustum:SMat4(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float)
		Local rl:Float = 1.0 / (r - l)
		Local tb:Float = 1.0 / (t - b)
		Local nf:Float = 1.0 / (n - f)
		Return New SMat4((2.0 * n) * rl, 0, 0, 0, ..
			0, (2.0 * n) * tb, 0, 0, ..
			(r + l) * rl, (t + b) * tb, (f + n) * nf, -1, ..
			0, 0, (2.0 * n * f) * nf, 0)
	End Function
	
	Rem
	bbdoc: The inverse of this matrix.
	about: An inverted matrix is such that if multiplied by the original would result in identity matrix.
	If some matrix transforms vectors in a particular way, then the inverse matrix can transform them back.
	End Rem
	Method Invert:SMat4()
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a03:Float = d
		Local a10:Float = e
		Local a11:Float = f
		Local a12:Float = g
		Local a13:Float = h
		Local a20:Float = i
		Local a21:Float = j
		Local a22:Float = k
		Local a23:Float = l
		Local a30:Float = m
		Local a31:Float = n
		Local a32:Float = o
		Local a33:Float = p
		Local b00:Float = a00 * a11 - a01 * a10
		Local b01:Float = a00 * a12 - a02 * a10
		Local b02:Float = a00 * a13 - a03 * a10
		Local b03:Float = a01 * a12 - a02 * a11
		Local b04:Float = a01 * a13 - a03 * a11
		Local b05:Float = a02 * a13 - a03 * a12
		Local b06:Float = a20 * a31 - a21 * a30
		Local b07:Float = a20 * a32 - a22 * a30
		Local b08:Float = a20 * a33 - a23 * a30
		Local b09:Float = a21 * a32 - a22 * a31
		Local b10:Float = a21 * a33 - a23 * a31
		Local b11:Float = a22 * a33 - a23 * a32
		Local det:Float = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
		If det = 0 Then
			Return New SMat4(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat4((a11 * b11 - a12 * b10 + a13 * b09) * det, ..
			(a02 * b10 - a01 * b11 - a03 * b09) * det, ..
			(a31 * b05 - a32 * b04 + a33 * b03) * det, ..
			(a22 * b04 - a21 * b05 - a23 * b03) * det, ..
			(a12 * b08 - a10 * b11 - a13 * b07) * det, ..
			(a00 * b11 - a02 * b08 + a03 * b07) * det, ..
			(a32 * b02 - a30 * b05 - a33 * b01) * det, ..
			(a20 * b05 - a22 * b02 + a23 * b01) * det, ..
			(a10 * b10 - a11 * b08 + a13 * b06) * det, ..
			(a01 * b08 - a00 * b10 - a03 * b06) * det, ..
			(a30 * b04 - a31 * b02 + a33 * b00) * det, ..
			(a21 * b02 - a20 * b04 - a23 * b00) * det, ..
			(a11 * b07 - a10 * b09 - a12 * b06) * det, ..
			(a00 * b09 - a01 * b07 + a02 * b06) * det, ..
			(a31 * b01 - a30 * b03 - a32 * b00) * det, ..
			(a20 * b03 - a21 * b01 + a22 * b00) * det)
	End Method
	
	Rem
	bbdoc: Computes a transformation matrix that corresponds to a camera viewing the @eye from the @pos.
	about: The right-hand vector is perpendicular to the up vector.
	End Rem
	Function LookAt:SMat4(eye:SVec3, pos:SVec3, up:SVec3)
		Local ex:Float = eye.x
		Local ey:Float = eye.y
		Local ez:Float = eye.z
		Local px:Float = pos.x
		Local py:Float = pos.y
		Local pz:Float = pos.z
		Local ux:Float = up.x
		Local uy:Float = up.y
		Local uz:Float = up.z
		Local z0:Float = ex - px
		Local z1:Float = ey - py
		Local z2:Float = ez - pz
		
		If z0 = 0 Or z1 = 0 Or z2 = 0 Then
			Return Identity()
		End If
		
		Local length:Float = Sqr(z0 * z0 + z1 * z1 + z2 * z2)
		z0 :* length
		z1 :* length
		z2 :* length
		
		Local x0:Float = uy * z2 - uz * z1
		Local x1:Float = uz * z0 - ux * z2
		Local x2:Float = ux * z1 - uy * z0
		
		length = Sqr(x0 * x0 + x1 * x1 + x2 * x2)
		
		If length = 0 Then
			x0 = 0
			x1 = 0
			x2 = 0
		Else
			length = 1 / length
			x0 :* length
			x1 :* length
			x2 :* length
		End If
		
		Local y0:Float = z1 * x2 - z2 * x1
		Local y1:Float = z2 * x0 - z0 * x2
		Local y2:Float = z0 * x1 - z1 * x0
		
		length = Sqr(y0 * y0 + y1 * y1 + y2 * y2)
		If length = 0 Then
			y0 = 0
			y1 = 0
			y2 = 0
		Else
			length = 1 / length
			y0 :* length
			y1 :* length
			y2 :* length
		End If
		
		Return New SMat4(x0, y0, z0, 0, x1, y1, z1, 0, x2, y2, z2, 0, ..
			-(x0 * ex + x1 * ey + x2 * ez), -(y0 * ex + y1 * ey + y2 * ez), -(z0 * ex + z1 * ey + z2 * ez), 1)
	End Function
	
	Rem
	bbdoc: Creates an orthogonal projection matrix.
	about: The returned matrix, when used as a Camera's projection matrix, creates a view showing the area between @width and @height, with @zNear and @zFar as the near and far depth clipping planes.
	End Rem
	Function Orthogonal:SMat4(width:Float, height:Float, zNear:Float, zFar:Float)
		Local nf:Float = 1.0 / (zNear - zFar)
		Return New SMat4(2.0 / width, 0, 0, 0, ..
			0, 2.0 / height, 0, 0, ..
			0, 0, 2.0 * nf, 0, ..
			0, 0, (zNear + zFar) * nf, 1)
	End Function
	
	Rem
	bbdoc: Creates a perspective projection matrix.
	End Rem
	Function Perspective:SMat4(fov:Float, w:Float, h:Float, n:Float, f:Float)
		Local ft:Float = 1.0 / Tan(fov * 0.5)
		Local nf:Float = 1.0 / (n - f)
		Return New SMat4(ft, 0, 0, 0, ..
			0, ft * w / h, 0, 0, ..
			0, 0, (f + n) * nf, -1, ..
			0, 0, (2.0 * f * n) * nf, 0) 
	End Function
	
	Rem
	bbdoc: Creates a rotation matrix, rotated @angle degrees around the point @axis.
	End Rem
	Method Rotate:SMat4(axis:SVec3, angle:Float)
		Local x:Float = axis.x
		Local y:Float = axis.y
		Local z:Float = axis.z
		Local a00:Float = a
		Local a01:Float = b
		Local a02:Float = c
		Local a03:Float = d
		Local a10:Float = e
		Local a11:Float = f
		Local a12:Float = g
		Local a13:Float = h
		Local a20:Float = i
		Local a21:Float = j
		Local a22:Float = k
		Local a23:Float = l
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Local t:Float = 1 - ca
		Local b00:Float = x * x * t + ca
		Local b01:Float = y * x * t + z * sa
		Local b02:Float = z * x * t - y * sa
		Local b10:Float = x * y * t - z * sa
		Local b11:Float = y * y * t + ca
		Local b12:Float = z * y * t + x * sa
		Local b20:Float = x * z * t + y * sa
		Local b21:Float = y * z * t - x * sa
		Local b22:Float = z * z * t + ca
		Return New SMat4(a00 * b00 + a10 * b01 + a20 * b02, ..
			a01 * b00 + a11 * b01 + a21 * b02, ..
			a02 * b00 + a12 * b01 + a22 * b02, ..
			a03 * b00 + a13 * b01 + a23 * b02, ..
			a00 * b10 + a10 * b11 + a20 * b12, ..
			a01 * b10 + a11 * b11 + a21 * b12, ..
			a02 * b10 + a12 * b11 + a22 * b12, ..
			a03 * b10 + a13 * b11 + a23 * b12, ..
			a00 * b20 + a10 * b21 + a20 * b22, ..
			a01 * b20 + a11 * b21 + a21 * b22, ..
			a02 * b20 + a12 * b21 + a22 * b22, ..
			a03 * b20 + a13 * b21 + a23 * b22, ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Returns a rotation matrix on the given @axis and @angle degrees.
	End Rem
	Function Rotation:SMat4(axis:SVec3, angle:Float)
		Local x:Float = axis.x
		Local y:Float = axis.y
		Local z:Float = axis.z
		Local sa:Float = Sin(angle)
		Local ca:Float = Cos(angle)
		Local t:Float = 1 - ca
		Return New SMat4(x * x * t + ca, ..
			y * x * t + z * sa, ..
			z * x * t - y * sa, ..
			0, ..
			x * y * t - z * sa, ..
			y * y * t + ca, ..
			z * y * t + x * sa, ..
			0, ..
			x * z * t + y * sa, ..
			y * z * t - x * sa, ..
			z * z * t + ca, ..
			0, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Creates a translation and rotation matrix.
	about: The returned matrix is such that it places objects at position @s, oriented in rotation @a.
	End Rem
	Function RotTrans:SMat4(a:SQuat, s:SVec3)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.x
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local axy:Float = ax * ay2
		Local axz:Float = ax * az2
		Local ayy:Float = ay * ay2
		Local ayz:Float = ay * az2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat4(1.0 - ayy - azz, axy + awz, axz - awy, 0, ..
			axy - awz, 1.0 - axx - azz, ayz + awx, 0, ..
			axz + awy, ayz - awx, 1.0 - axx - ayy, 0, ..
			s.x, s.y, s.z, 1)
	End Function
	
	Rem
	bbdoc: Creates a translation, rotation and scaling matrix.
	about: The returned matrix is such that it places objects at position @origin, oriented in rotation @a and scaled by @s.
	End Rem
	Function RotTransOrigin:SMat4(a:SQuat, s:SVec3, origin:SVec3)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.x
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local axy:Float = ax * ay2
		Local axz:Float = ax * az2
		Local ayy:Float = ay * ay2
		Local ayz:Float = ay * az2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Local ox:Float = origin.x
		Local oy:Float = origin.y
		Local oz:Float = origin.z
		Local o00:Float = 1.0 - ayy - azz
		Local o01:Float = axy + awz
		Local o02:Float = axz - awy
		Local o10:Float = axy - awz
		Local o11:Float = 1.0 - axx - azz
		Local o12:Float = ayz + awx
		Local o20:Float = axz + awy
		Local o21:Float = ayz - awx
		Local o22:Float = 1.0 - axx - ayy
		Return New SMat4(o00, o01, o02, 0, ..
			o10, o11, o12, 0, ..
			o20, o21, o22, 0, ..
			s.x + ox - (o00 * ox + o10 * oy + o20 * oz), ..
			s.y + oy - (o01 * ox + o11 * oy + o21 * oz), ..
			s.z + oz - (o02 * ox + o12 * oy + o22 * oz), 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4(s:SVec3)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4(a * bx, b * bx, c * bx, d * bx, ..
			e * by, f * by, g * by, h * by, ..
			i * bz, j * bz, k * bz, l * bz, ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4(s:SVec3)
		Return New SMat4(s.x, 0, 0, 0, 0, s.y, 0, 0, 0, 0, s.z, 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns the transpose of this matrix
	about: The transposed matrix is the one that has the columns exchanged with its rows.
	End Rem
	Method Transpose:SMat4()
		Return New SMat4(a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p)
	End Method
	
	Rem
	bbdoc: Translates the matrix to @s.
	End Rem
	Method Translate:SMat4(s:SVec3)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4(a, b, c, d, e, f, g, h, i, j, k, l, ..
			a * bx + e * by + i * bz + m, ..
			b * bx + f * by + j * bz + n, ..
			c * bx + g * by + k * bz + o, ..
			d * bx + h * by + l * bz + p)
	End Method

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4(s:SVec3)
		Return New SMat4(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			s.x, s.y, s.z, 1)
	End Function
	
	Rem
	bbdoc: Applies the quaternian to the matrix, return the new matrix.
	End Rem
	Function Quat:SMat4(a:SQuat)
		Local ax:Float = a.x
		Local ay:Float = a.y
		Local az:Float = a.z
		Local aw:Float = a.w
		Local ax2:Float = ax + ax
		Local ay2:Float = ay + ay
		Local az2:Float = az + az
		Local axx:Float = ax * ax2
		Local ayx:Float = ay * ax2
		Local ayy:Float = ay * ay2
		Local azx:Float = az * ax2
		Local azy:Float = az * ay2
		Local azz:Float = az * az2
		Local awx:Float = aw * ax2
		Local awy:Float = aw * ay2
		Local awz:Float = aw * az2
		Return New SMat4(1.0 - ayy - azz, ayx + awz, azx - awy, 0, ..
			ayx - awz, 1.0 - axx - azz, azy + awx, 0, ..
			azx + awy, azy - awx, 1.0 - axx - ayy, 0, ..
			0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Returns a #String representation of the matrix.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append(a).Append(", ").Append(e).Append(", ").Append(i).Append(", ").Append(m).Append(",~n")
		sb.Append(b).Append(", ").Append(f).Append(", ").Append(j).Append(", ").Append(n).Append(",~n")
		sb.Append(c).Append(", ").Append(g).Append(", ").Append(k).Append(", ").Append(o).Append(",~n")
		sb.Append(d).Append(", ").Append(h).Append(", ").Append(l).Append(", ").Append(p)
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A Quaternion.
about: Quaternions are used to represent rotations.
They are compact, don't suffer from gimbal lock and can easily be interpolated.
End Rem
Struct SQuat
	Field x:Float
	Field y:Float
	Field z:Float
	Field w:Float
	
	Rem
	bbdoc: Creates a new #SQuat from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float, z:Float, w:Float)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method
	
	Rem
	bbdoc: The dot product between two rotations.
	End Rem
	Method Dot:Float(b:SQuat)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the Inverse of rotation.
	End Rem
	Method Invert:SQuat()
		Local dot:Float = x * x + y * y + z * z + w * w
		Local invdot:Float
		If dot <> 0 Then
			invdot = 1 / dot
		End If
		Return New SQuat(-x * invdot, -y * invdot, -z * invdot, w * invdot)
	End Method
	
	Rem
	bbdoc: Interpolates between the SQuat and @b by @t and normalizes the result afterwards.
	End Rem
	Method Lerp:SQuat(b:SQuat, t:Float)
		Return New SQuat(LerpF(x, b.x, t), LerpF(y, b.y, t), LerpF(z, b.z, t), LerpF(w, b.w, t))
	End Method
	
	Rem
	bbdoc: Multiplies the quaternion by @b, returning a new quaternion.
	End Rem
	Method Operator*:SQuat(b:SQuat)
		Return New SQuat(x * b.w + w * b.x + y * b.z - z * b.y, ..
			y * b.w + w * b.y + z * b.x - x * b.z, ..
			z * b.w + w * b.z + x * b.y - y * b.x, ..
			w * b.w - x * b.x - y * b.y - z * b.z)
	End Method
	
	Rem
	bbdoc: Returns the quaternion, negated.
	End Rem
	Method Operator-:SQuat()
		Return New SQuat(-x, -y, -z, -w)
	End Method
	
	Rem
	bbdoc: The identity rotation.
	End Rem
	Function Identity:SQuat()
		Return New SQuat(0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Converts this quaternion to one with the same orientation but with a magnitude of 1.
	End Rem
	Method Normal:SQuat()
		Local length:Float = x * x + y * y + z * z + w * w
		If length > 0 Then
			length = Sqr(length)
			Return New SQuat(x * length, y * length, z * length, w * length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Spherically interpolates between this SQuat and @b by @t.
	End Rem
	Method Slerp:SQuat(b:SQuat, t:Float)
		Local bx:Float = b.x
		Local by:Float = b.y
		Local bz:Float = b.z
		Local bw:Float = b.w
		Local scale0:Float
		Local scale1:Float

		Local cosom:Float = x * bx + y * by + z * bz + w * bw

		If cosom < 0 Then
			cosom = -cosom
			bx = -bx
			by = -by
			bz = -bz
			bw = -bw
		End If
		
		If 1 - cosom > 0.000001 Then
			Local omega:Float = _acos(cosom)
			Local sinom:Float = _sin(omega)
			scale0 = _sin((1.0 - t) * omega) / sinom
			scale1 = _sin(t * omega) / sinom
		Else
			scale0 = 1 - t
			scale1 = t
		End If
		
		Return New SQuat(scale0 * x + scale1 * bx, scale0 * y + scale1 * by, scale0 * z + scale1 * bz, scale0 * w + scale1 * bw)
	End Method
	
	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerXYZ:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz + cx * sy * sz, ..
			cx * sy * cz - sx * cy * sz, ..
			cx * cy * sz + sx * sy * cz, ..
			cx * cy * cz - sx * sy * sz)
	End Method
	
	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerXZY:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz - cx * sy * sz, ..
			cx * sy * cz - sx * cy * sz, ..
			cx * cy * sz + sx * sy * cz, ..
			cx * cy * cz + sx * sy * sz)
	End Method

	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerYXZ:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz + cx * sy * sz, ..
			cx * sy * cz - sx * cy * sz, ..
			cx * cy * sz - sx * sy * cz, ..
			cx * cy * cz + sx * sy * sz)
	End Method

	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerYZX:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz + cx * sy * sz, ..
			cx * sy * cz + sx * cy * sz, ..
			cx * cy * sz - sx * sy * cz, ..
			cx * cy * cz - sx * sy * sz)
	End Method

	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerZXY:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz - cx * sy * sz, ..
			cx * sy * cz + sx * cy * sz, ..
			cx * cy * sz + sx * sy * cz, ..
			cx * cy * cz - sx * sy * sz)
	End Method

	Rem
	bbdoc: Returns a rotation that rotates around @rot.
	End Rem
	Method EulerZYX:SQuat(rot:SVec3)
		Local cx:Float = Cos(rot.x)
		Local cy:Float = Cos(rot.y)
		Local cz:Float = Cos(rot.z)
		Local sx:Float = Sin(rot.x)
		Local sy:Float = Sin(rot.y)
		Local sz:Float = Sin(rot.z)
		Return New SQuat(sx * cy * cz - cx * sy * sz, ..
			cx * sy * cz + sx * cy * sz, ..
			cx * cy * sz - sx * sy * cz, ..
			cx * cy * cz + sx * sy * sz)
	End Method
	
End Struct

Private
Function MinF:Float(a:Float, b:Float)
	If b < a Then
		Return b
	End If
	Return a
End Function

Function MaxF:Float(a:Float, b:Float)
	If b > a Then
		Return b
	End If
	Return a
End Function

Function LerpF:Float(a:Float, b:Float, t:Float)
	Return a + (b - a) * t
End Function

Function ClampF:Float(a:Float, minf:Float, maxf:Float)
	If a < minf Then
		Return minf
	Else If a > maxf Then
		Return maxf
	End If
	Return a
End Function

Extern
	Function _acos:Double(x:Double)="double acos(double)!"
	Function _sin:Double(x:Double)="double sin(double)!"
End Extern
Public
