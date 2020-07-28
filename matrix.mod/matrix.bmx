' Copyright (c) 2019-2020 Bruce A Henderson
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
bbdoc: Math/Matrix
End Rem
Module BRL.Matrix

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2019-2020 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Math
Import BRL.Vector
Import BRL.StringBuilder

Rem
bbdoc: A 2x2 Matrix
End Rem
Struct SMat2D
	Field ReadOnly a:Double
	Field ReadOnly b:Double
	Field ReadOnly c:Double
	Field ReadOnly d:Double
	
	Rem
	bbdoc: Creates a new #SMat2D from the supplied arguments.
	End Rem
	Method New(a:Double, b:Double, c:Double, d:Double)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
	End Method
	
	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2D(v:SVec2D)
		Return New SVec2D(a * v.x + c * v.y, b * v.x + d * v.y)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat2D()
		Return New SMat2D(1, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat2D(z:SMat2D)
		Return New SMat2D(a + z.a, b + z.b, c + z.c, d + z.d)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat2D(z:SMat2D)
		Return New SMat2D(a - z.a, b - z.b, c - z.c, d - z.d)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat2D(z:SMat2D)
		Return New SMat2D(a * z.a + c * z.b, b * z.a + d * z.b, a * z.c + c * z.d, b * z.c + d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat2D()
		Return New SMat2D(d, -b, -c, a)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat2D(z:SMat2D)
		Return New SMat2D(a * z.a, b * z.b, c * z.c, d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Double()
		Return a * d - c * b
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat2D()
		Local det:Double = a * d - c * b
		If det = 0 Then
			Return New SMat2D(0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat2D(d * det, -b * det, -c * det, a * det)
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning the rotated matrix.
	End Rem
	Method Rotate:SMat2D(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2D(a * ca + c * sa, b * ca + d * sa, a * -sa + c * ca, b * -sa + d * ca)
	End Method
	
	Rem
	bbdoc: Creates a rotated matrix of @angle degrees.
	End Rem
	Function Rotation:SMat2D(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2D(ca, sa, -sa, ca)
	End Function
	
	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2D(s:SVec2D)
		Return New SMat2D(a * s.x, b * s.x, c * s.y, d * s.y)
	End Method
	
	Rem
	bbdoc: Creates a scaled matrix of the scale @s.
	End Rem
	Function Scaling:SMat2D(s:SVec2D)
		Return New SMat2D(s.x, 0, 0, s.y)
	End Function
	
	Rem
	bbdoc: Returns the transpose of this matrix.
	End Rem
	Method Transpose:SMat2D()
		Return New SMat2D(a, c, b, d)
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
Struct SMat3D
	Field ReadOnly a:Double
	Field ReadOnly b:Double
	Field ReadOnly c:Double
	Field ReadOnly d:Double
	Field ReadOnly e:Double
	Field ReadOnly f:Double
	Field ReadOnly g:Double
	Field ReadOnly h:Double
	Field ReadOnly i:Double

	Rem
	bbdoc: Creates a new #SMat3D from the supplied arguments.
	End Rem
	Method New(a:Double, b:Double, c:Double, d:Double, e:Double, f:Double, g:Double, h:Double, i:Double)
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2D(v:SVec2D)
		Return New SVec2D(a * v.x + d * v.y + g, b * v.x + e * v.y + h)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec3D(v:SVec3D)
		Return New SVec3D(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec4D(v:SVec4D)
		Return New SVec4D(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i, 0)
	End Method

	Rem
	bbdoc: Return the 3x3 identity matrix.
	End Rem
	Function Identity:SMat3D()
		Return New SMat3D(1, 0, 0, 0, 1, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat3D(z:SMat3D Var)
		Return New SMat3D(a + z.a, b + z.b, c + z.c, d + z.d, e + z.e, f + z.f, g + z.g, h + z.h, i + z.i)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat3D(z:SMat3D Var)
		Return New SMat3D(a - z.a, b - z.b, c - z.c, d - z.d, e - z.e, f - z.f, g - z.g, h - z.h, i - z.i)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat3D(z:SMat3D Var)
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a10:Double = d
		Local a11:Double = e
		Local a12:Double = f
		Local a20:Double = g
		Local a21:Double = h
		Local a22:Double = i
		Local b00:Double = z.a
		Local b01:Double = z.b
		Local b02:Double = z.c
		Local b10:Double = z.d
		Local b11:Double = z.e
		Local b12:Double = z.f
		Local b20:Double = z.g
		Local b21:Double = z.h
		Local b22:Double = z.i
		Return New SMat3D(b00 * a00 + b01 * a10 + b02 * a20, ..
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
	Method Adjoint:SMat3D()
		Return New SMat3D(e * i - f * h, ..
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
	Method CompMul:SMat3D(z:SMat3D Var)
		Return New SMat3D(a * z.a, b * z.b, c * z.c, d * z.d, e * z.e, f * z.f, g * z.g, h * z.h, i * z.i)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Double()
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a10:Double = d
		Local a11:Double = e
		Local a12:Double = f
		Local a20:Double = g
		Local a21:Double = h
		Local a22:Double = i
		Return a00 * ( a22 * a11 - a12 * a21) + a01 * (-a22 * a10 + a12 * a20) + a02 * ( a21 * a10 - a11 * a20)
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat3D()
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a10:Double = d
		Local a11:Double = e
		Local a12:Double = f
		Local a20:Double = g
		Local a21:Double = h
		Local a22:Double = i
		Local b01:Double =  a22 * a11 - a12 * a21
		Local b11:Double = -a22 * a10 + a12 * a20
		Local b21:Double =  a21 * a10 - a11 * a20
		Local det:Double = a00 * b01 + a01 * b11 + a02 * b21
		If det = 0 Then
			Return New SMat3D(0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat3D(b01 * det, ..
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
	Method Rotate:SMat3D(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3D(ca * a + sa * d, ..
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
	Function Rotation:SMat3D(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3D(ca, sa, 0, -sa, ca, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3D(s:SVec2D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Return New SMat3D(a * bx, b * bx, c * bx, d * by, e * by, f * by, g, h, i)
	End Method
	
	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3D(s:SVec2D)
		Return New SMat3D(s.x, 0, 0, 0, s.y, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Returns a transposition of the matrix.
	End Rem
	Method Transpose:SMat3D()
		Return New SMat3D(a, d, g, b, e, h, c, f, i)
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
Struct SMat4D
	Field ReadOnly a:Double
	Field ReadOnly b:Double
	Field ReadOnly c:Double
	Field ReadOnly d:Double
	Field ReadOnly e:Double
	Field ReadOnly f:Double
	Field ReadOnly g:Double
	Field ReadOnly h:Double
	Field ReadOnly i:Double
	Field ReadOnly j:Double
	Field ReadOnly k:Double
	Field ReadOnly l:Double
	Field ReadOnly m:Double
	Field ReadOnly n:Double
	Field ReadOnly o:Double
	Field ReadOnly p:Double

	Rem
	bbdoc: Creates a new #SMat4D from the supplied arguments.
	End Rem
	Method New(a:Double, b:Double, c:Double, d:Double, e:Double, f:Double, g:Double, h:Double, i:Double, j:Double, k:Double, l:Double, m:Double, n:Double, o:Double, p:Double)
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2D(v:SVec2D)
		Return New SVec2D(a * v.x + e * v.y + m, b * v.x + f * v.y + n)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec3D(v:SVec3D)
		Local w:Double = d * v.x + h * v.y + l * v.z + p
		If w = 0 Then
			w = 1
		Else
			w = 1 / w
		End If
		Return New SVec3D((a * v.x + e * v.y + i * v.z + m) * w, ..
			(b * v.x + f * v.y + j * v.z + n) * w, ..
			(c * v.x + g * v.y + k * v.z + o) * w)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec4D(v:SVec4D)
		Return New SVec4D(a * v.x + e * v.y + i * v.z + m * v.w, ..
			b * v.x + f * v.y + j * v.z + n * v.w, ..
			c * v.x + g * v.y + k * v.z + o * v.w, ..
			d * v.x + h * v.y + l * v.z + p * v.w)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat4D()
		Return New SMat4D(1, 0, 0, 0, ..
				0, 1, 0, 0, ..
				0, 0, 1, 0, ..
				0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat4D(z:SMat4D Var)
		Return New SMat4D(a + z.a, b + z.b, c + z.c, d + z.d, ..
			e + z.e, f + z.f, g + z.g, h + z.h, ..
			i + z.i, j + z.j, k + z.k, l + z.l, ..
			m + z.m, n + z.n, o + z.o, p + z.p)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat4D(z:SMat4D Var)
		Return New SMat4D(a - z.a, b - z.b, c - z.c, d - z.d, ..
			e - z.e, f - z.f, g - z.g, h - z.h, ..
			i - z.i, j - z.j, k - z.k, l - z.l, ..
			m - z.m, n - z.n, o - z.o, p - z.p)
	End Method

	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix. 
	End Rem
	Method Operator*:SMat4D(z:SMat4D Var)
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a03:Double = d
		Local a10:Double = e
		Local a11:Double = f
		Local a12:Double = g
		Local a13:Double = h
		Local a20:Double = i
		Local a21:Double = j
		Local a22:Double = k
		Local a23:Double = l
		Local a30:Double = m
		Local a31:Double = n
		Local a32:Double = o
		Local a33:Double = p
		Local b00:Double = z.a
		Local b01:Double = z.b
		Local b02:Double = z.c
		Local b03:Double = z.d
		Local b10:Double = z.e
		Local b11:Double = z.f
		Local b12:Double = z.g
		Local b13:Double = z.h
		Local b20:Double = z.i
		Local b21:Double = z.j
		Local b22:Double = z.k
		Local b23:Double = z.l
		Local b30:Double = z.m
		Local b31:Double = z.n
		Local b32:Double = z.o
		Local b33:Double = z.p
		Return New SMat4D(b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30, ..
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
	Method Adjoint:SMat4D()
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a03:Double = d
		Local a10:Double = e
		Local a11:Double = f
		Local a12:Double = g
		Local a13:Double = h
		Local a20:Double = i
		Local a21:Double = j
		Local a22:Double = k
		Local a23:Double = l
		Local a30:Double = m
		Local a31:Double = n
		Local a32:Double = o
		Local a33:Double = p
		Return New SMat4D(a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22), ..
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
	bbdoc: Multiplies the matrix by @z by its components, returning a new matrix.
	End Rem
	Method CompMul:SMat4D(z:SMat4D Var)
		Return New SMat4D(a * z.a, b * z.b, c * z.c, d * z.d, ..
			e * z.e, f * z.f, g * z.g, h * z.h, ..
			i * z.i, j * z.j, k * z.k, l * z.l, ..
			m * z.m, n * z.n, o * z.o, p * z.p)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Double()
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a03:Double = d
		Local a10:Double = e
		Local a11:Double = f
		Local a12:Double = g
		Local a13:Double = h
		Local a20:Double = i
		Local a21:Double = j
		Local a22:Double = k
		Local a23:Double = l
		Local a30:Double = m
		Local a31:Double = n
		Local a32:Double = o
		Local a33:Double = p
		Local b00:Double = a00 * a11 - a01 * a10
		Local b01:Double = a00 * a12 - a02 * a10
		Local b02:Double = a00 * a13 - a03 * a10
		Local b03:Double = a01 * a12 - a02 * a11
		Local b04:Double = a01 * a13 - a03 * a11
		Local b05:Double = a02 * a13 - a03 * a12
		Local b06:Double = a20 * a31 - a21 * a30
		Local b07:Double = a20 * a32 - a22 * a30
		Local b08:Double = a20 * a33 - a23 * a30
		Local b09:Double = a21 * a32 - a22 * a31
		Local b10:Double = a21 * a33 - a23 * a31
		Local b11:Double = a22 * a33 - a23 * a32
		Return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
	End Method

	Rem
	bbdoc: Returns a projection matrix with a viewing frustum defined by the plane coordinates passed in.
	End Rem
	Function Frustum:SMat4D(l:Double, r:Double, b:Double, t:Double, n:Double, f:Double)
		Local rl:Double = 1.0 / (r - l)
		Local tb:Double = 1.0 / (t - b)
		Local nf:Double = 1.0 / (n - f)
		Return New SMat4D((2.0 * n) * rl, 0, 0, 0, ..
			0, (2.0 * n) * tb, 0, 0, ..
			(r + l) * rl, (t + b) * tb, (f + n) * nf, -1, ..
			0, 0, (2.0 * n * f) * nf, 0)
	End Function
	
	Rem
	bbdoc: The inverse of this matrix.
	about: An inverted matrix is such that if multiplied by the original would result in identity matrix.
	If some matrix transforms vectors in a particular way, then the inverse matrix can transform them back.
	End Rem
	Method Invert:SMat4D()
		Local a00:Double = a
		Local a01:Double = b
		Local a02:Double = c
		Local a03:Double = d
		Local a10:Double = e
		Local a11:Double = f
		Local a12:Double = g
		Local a13:Double = h
		Local a20:Double = i
		Local a21:Double = j
		Local a22:Double = k
		Local a23:Double = l
		Local a30:Double = m
		Local a31:Double = n
		Local a32:Double = o
		Local a33:Double = p
		Local b00:Double = a00 * a11 - a01 * a10
		Local b01:Double = a00 * a12 - a02 * a10
		Local b02:Double = a00 * a13 - a03 * a10
		Local b03:Double = a01 * a12 - a02 * a11
		Local b04:Double = a01 * a13 - a03 * a11
		Local b05:Double = a02 * a13 - a03 * a12
		Local b06:Double = a20 * a31 - a21 * a30
		Local b07:Double = a20 * a32 - a22 * a30
		Local b08:Double = a20 * a33 - a23 * a30
		Local b09:Double = a21 * a32 - a22 * a31
		Local b10:Double = a21 * a33 - a23 * a31
		Local b11:Double = a22 * a33 - a23 * a32
		Local det:Double = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
		If det = 0 Then
			Return New SMat4D(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat4D((a11 * b11 - a12 * b10 + a13 * b09) * det, ..
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
	Function LookAt:SMat4D(eye:SVec3D, pos:SVec3D, upDir:SVec3D)
		Local forward:SVec3D = (eye - pos).Normal()
		Local lft:SVec3D = upDir.Cross(forward).Normal()
		
		Local up:SVec3D = forward.Cross(lft)
		
		Local mat:SMat4D = SMat4D.Identity()
		
		Local a00:Double = lft.x
		Local a01:Double = up.x
		Local a02:Double = forward.x
		Local a03:Double = mat.d
		Local a10:Double = lft.y
		Local a11:Double = up.y
		Local a12:Double = forward.y
		Local a13:Double = mat.h
		Local a20:Double = lft.z
		Local a21:Double = up.z
		Local a22:Double = forward.z
		Local a23:Double = mat.l
		Local a30:Double = -lft.x * eye.x - lft.y * eye.y - lft.z * eye.z
		Local a31:Double = -up.x * eye.x - up.y * eye.y - up.z * eye.z
		Local a32:Double = -forward.x * eye.x - forward.y * eye.y - forward.z * eye.z
		Local a33:Double = mat.p

		Return New SMat4D(a00, a01, a02, a03, a10, a11, a12, a13, a20, a21, a22, a23, a30, a31, a32, a33)
	End Function
	
	Rem
	bbdoc: Creates an orthogonal projection matrix.
	about: The returned matrix, when used as a Camera's projection matrix, creates a view showing the area between @width and @height, with @zNear and @zFar as the near and far depth clipping planes.
	End Rem
	Function Orthogonal:SMat4D(width:Double, height:Double, zNear:Double, zFar:Double)
		Local nf:Double = 1.0 / (zNear - zFar)
		Return New SMat4D(2.0 / width, 0, 0, 0, ..
			0, 2.0 / height, 0, 0, ..
			0, 0, 2.0 * nf, 0, ..
			0, 0, (zNear + zFar) * nf, 1)
	End Function
	
	Rem
	bbdoc: Creates a perspective projection matrix.
	End Rem
	Function Perspective:SMat4D(fov:Double, w:Double, h:Double, n:Double, f:Double)
		Local tf:Double = Tan(fov / 2)
		Return New SMat4D(1 / ((w / h) * tf), 0, 0, 0, ..
			0, 1 / tf, 0, 0, ..
			0, 0, - (f + n) / (f - n), -1, ..
			0, 0, - (2 * f * n) / (f - n), 0)
	End Function
	
	Rem
	bbdoc: Creates a rotation matrix, rotated @angle degrees around the point @axis.
	End Rem
	Method Rotate:SMat4D(axis:SVec3D, angle:Double)
		Local c:Double = Cos(angle)
		Local ic:Double = 1 - c
		Local s:Double = Sin(angle)

		Local norm:SVec3D = axis.Normal()

		Local x:Double = ic * norm.x
		Local y:Double = ic * norm.y
		Local z:Double = ic * norm.z
		Local mat:SMat4D = New SMat4D(c + x * norm.x, x * norm.y + s * norm.z, x * norm.z - s * norm.y, 0, ..
				y * norm.x - s * norm.z, c + y * norm.y, y * norm.z + s * norm.x, 0, ..
				z * norm.x + s * norm.y, z * norm.y - s * norm.x, c + z * norm.z, 0, ..
				0, 0, 0, 1)
		
		Return Self * mat
	End Method
	
	Rem
	bbdoc: Returns a rotation matrix on the given @axis and @angle degrees.
	End Rem
	Function Rotation:SMat4D(axis:SVec3D, angle:Double)
		Local x:Double = axis.x
		Local y:Double = axis.y
		Local z:Double = axis.z
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Local t:Double = 1 - ca
		Return New SMat4D(x * x * t + ca, ..
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
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4D(s:SVec3D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Local bz:Double = s.z
		Return New SMat4D(a * bx, b * bx, c * bx, d * bx, ..
			e * by, f * by, g * by, h * by, ..
			i * bz, j * bz, k * bz, l * bz, ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4D(s:SVec3D)
		Return New SMat4D(s.x, 0, 0, 0, 0, s.y, 0, 0, 0, 0, s.z, 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns the transpose of this matrix.
	about: The transposed matrix is the one that has the columns exchanged with its rows.
	End Rem
	Method Transpose:SMat4D()
		Return New SMat4D(a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p)
	End Method
	
	Rem
	bbdoc: Translates the matrix to @s.
	End Rem
	Method Translate:SMat4D(s:SVec3D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Local bz:Double = s.z
		Return New SMat4D(a, b, c, d, e, f, g, h, i, j, k, l, ..
			a * bx + e * by + i * bz + m, ..
			b * bx + f * by + j * bz + n, ..
			c * bx + g * by + k * bz + o, ..
			d * bx + h * by + l * bz + p)
	End Method

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4D(s:SVec3D)
		Return New SMat4D(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			s.x, s.y, s.z, 1)
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
bbdoc: A #Float backed 2x2 Matrix.
End Rem
Struct SMat2F
	Field ReadOnly a:Float
	Field ReadOnly b:Float
	Field ReadOnly c:Float
	Field ReadOnly d:Float
	
	Rem
	bbdoc: Creates a new #SMat2F from the supplied arguments.
	End Rem
	Method New(a:Float, b:Float, c:Float, d:Float)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
	End Method
	
	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2F(v:SVec2F)
		Return New SVec2F(a * v.x + c * v.y, b * v.x + d * v.y)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat2F()
		Return New SMat2F(1, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat2F(z:SMat2F)
		Return New SMat2F(a + z.a, b + z.b, c + z.c, d + z.d)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat2F(z:SMat2F)
		Return New SMat2F(a - z.a, b - z.b, c - z.c, d - z.d)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat2F(z:SMat2F)
		Return New SMat2F(a * z.a + c * z.b, b * z.a + d * z.b, a * z.c + c * z.d, b * z.c + d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat2F()
		Return New SMat2F(d, -b, -c, a)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat2F(z:SMat2F)
		Return New SMat2F(a * z.a, b * z.b, c * z.c, d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Float()
		Return a * d - c * b
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat2F()
		Local det:Float = a * d - c * b
		If det = 0 Then
			Return New SMat2F(0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat2F(d * det, -b * det, -c * det, a * det)
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning the rotated matrix.
	End Rem
	Method Rotate:SMat2F(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2F(Float(a * ca + c * sa), Float(b * ca + d * sa), Float(a * -sa + c * ca), Float(b * -sa + d * ca))
	End Method
	
	Rem
	bbdoc: Creates a rotated matrix of @angle degrees.
	End Rem
	Function Rotation:SMat2F(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2F(Float(ca), Float(sa), Float(-sa), Float(ca))
	End Function
	
	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2F(s:SVec2F)
		Return New SMat2F(a * s.x, b * s.x, c * s.y, d * s.y)
	End Method

	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2F(s:SVec2D)
		Return New SMat2F(Float(a * s.x), Float(b * s.x), Float(c * s.y), Float(d * s.y))
	End Method
	
	Rem
	bbdoc: Creates a scaled matrix of the scale @s.
	End Rem
	Function Scaling:SMat2F(s:SVec2F)
		Return New SMat2F(s.x, 0, 0, s.y)
	End Function

	Rem
	bbdoc: Creates a scaled matrix of the scale @s.
	End Rem
	Function Scaling:SMat2F(s:SVec2D)
		Return New SMat2F(Float(s.x), 0, 0, Float(s.y))
	End Function
	
	Rem
	bbdoc: Returns the transpose of this matrix.
	End Rem
	Method Transpose:SMat2F()
		Return New SMat2F(a, c, b, d)
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
bbdoc: A #Float backed 3x3 matrix.
End Rem
Struct SMat3F
	Field ReadOnly a:Float
	Field ReadOnly b:Float
	Field ReadOnly c:Float
	Field ReadOnly d:Float
	Field ReadOnly e:Float
	Field ReadOnly f:Float
	Field ReadOnly g:Float
	Field ReadOnly h:Float
	Field ReadOnly i:Float

	Rem
	bbdoc: Creates a new #SMat3F from the supplied arguments.
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2F(v:SVec2F)
		Return New SVec2F(a * v.x + d * v.y + g, b * v.x + e * v.y + h)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec3F(v:SVec3F)
		Return New SVec3F(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec4F(v:SVec4F)
		Return New SVec4F(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i, 0)
	End Method

	Rem
	bbdoc: Return the 3x3 identity matrix.
	End Rem
	Function Identity:SMat3F()
		Return New SMat3F(1, 0, 0, 0, 1, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat3F(z:SMat3F Var)
		Return New SMat3F(a + z.a, b + z.b, c + z.c, d + z.d, e + z.e, f + z.f, g + z.g, h + z.h, i + z.i)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat3F(z:SMat3F Var)
		Return New SMat3F(a - z.a, b - z.b, c - z.c, d - z.d, e - z.e, f - z.f, g - z.g, h - z.h, i - z.i)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat3F(z:SMat3F Var)
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
		Return New SMat3F(b00 * a00 + b01 * a10 + b02 * a20, ..
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
	Method Adjoint:SMat3F()
		Return New SMat3F(e * i - f * h, ..
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
	Method CompMul:SMat3F(z:SMat3F Var)
		Return New SMat3F(a * z.a, b * z.b, c * z.c, d * z.d, e * z.e, f * z.f, g * z.g, h * z.h, i * z.i)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Float()
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
	Method Invert:SMat3F()
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
			Return New SMat3F(0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat3F(b01 * det, ..
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
	Method Rotate:SMat3F(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3F(Float(ca * a + sa * d), ..
			Float(ca * b + sa * e), ..
			Float(ca * c + sa * f), ..
			Float(ca * d - sa * a), ..
			Float(ca * e - sa * b), ..
			Float(ca * f - sa * c), ..
			g, h, i)
	End Method
	
	Rem
	bbdoc: Retrns a rotation matrix of @angle degrees.
	End Rem
	Function Rotation:SMat3F(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3F(Float(ca), Float(sa), 0, Float(-sa), Float(ca), 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3F(s:SVec2F)
		Local bx:Float = s.x
		Local by:Float = s.y
		Return New SMat3F(a * bx, b * bx, c * bx, d * by, e * by, f * by, g, h, i)
	End Method

	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3F(s:SVec2D)
		Local bx:Float = s.x
		Local by:Float = s.y
		Return New SMat3F(Float(a * bx), Float(b * bx), Float(c * bx), Float(d * by), Float(e * by), Float(f * by), g, h, i)
	End Method
	
	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3F(s:SVec2F)
		Return New SMat3F(s.x, 0, 0, 0, s.y, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3F(s:SVec2D)
		Return New SMat3F(Float(s.x), 0, 0, 0, Float(s.y), 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Returns a transposition of the matrix.
	End Rem
	Method Transpose:SMat3F()
		Return New SMat3F(a, d, g, b, e, h, c, f, i)
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
bbdoc: A standard #Float backed 4x4 transformation matrix.
End Rem
Struct SMat4F
	Field ReadOnly a:Float
	Field ReadOnly b:Float
	Field ReadOnly c:Float
	Field ReadOnly d:Float
	Field ReadOnly e:Float
	Field ReadOnly f:Float
	Field ReadOnly g:Float
	Field ReadOnly h:Float
	Field ReadOnly i:Float
	Field ReadOnly j:Float
	Field ReadOnly k:Float
	Field ReadOnly l:Float
	Field ReadOnly m:Float
	Field ReadOnly n:Float
	Field ReadOnly o:Float
	Field ReadOnly p:Float

	Rem
	bbdoc: Creates a new #SMat4F from the supplied arguments.
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2F(v:SVec2F)
		Return New SVec2F(a * v.x + e * v.y + m, b * v.x + f * v.y + n)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec3F(v:SVec3F)
		Local w:Float = d * v.x + h * v.y + l * v.z + p
		If w = 0 Then
			w = 1
		Else
			w = 1 / w
		End If
		Return New SVec3F((a * v.x + e * v.y + i * v.z + m) * w, ..
			(b * v.x + f * v.y + j * v.z + n) * w, ..
			(c * v.x + g * v.y + k * v.z + o) * w)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec4F(v:SVec4F)
		Return New SVec4F(a * v.x + e * v.y + i * v.z + m * v.w, ..
			b * v.x + f * v.y + j * v.z + n * v.w, ..
			c * v.x + g * v.y + k * v.z + o * v.w, ..
			d * v.x + h * v.y + l * v.z + p * v.w)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat4F()
		Return New SMat4F(1, 0, 0, 0, ..
				0, 1, 0, 0, ..
				0, 0, 1, 0, ..
				0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat4F(z:SMat4F Var)
		Return New SMat4F(a + z.a, b + z.b, c + z.c, d + z.d, ..
			e + z.e, f + z.f, g + z.g, h + z.h, ..
			i + z.i, j + z.j, k + z.k, l + z.l, ..
			m + z.m, n + z.n, o + z.o, p + z.p)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat4F(z:SMat4F Var)
		Return New SMat4F(a - z.a, b - z.b, c - z.c, d - z.d, ..
			e - z.e, f - z.f, g - z.g, h - z.h, ..
			i - z.i, j - z.j, k - z.k, l - z.l, ..
			m - z.m, n - z.n, o - z.o, p - z.p)
	End Method

	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix. 
	End Rem
	Method Operator*:SMat4F(z:SMat4F Var)
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
		Return New SMat4F(b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30, ..
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
	Method Adjoint:SMat4F()
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
		Return New SMat4F(a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22), ..
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
	bbdoc: Multiplies the matrix by @z by its components, returning a new matrix.
	End Rem
	Method CompMul:SMat4F(z:SMat4F Var)
		Return New SMat4F(a * z.a, b * z.b, c * z.c, d * z.d, ..
			e * z.e, f * z.f, g * z.g, h * z.h, ..
			i * z.i, j * z.j, k * z.k, l * z.l, ..
			m * z.m, n * z.n, o * z.o, p * z.p)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Float()
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
	Function Frustum:SMat4F(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float)
		Local rl:Float = 1.0 / (r - l)
		Local tb:Float = 1.0 / (t - b)
		Local nf:Float = 1.0 / (n - f)
		Return New SMat4F((2.0 * n) * rl, 0, 0, 0, ..
			0, (2.0 * n) * tb, 0, 0, ..
			(r + l) * rl, (t + b) * tb, (f + n) * nf, -1, ..
			0, 0, (2.0 * n * f) * nf, 0)
	End Function
	
	Rem
	bbdoc: The inverse of this matrix.
	about: An inverted matrix is such that if multiplied by the original would result in identity matrix.
	If some matrix transforms vectors in a particular way, then the inverse matrix can transform them back.
	End Rem
	Method Invert:SMat4F()
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
			Return New SMat4F(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat4F((a11 * b11 - a12 * b10 + a13 * b09) * det, ..
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
	Function LookAt:SMat4F(eye:SVec3F, pos:SVec3F, upDir:SVec3F)
		Local forward:SVec3F = (eye - pos).Normal()
		Local lft:SVec3F = upDir.Cross(forward).Normal()
		
		Local up:SVec3F = forward.Cross(lft)
		
		Local mat:SMat4F = SMat4F.Identity()
		
		Local a00:Float = lft.x
		Local a01:Float = up.x
		Local a02:Float = forward.x
		Local a03:Float = mat.d
		Local a10:Float = lft.y
		Local a11:Float = up.y
		Local a12:Float = forward.y
		Local a13:Float = mat.h
		Local a20:Float = lft.z
		Local a21:Float = up.z
		Local a22:Float = forward.z
		Local a23:Float = mat.l
		Local a30:Float = -lft.x * eye.x - lft.y * eye.y - lft.z * eye.z
		Local a31:Float = -up.x * eye.x - up.y * eye.y - up.z * eye.z
		Local a32:Float = -forward.x * eye.x - forward.y * eye.y - forward.z * eye.z
		Local a33:Float = mat.p

		Return New SMat4F(a00, a01, a02, a03, a10, a11, a12, a13, a20, a21, a22, a23, a30, a31, a32, a33)
	End Function
	
	Rem
	bbdoc: Creates an orthogonal projection matrix.
	about: The returned matrix, when used as a Camera's projection matrix, creates a view showing the area between @width and @height, with @zNear and @zFar as the near and far depth clipping planes.
	End Rem
	Function Orthogonal:SMat4F(width:Float, height:Float, zNear:Float, zFar:Float)
		Local nf:Float = 1.0 / (zNear - zFar)
		Return New SMat4F(2.0 / width, 0, 0, 0, ..
			0, 2.0 / height, 0, 0, ..
			0, 0, 2.0 * nf, 0, ..
			0, 0, (zNear + zFar) * nf, 1)
	End Function
	
	Rem
	bbdoc: Creates a perspective projection matrix.
	End Rem
	Function Perspective:SMat4F(fov:Float, w:Float, h:Float, n:Float, f:Float)
		Local tf:Float = Tan(fov / 2)
		Return New SMat4F(1 / ((w / h) * tf), 0, 0, 0, ..
			0, 1 / tf, 0, 0, ..
			0, 0, - (f + n) / (f - n), -1, ..
			0, 0, - (2 * f * n) / (f - n), 0)
	End Function
	
	Rem
	bbdoc: Creates a rotation matrix, rotated @angle degrees around the point @axis.
	End Rem
	Method Rotate:SMat4F(axis:SVec3F, angle:Double)
		Local c:Float = Cos(angle)
		Local ic:Float = 1 - c
		Local s:Float = Sin(angle)

		Local norm:SVec3F = axis.Normal()

		Local x:Float = ic * norm.x
		Local y:Float = ic * norm.y
		Local z:Float = ic * norm.z
		Local mat:SMat4F = New SMat4F(c + x * norm.x, x * norm.y + s * norm.z, x * norm.z - s * norm.y, 0, ..
				y * norm.x - s * norm.z, c + y * norm.y, y * norm.z + s * norm.x, 0, ..
				z * norm.x + s * norm.y, z * norm.y - s * norm.x, c + z * norm.z, 0, ..
				0, 0, 0, 1)
		
		Return Self * mat
	End Method
	
	Rem
	bbdoc: Returns a rotation matrix on the given @axis and @angle degrees.
	End Rem
	Function Rotation:SMat4F(axis:SVec3F, angle:Double)
		Local x:Float = axis.x
		Local y:Float = axis.y
		Local z:Float = axis.z
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Local t:Float = 1 - ca
		Return New SMat4F(Float(x * x * t + ca), ..
			Float(y * x * t + z * sa), ..
			Float(z * x * t - y * sa), ..
			0, ..
			Float(x * y * t - z * sa), ..
			Float(y * y * t + ca), ..
			Float(z * y * t + x * sa), ..
			0, ..
			Float(x * z * t + y * sa), ..
			Float(y * z * t - x * sa), ..
			Float(z * z * t + ca), ..
			0, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4F(s:SVec3F)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4F(a * bx, b * bx, c * bx, d * bx, ..
			e * by, f * by, g * by, h * by, ..
			i * bz, j * bz, k * bz, l * bz, ..
			m, n, o, p)
	End Method

	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4F(s:SVec3D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Local bz:Double = s.z
		Return New SMat4F(Float(a * bx), Float(b * bx), Float(c * bx), Float(d * bx), ..
			Float(e * by), Float(f * by), Float(g * by), Float(h * by), ..
			Float(i * bz), Float(j * bz), Float(k * bz), Float(l * bz), ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4F(s:SVec3F)
		Return New SMat4F(s.x, 0, 0, 0, 0, s.y, 0, 0, 0, 0, s.z, 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Creates a Scaling matrix.
	End Rem
	Function Scaling:SMat4F(s:SVec3D)
		Return New SMat4F(Float(s.x), 0, 0, 0, 0, Float(s.y), 0, 0, 0, 0, Float(s.z), 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns the transpose of this matrix.
	about: The transposed matrix is the one that has the columns exchanged with its rows.
	End Rem
	Method Transpose:SMat4F()
		Return New SMat4F(a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p)
	End Method
	
	Rem
	bbdoc: Translates the matrix to @s.
	End Rem
	Method Translate:SMat4F(s:SVec3F)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4F(a, b, c, d, e, f, g, h, i, j, k, l, ..
			a * bx + e * by + i * bz + m, ..
			b * bx + f * by + j * bz + n, ..
			c * bx + g * by + k * bz + o, ..
			d * bx + h * by + l * bz + p)
	End Method

	Rem
	bbdoc: Translates the matrix To @s.
	End Rem
	Method Translate:SMat4F(s:SVec3D)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4F(a, b, c, d, e, f, g, h, i, j, k, l, ..
			a * bx + e * by + i * bz + m, ..
			b * bx + f * by + j * bz + n, ..
			c * bx + g * by + k * bz + o, ..
			d * bx + h * by + l * bz + p)
	End Method

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4F(s:SVec3F)
		Return New SMat4F(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			s.x, s.y, s.z, 1)
	End Function

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4F(s:SVec3D)
		Return New SMat4F(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			Float(s.x), Float(s.y), Float(s.z), 1)
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
bbdoc: An #Int backed 2x2 Matrix.
End Rem
Struct SMat2I
	Field ReadOnly a:Int
	Field ReadOnly b:Int
	Field ReadOnly c:Int
	Field ReadOnly d:Int
	
	Rem
	bbdoc: Creates a new #SMat2I from the supplied arguments.
	End Rem
	Method New(a:Int, b:Int, c:Int, d:Int)
		Self.a = a
		Self.b = b
		Self.c = c
		Self.d = d
	End Method
	
	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2I(v:SVec2I)
		Return New SVec2I(a * v.x + c * v.y, b * v.x + d * v.y)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat2I()
		Return New SMat2I(1, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat2I(z:SMat2I)
		Return New SMat2I(a + z.a, b + z.b, c + z.c, d + z.d)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat2I(z:SMat2I)
		Return New SMat2I(a - z.a, b - z.b, c - z.c, d - z.d)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat2I(z:SMat2I)
		Return New SMat2I(a * z.a + c * z.b, b * z.a + d * z.b, a * z.c + c * z.d, b * z.c + d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the transposition of the cofactor matrix.
	End Rem
	Method Adjoint:SMat2I()
		Return New SMat2I(d, -b, -c, a)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z by its components, return a new matrix.
	End Rem
	Method CompMul:SMat2I(z:SMat2I)
		Return New SMat2I(a * z.a, b * z.b, c * z.c, d * z.d)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Int()
		Return a * d - c * b
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat2I()
		Local det:Double = a * d - c * b
		If det = 0 Then
			Return New SMat2I(0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat2I(Int(d * det), Int(-b * det), Int(-c * det), Int(a * det))
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning the rotated matrix.
	End Rem
	Method Rotate:SMat2I(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2I(Int(a * ca + c * sa), Int(b * ca + d * sa), Int(a * -sa + c * ca), Int(b * -sa + d * ca))
	End Method
	
	Rem
	bbdoc: Creates a rotated matrix of @angle degrees.
	End Rem
	Function Rotation:SMat2I(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat2I(Int(ca), Int(sa), Int(-sa), Int(ca))
	End Function
	
	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2I(s:SVec2I)
		Return New SMat2I(a * s.x, b * s.x, c * s.y, d * s.y)
	End Method

	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2I(s:SVec2D)
		Return New SMat2I(Int(a * s.x), Int(b * s.x), Int(c * s.y), Int(d * s.y))
	End Method

	Rem
	bbdoc: Returns the scale of this matrix.
	End Rem
	Method Scale:SMat2I(s:SVec2F)
		Return New SMat2I(Int(a * s.x), Int(b * s.x), Int(c * s.y), Int(d * s.y))
	End Method
	
	Rem
	bbdoc: Creates a scaled matrix of the scale @s.
	End Rem
	Function Scaling:SMat2I(s:SVec2I)
		Return New SMat2I(s.x, 0, 0, s.y)
	End Function
	
	Rem
	bbdoc: Returns the transpose of this matrix.
	End Rem
	Method Transpose:SMat2I()
		Return New SMat2I(a, c, b, d)
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
bbdoc: An #Int backed 3x3 matrix.
End Rem
Struct SMat3I
	Field ReadOnly a:Int
	Field ReadOnly b:Int
	Field ReadOnly c:Int
	Field ReadOnly d:Int
	Field ReadOnly e:Int
	Field ReadOnly f:Int
	Field ReadOnly g:Int
	Field ReadOnly h:Int
	Field ReadOnly i:Int

	Rem
	bbdoc: Creates a new #SMat3I from the supplied arguments.
	End Rem
	Method New(a:Int, b:Int, c:Int, d:Int, e:Int, f:Int, g:Int, h:Int, i:Int)
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2I(v:SVec2I)
		Return New SVec2I(a * v.x + d * v.y + g, b * v.x + e * v.y + h)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec3I(v:SVec3I)
		Return New SVec3I(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i)
	End Method

	Rem
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec4I(v:SVec4I)
		Return New SVec4I(v.x * a + v.y * d + v.z * g, v.x * b + v.y * e + v.z * h, v.x * c + v.y * f + v.z * i, 0)
	End Method

	Rem
	bbdoc: Return the 3x3 identity matrix.
	End Rem
	Function Identity:SMat3I()
		Return New SMat3I(1, 0, 0, 0, 1, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat3I(z:SMat3I Var)
		Return New SMat3I(a + z.a, b + z.b, c + z.c, d + z.d, e + z.e, f + z.f, g + z.g, h + z.h, i + z.i)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat3I(z:SMat3I Var)
		Return New SMat3I(a - z.a, b - z.b, c - z.c, d - z.d, e - z.e, f - z.f, g - z.g, h - z.h, i - z.i)
	End Method
	
	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix.
	End Rem
	Method Operator*:SMat3I(z:SMat3I Var)
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a10:Int = d
		Local a11:Int = e
		Local a12:Int = f
		Local a20:Int = g
		Local a21:Int = h
		Local a22:Int = i
		Local b00:Int = z.a
		Local b01:Int = z.b
		Local b02:Int = z.c
		Local b10:Int = z.d
		Local b11:Int = z.e
		Local b12:Int = z.f
		Local b20:Int = z.g
		Local b21:Int = z.h
		Local b22:Int = z.i
		Return New SMat3I(b00 * a00 + b01 * a10 + b02 * a20, ..
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
	Method Adjoint:SMat3I()
		Return New SMat3I(e * i - f * h, ..
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
	Method CompMul:SMat3I(z:SMat3I Var)
		Return New SMat3I(a * z.a, b * z.b, c * z.c, d * z.d, e * z.e, f * z.f, g * z.g, h * z.h, i * z.i)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Int()
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a10:Int = d
		Local a11:Int = e
		Local a12:Int = f
		Local a20:Int = g
		Local a21:Int = h
		Local a22:Int = i
		Return a00 * ( a22 * a11 - a12 * a21) + a01 * (-a22 * a10 + a12 * a20) + a02 * ( a21 * a10 - a11 * a20)
	End Method
	
	Rem
	bbdoc: Returns the inverse of the matrix.
	End Rem
	Method Invert:SMat3I()
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a10:Int = d
		Local a11:Int = e
		Local a12:Int = f
		Local a20:Int = g
		Local a21:Int = h
		Local a22:Int = i
		Local b01:Int =  a22 * a11 - a12 * a21
		Local b11:Int = -a22 * a10 + a12 * a20
		Local b21:Int =  a21 * a10 - a11 * a20
		Local det:Double = a00 * b01 + a01 * b11 + a02 * b21
		If det = 0 Then
			Return New SMat3I(0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat3I(Int(b01 * det), ..
			Int((-a22 * a01 + a02 * a21) * det), ..
			Int(( a12 * a01 - a02 * a11) * det),
			Int(b11 * det), ..
			Int(( a22 * a00 - a02 * a20) * det), ..
			Int((-a12 * a00 + a02 * a10) * det), ..
			Int(b21 * det), ..
			Int((-a21 * a00 + a01 * a20) * det), ..
			Int(( a11 * a00 - a01 * a10) * det))
	End Method
	
	Rem
	bbdoc: Rotates the matrix by @angle degrees, returning a new matrix.
	End Rem
	Method Rotate:SMat3I(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3I(Int(ca * a + sa * d), ..
			Int(ca * b + sa * e), ..
			Int(ca * c + sa * f), ..
			Int(ca * d - sa * a), ..
			Int(ca * e - sa * b), ..
			Int(ca * f - sa * c), ..
			g, h, i)
	End Method
	
	Rem
	bbdoc: Retrns a rotation matrix of @angle degrees.
	End Rem
	Function Rotation:SMat3I(angle:Double)
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Return New SMat3I(Int(ca), Int(sa), 0, Int(-sa), Int(ca), 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3I(s:SVec2I)
		Local bx:Int = s.x
		Local by:Int = s.y
		Return New SMat3I(a * bx, b * bx, c * bx, d * by, e * by, f * by, g, h, i)
	End Method

	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3I(s:SVec2D)
		Local bx:Int = s.x
		Local by:Int = s.y
		Return New SMat3I(Int(a * bx), Int(b * bx), Int(c * bx), Int(d * by), Int(e * by), Int(f * by), g, h, i)
	End Method

	Rem
	bbdoc: Scales the matrix by @s, returning a new matrix.
	End Rem
	Method Scale:SMat3I(s:SVec2F)
		Local bx:Int = s.x
		Local by:Int = s.y
		Return New SMat3I(Int(a * bx), Int(b * bx), Int(c * bx), Int(d * by), Int(e * by), Int(f * by), g, h, i)
	End Method
	
	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3I(s:SVec2I)
		Return New SMat3I(s.x, 0, 0, 0, s.y, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3I(s:SVec2D)
		Return New SMat3I(Int(s.x), 0, 0, 0, Int(s.y), 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns a scaling matrix of @s.
	End Rem
	Function Scaling:SMat3I(s:SVec2F)
		Return New SMat3I(Int(s.x), 0, 0, 0, Int(s.y), 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Returns a transposition of the matrix.
	End Rem
	Method Transpose:SMat3I()
		Return New SMat3I(a, d, g, b, e, h, c, f, i)
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
bbdoc: A standard #Int backed 4x4 transformation matrix.
End Rem
Struct SMat4I
	Field ReadOnly a:Int
	Field ReadOnly b:Int
	Field ReadOnly c:Int
	Field ReadOnly d:Int
	Field ReadOnly e:Int
	Field ReadOnly f:Int
	Field ReadOnly g:Int
	Field ReadOnly h:Int
	Field ReadOnly i:Int
	Field ReadOnly j:Int
	Field ReadOnly k:Int
	Field ReadOnly l:Int
	Field ReadOnly m:Int
	Field ReadOnly n:Int
	Field ReadOnly o:Int
	Field ReadOnly p:Int

	Rem
	bbdoc: Creates a new #SMat4I from the supplied arguments.
	End Rem
	Method New(a:Int, b:Int, c:Int, d:Int, e:Int, f:Int, g:Int, h:Int, i:Int, j:Int, k:Int, l:Int, m:Int, n:Int, o:Int, p:Int)
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
	bbdoc: Applies the matrix to the vector @v, returning a new vector.
	End Rem
	Method Apply:SVec2I(v:SVec2I)
		Return New SVec2I(a * v.x + e * v.y + m, b * v.x + f * v.y + n)
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec3I(v:SVec3I)
		Local w:Double = d * v.x + h * v.y + l * v.z + p
		If w = 0 Then
			w = 1
		Else
			w = 1 / w
		End If
		Return New SVec3I(Int((a * v.x + e * v.y + i * v.z + m) * w), ..
			Int((b * v.x + f * v.y + j * v.z + n) * w), ..
			Int((c * v.x + g * v.y + k * v.z + o) * w))
	End Method

	Rem
	bbdoc: Applies the 4x4 matrix @b to the vector, returning a new vector.
	End Rem
	Method Apply:SVec4I(v:SVec4I)
		Return New SVec4I(a * v.x + e * v.y + i * v.z + m * v.w, ..
			b * v.x + f * v.y + j * v.z + n * v.w, ..
			c * v.x + g * v.y + k * v.z + o * v.w, ..
			d * v.x + h * v.y + l * v.z + p * v.w)
	End Method

	Rem
	bbdoc: Returns the identity matrix.
	End Rem
	Function Identity:SMat4I()
		Return New SMat4I(1, 0, 0, 0, ..
				0, 1, 0, 0, ..
				0, 0, 1, 0, ..
				0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Adds @z to the matrix, returning a new matrix.
	End Rem
	Method Operator+:SMat4I(z:SMat4I Var)
		Return New SMat4I(a + z.a, b + z.b, c + z.c, d + z.d, ..
			e + z.e, f + z.f, g + z.g, h + z.h, ..
			i + z.i, j + z.j, k + z.k, l + z.l, ..
			m + z.m, n + z.n, o + z.o, p + z.p)
	End Method
	
	Rem
	bbdoc: Subtracts @z from the matrix, returning a new matrix.
	End Rem
	Method Operator-:SMat4I(z:SMat4I Var)
		Return New SMat4I(a - z.a, b - z.b, c - z.c, d - z.d, ..
			e - z.e, f - z.f, g - z.g, h - z.h, ..
			i - z.i, j - z.j, k - z.k, l - z.l, ..
			m - z.m, n - z.n, o - z.o, p - z.p)
	End Method

	Rem
	bbdoc: Multiplies the matrix by @z, returning a new matrix. 
	End Rem
	Method Operator*:SMat4I(z:SMat4I Var)
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a03:Int = d
		Local a10:Int = e
		Local a11:Int = f
		Local a12:Int = g
		Local a13:Int = h
		Local a20:Int = i
		Local a21:Int = j
		Local a22:Int = k
		Local a23:Int = l
		Local a30:Int = m
		Local a31:Int = n
		Local a32:Int = o
		Local a33:Int = p
		Local b00:Int = z.a
		Local b01:Int = z.b
		Local b02:Int = z.c
		Local b03:Int = z.d
		Local b10:Int = z.e
		Local b11:Int = z.f
		Local b12:Int = z.g
		Local b13:Int = z.h
		Local b20:Int = z.i
		Local b21:Int = z.j
		Local b22:Int = z.k
		Local b23:Int = z.l
		Local b30:Int = z.m
		Local b31:Int = z.n
		Local b32:Int = z.o
		Local b33:Int = z.p
		Return New SMat4I(b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30, ..
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
	Method Adjoint:SMat4I()
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a03:Int = d
		Local a10:Int = e
		Local a11:Int = f
		Local a12:Int = g
		Local a13:Int = h
		Local a20:Int = i
		Local a21:Int = j
		Local a22:Int = k
		Local a23:Int = l
		Local a30:Int = m
		Local a31:Int = n
		Local a32:Int = o
		Local a33:Int = p
		Return New SMat4I(a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22), ..
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
	bbdoc: Multiplies the matrix by @z by its components, returning a new matrix.
	End Rem
	Method CompMul:SMat4I(z:SMat4I Var)
		Return New SMat4I(a * z.a, b * z.b, c * z.c, d * z.d, ..
			e * z.e, f * z.f, g * z.g, h * z.h, ..
			i * z.i, j * z.j, k * z.k, l * z.l, ..
			m * z.m, n * z.n, o * z.o, p * z.p)
	End Method
	
	Rem
	bbdoc: Returns the determinant of the matrix.
	End Rem
	Method Determinant:Int()
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a03:Int = d
		Local a10:Int = e
		Local a11:Int = f
		Local a12:Int = g
		Local a13:Int = h
		Local a20:Int = i
		Local a21:Int = j
		Local a22:Int = k
		Local a23:Int = l
		Local a30:Int = m
		Local a31:Int = n
		Local a32:Int = o
		Local a33:Int = p
		Local b00:Int = a00 * a11 - a01 * a10
		Local b01:Int = a00 * a12 - a02 * a10
		Local b02:Int = a00 * a13 - a03 * a10
		Local b03:Int = a01 * a12 - a02 * a11
		Local b04:Int = a01 * a13 - a03 * a11
		Local b05:Int = a02 * a13 - a03 * a12
		Local b06:Int = a20 * a31 - a21 * a30
		Local b07:Int = a20 * a32 - a22 * a30
		Local b08:Int = a20 * a33 - a23 * a30
		Local b09:Int = a21 * a32 - a22 * a31
		Local b10:Int = a21 * a33 - a23 * a31
		Local b11:Int = a22 * a33 - a23 * a32
		Return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
	End Method

	Rem
	bbdoc: Returns a projection matrix with a viewing frustum defined by the plane coordinates passed in.
	End Rem
	Function Frustum:SMat4I(l:Double, r:Double, b:Double, t:Double, n:Double, f:Double)
		Local rl:Double = 1.0 / (r - l)
		Local tb:Double = 1.0 / (t - b)
		Local nf:Double = 1.0 / (n - f)
		Return New SMat4I(Int((2.0 * n) * rl), 0, 0, 0, ..
			0, Int((2.0 * n) * tb), 0, 0, ..
			Int((r + l) * rl), Int((t + b) * tb), Int((f + n) * nf), -1, ..
			0, 0, Int((2.0 * n * f) * nf), 0)
	End Function
	
	Rem
	bbdoc: The inverse of this matrix.
	about: An inverted matrix is such that if multiplied by the original would result in identity matrix.
	If some matrix transforms vectors in a particular way, then the inverse matrix can transform them back.
	End Rem
	Method Invert:SMat4I()
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a03:Int = d
		Local a10:Int = e
		Local a11:Int = f
		Local a12:Int = g
		Local a13:Int = h
		Local a20:Int = i
		Local a21:Int = j
		Local a22:Int = k
		Local a23:Int = l
		Local a30:Int = m
		Local a31:Int = n
		Local a32:Int = o
		Local a33:Int = p
		Local b00:Int = a00 * a11 - a01 * a10
		Local b01:Int = a00 * a12 - a02 * a10
		Local b02:Int = a00 * a13 - a03 * a10
		Local b03:Int = a01 * a12 - a02 * a11
		Local b04:Int = a01 * a13 - a03 * a11
		Local b05:Int = a02 * a13 - a03 * a12
		Local b06:Int = a20 * a31 - a21 * a30
		Local b07:Int = a20 * a32 - a22 * a30
		Local b08:Int = a20 * a33 - a23 * a30
		Local b09:Int = a21 * a32 - a22 * a31
		Local b10:Int = a21 * a33 - a23 * a31
		Local b11:Int = a22 * a33 - a23 * a32
		Local det:Int = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
		If det = 0 Then
			Return New SMat4I(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		End If
		det = 1 / det
		Return New SMat4I((a11 * b11 - a12 * b10 + a13 * b09) * det, ..
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
	Function LookAt:SMat4I(eye:SVec3I, pos:SVec3I, up:SVec3I)
		Local ex:Int = eye.x
		Local ey:Int = eye.y
		Local ez:Int = eye.z
		Local px:Int = pos.x
		Local py:Int = pos.y
		Local pz:Int = pos.z
		Local ux:Int = up.x
		Local uy:Int = up.y
		Local uz:Int = up.z
		Local z0:Int = ex - px
		Local z1:Int = ey - py
		Local z2:Int = ez - pz
		
		If z0 = 0 Or z1 = 0 Or z2 = 0 Then
			Return Identity()
		End If
		
		Local length:Int = Sqr(z0 * z0 + z1 * z1 + z2 * z2)
		z0 :* length
		z1 :* length
		z2 :* length
		
		Local x0:Int = uy * z2 - uz * z1
		Local x1:Int = uz * z0 - ux * z2
		Local x2:Int = ux * z1 - uy * z0
		
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
		
		Local y0:Int = z1 * x2 - z2 * x1
		Local y1:Int = z2 * x0 - z0 * x2
		Local y2:Int = z0 * x1 - z1 * x0
		
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
		
		Return New SMat4I(x0, y0, z0, 0, x1, y1, z1, 0, x2, y2, z2, 0, ..
			-(x0 * ex + x1 * ey + x2 * ez), -(y0 * ex + y1 * ey + y2 * ez), -(z0 * ex + z1 * ey + z2 * ez), 1)
	End Function
	
	Rem
	bbdoc: Creates an orthogonal projection matrix.
	about: The returned matrix, when used as a Camera's projection matrix, creates a view showing the area between @width and @height, with @zNear and @zFar as the near and far depth clipping planes.
	End Rem
	Function Orthogonal:SMat4I(width:Double, height:Double, zNear:Double, zFar:Double)
		Local nf:Double = 1.0 / (zNear - zFar)
		Return New SMat4I(Int(2.0 / width), 0, 0, 0, ..
			0, Int(2.0 / height), 0, 0, ..
			0, 0, Int(2.0 * nf), 0, ..
			0, 0, Int((zNear + zFar) * nf), 1)
	End Function
	
	Rem
	bbdoc: Creates a Perspective projection matrix.
	End Rem
	Function Perspective:SMat4I(fov:Double, w:Double, h:Double, n:Double, f:Double)
		Local ft:Double = 1.0 / Tan(fov * 0.5)
		Local nf:Double = 1.0 / (n - f)
		Return New SMat4I(Int(ft), 0, 0, 0, ..
			0, Int(ft * w / h), 0, 0, ..
			0, 0, Int((f + n) * nf), -1, ..
			0, 0, Int((2.0 * f * n) * nf), 0) 
	End Function
	
	Rem
	bbdoc: Creates a rotation matrix, rotated @angle degrees around the point @axis.
	End Rem
	Method Rotate:SMat4I(axis:SVec3I, angle:Double)
		Local x:Int = axis.x
		Local y:Int = axis.y
		Local z:Int = axis.z
		Local a00:Int = a
		Local a01:Int = b
		Local a02:Int = c
		Local a03:Int = d
		Local a10:Int = e
		Local a11:Int = f
		Local a12:Int = g
		Local a13:Int = h
		Local a20:Int = i
		Local a21:Int = j
		Local a22:Int = k
		Local a23:Int = l
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Local t:Double = 1 - ca
		Local b00:Double = x * x * t + ca
		Local b01:Double = y * x * t + z * sa
		Local b02:Double = z * x * t - y * sa
		Local b10:Double = x * y * t - z * sa
		Local b11:Double = y * y * t + ca
		Local b12:Double = z * y * t + x * sa
		Local b20:Double = x * z * t + y * sa
		Local b21:Double = y * z * t - x * sa
		Local b22:Double = z * z * t + ca
		Return New SMat4I(Int(a00 * b00 + a10 * b01 + a20 * b02), ..
			Int(a01 * b00 + a11 * b01 + a21 * b02), ..
			Int(a02 * b00 + a12 * b01 + a22 * b02), ..
			Int(a03 * b00 + a13 * b01 + a23 * b02), ..
			Int(a00 * b10 + a10 * b11 + a20 * b12), ..
			Int(a01 * b10 + a11 * b11 + a21 * b12), ..
			Int(a02 * b10 + a12 * b11 + a22 * b12), ..
			Int(a03 * b10 + a13 * b11 + a23 * b12), ..
			Int(a00 * b20 + a10 * b21 + a20 * b22), ..
			Int(a01 * b20 + a11 * b21 + a21 * b22), ..
			Int(a02 * b20 + a12 * b21 + a22 * b22), ..
			Int(a03 * b20 + a13 * b21 + a23 * b22), ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Returns a rotation matrix on the given @axis and @angle degrees.
	End Rem
	Function Rotation:SMat4I(axis:SVec3I, angle:Double)
		Local x:Int = axis.x
		Local y:Int = axis.y
		Local z:Int = axis.z
		Local sa:Double = Sin(angle)
		Local ca:Double = Cos(angle)
		Local t:Double = 1 - ca
		Return New SMat4I(Int(x * x * t + ca), ..
			Int(y * x * t + z * sa), ..
			Int(z * x * t - y * sa), ..
			0, ..
			Int(x * y * t - z * sa), ..
			Int(y * y * t + ca), ..
			Int(z * y * t + x * sa), ..
			0, ..
			Int(x * z * t + y * sa), ..
			Int(y * z * t - x * sa), ..
			Int(z * z * t + ca), ..
			0, 0, 0, 0, 1)
	End Function
	
	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4I(s:SVec3I)
		Local bx:Int = s.x
		Local by:Int = s.y
		Local bz:Int = s.z
		Return New SMat4I(a * bx, b * bx, c * bx, d * bx, ..
			e * by, f * by, g * by, h * by, ..
			i * bz, j * bz, k * bz, l * bz, ..
			m, n, o, p)
	End Method

	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4I(s:SVec3D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Local bz:Double = s.z
		Return New SMat4I(Int(a * bx), Int(b * bx), Int(c * bx), Int(d * bx), ..
			Int(e * by), Int(f * by), Int(g * by), Int(h * by), ..
			Int(i * bz), Int(j * bz), Int(k * bz), Int(l * bz), ..
			m, n, o, p)
	End Method

	Rem
	bbdoc: Scales the matrix, return the new scaled matrix.
	End Rem
	Method Scale:SMat4I(s:SVec3F)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4I(Int(a * bx), Int(b * bx), Int(c * bx), Int(d * bx), ..
			Int(e * by), Int(f * by), Int(g * by), Int(h * by), ..
			Int(i * bz), Int(j * bz), Int(k * bz), Int(l * bz), ..
			m, n, o, p)
	End Method
	
	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4I(s:SVec3I)
		Return New SMat4I(s.x, 0, 0, 0, 0, s.y, 0, 0, 0, 0, s.z, 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4I(s:SVec3D)
		Return New SMat4I(Int(s.x), 0, 0, 0, 0, Int(s.y), 0, 0, 0, 0, Int(s.z), 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Creates a scaling matrix.
	End Rem
	Function Scaling:SMat4I(s:SVec3F)
		Return New SMat4I(Int(s.x), 0, 0, 0, 0, Int(s.y), 0, 0, 0, 0, Int(s.z), 0, 0, 0, 0, 1)
	End Function

	Rem
	bbdoc: Returns the transpose of this matrix.
	about: The transposed matrix is the one that has the columns exchanged with its rows.
	End Rem
	Method Transpose:SMat4I()
		Return New SMat4I(a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p)
	End Method
	
	Rem
	bbdoc: Translates the matrix to @s.
	End Rem
	Method Translate:SMat4I(s:SVec3I)
		Local bx:Int = s.x
		Local by:Int = s.y
		Local bz:Int = s.z
		Return New SMat4I(a, b, c, d, e, f, g, h, i, j, k, l, ..
			a * bx + e * by + i * bz + m, ..
			b * bx + f * by + j * bz + n, ..
			c * bx + g * by + k * bz + o, ..
			d * bx + h * by + l * bz + p)
	End Method

	Rem
	bbdoc: Translates the matrix to @s.
	End Rem
	Method Translate:SMat4I(s:SVec3D)
		Local bx:Double = s.x
		Local by:Double = s.y
		Local bz:Double = s.z
		Return New SMat4I(a, b, c, d, e, f, g, h, i, j, k, l, ..
			Int(a * bx + e * by + i * bz + m), ..
			Int(b * bx + f * by + j * bz + n), ..
			Int(c * bx + g * by + k * bz + o), ..
			Int(d * bx + h * by + l * bz + p))
	End Method

	Rem
	bbdoc: Translates the matrix To @s.
	End Rem
	Method Translate:SMat4I(s:SVec3F)
		Local bx:Float = s.x
		Local by:Float = s.y
		Local bz:Float = s.z
		Return New SMat4I(a, b, c, d, e, f, g, h, i, j, k, l, ..
			Int(a * bx + e * by + i * bz + m), ..
			Int(b * bx + f * by + j * bz + n), ..
			Int(c * bx + g * by + k * bz + o), ..
			Int(d * bx + h * by + l * bz + p))
	End Method

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4I(s:SVec3I)
		Return New SMat4I(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			s.x, s.y, s.z, 1)
	End Function

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4I(s:SVec3D)
		Return New SMat4I(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			Int(s.x), Int(s.y), Int(s.z), 1)
	End Function

	Rem
	bbdoc: Creates a translation matrix.
	End Rem
	Function Translation:SMat4I(s:SVec3F)
		Return New SMat4I(1, 0, 0, 0, ..
			0, 1, 0, 0, ..
			0, 0, 1, 0, ..
			Int(s.x), Int(s.y), Int(s.z), 1)
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
