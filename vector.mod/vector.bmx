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
bbdoc: Math/Vector
End Rem
Module BRL.Vector

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2019-2020 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Math
Import BRL.StringBuilder

Rem
bbdoc: A 2-element structure that can be used to represent positions and directions in 2D-space.
End Rem
Struct SVec2D
	Field ReadOnly x:Double
	Field ReadOnly y:Double
	
	Rem
	bbdoc: Creates a new #SVec2D from the supplied arguments.
	End Rem
	Method New(x:Double, y:Double)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Returns #True if @b is different.
	End Rem
	Method Operator<>:Int(b:SVec2D)
		Return x <> b.x Or y <> b.y
	End Method

	Rem
	bbdoc: Returns #True if the vector and @b are aproximately equal.
	End Rem
	Method Operator=:Int(b:SVec2D)
		Return (Self - b).LengthSquared() < 0.00000001
	End Method

	Rem
	bbdoc: Adds @b to the vector, returning a new vector.
	End Rem
	Method Operator+:SVec2D(b:SVec2D)
		Return New SVec2D(x + b.x, y + b.y)
	End Method
	
	Rem
	bbdoc: Subtracts @b from the vector, returning a new vector.
	End Rem
	Method Operator-:SVec2D(b:SVec2D)
		Return New SVec2D(x - b.x, y - b.y)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec2D(b:SVec2D)
		Return New SVec2D(x * b.x, y * b.y)
	End Method

	Rem
	bbdoc: Divides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec2D(b:SVec2D)
		Return New SVec2D(x / b.x, y / b.y)
	End Method
	
	Rem
	bbdoc: Returns a new vector, negated.
	End Rem
	Method Operator-:SVec2D()
		Return New SVec2D(-x, -y)
	End Method

	Rem
	bbdoc: Scales the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec2D(s:Double)
		Return New SVec2D(x * s, y * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec2D(s:Double)
		Return New SVec2D(x / s, y / s)
	End Method
	
	Rem
	bbdoc: Retrieves the x or y component using [0] or [1] respectively.
	End Rem
	Method Operator[]:Double(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
		End Select
		
		Throw New TArrayBoundsException
	End Method
	
	Rem
	bbdoc: Returns the unsigned angle between this vector and @b.
	End Rem
	Method AngleTo:Double(b:SVec2D)
		Local d:Double = Sqr(LengthSquared() * b.LengthSquared())

		If d < 1e-15 Then
			Return 0
		End If

		Local dot:Double = Clamp(Self.Dot(b) / d, -1, 1)
		Return _acos(dot)
	End Method
		
	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec2D(minv:SVec2D, maxv:SVec2D)
		Return New SVec2D(Clamp(x, minv.x, maxv.x), Clamp(y, minv.y, maxv.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec2D(b:SVec2D)
		Return New SVec2D(Min(x, b.x), Min(y, b.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec2D(b:SVec2D)
		Return New SVec2D(Max(x, b.x), Max(y, b.y))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec2D(b:SVec2D, t:Double)
		Return New SVec2D(Lerp(x, b.x, t), Lerp(y, b.y, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec2D()
		Local length:Double = x * x + y * y
		If length > 0 Then
			length = Sqr(length)
			Return New SVec2D(x / length, y / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors #Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Double(b:SVec2D)
		Return x * b.x + y * b.y
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Double()
		Return Sqr(LengthSquared())
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Double()
		Return x * x + y * y
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector And @b.
	End Rem
	Method DistanceTo:Double(b:SVec2D)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Double(b:SVec2D)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector perpendicular to the vector.
	End Rem
	Method Perpendicular:SVec2D()
		Return New SVec2D(-y, x)
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec2D(n:SVec2D)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: Returns a vector rotated by @angle degrees.
	End Rem
	Method Rotate:SVec2D(angle:Double)
		Return New SVec2D(x * Cos(angle) - y * Sin(angle), x * Sin(angle) + y * Cos(angle))
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder

		sb.Append("(")
		sb.Append(x).Append(", ").Append(y)
		sb.Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: A 3-element structure that can be used to represent positions and directions in 3D-space.
End Rem
Struct SVec3D
	Field ReadOnly x:Double
	Field ReadOnly y:Double
	Field ReadOnly z:Double
	
	Rem
	bbdoc: Creates a new #SVec3D from the supplied arguments.
	End Rem
	Method New(x:Double, y:Double, z:Double)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec3D(b:SVec3D)
		Return New SVec3D(x + b.x, y + b.y, z + b.z)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec3D(b:SVec3D)
		Return New SVec3D(x - b.x, y - b.y, z - b.z)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec3D(b:SVec3D)
		Return New SVec3D(x * b.x, y * b.y, z * b.z)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec3D(b:SVec3D)
		Return New SVec3D(x / b.x, y / b.y, z / b.z)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec3D()
		Return New SVec3D(-x, -y, -z)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec3D(s:Double)
		Return New SVec3D(x * s, y * s, z * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec3D(s:Double)
		Return New SVec3D(x / s, y / s, z/s)
	End Method

	Rem
	bbdoc: Retrieves the x, y or z component using [0], [1] or [2] respectively.
	End Rem
	Method Operator[]:Double(index:Int)
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
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec3D(minv:SVec3D, maxv:SVec3D)
		Return New SVec3D(Clamp(x, minv.x, maxv.x), Clamp(y, minv.y, maxv.y), Clamp(z, minv.z, maxv.z))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec3D(b:SVec3D)
		Return New SVec3D(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec3D(b:SVec3D)
		Return New SVec3D(Min(x, b.x), Min(y, b.y), Min(z, b.z))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec3D(b:SVec3D)
		Return New SVec3D(Max(x, b.x), Max(y, b.y), Max(z, b.z))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec3D(b:SVec3D, t:Double)
		Return New SVec3D(Lerp(x, b.x, t), Lerp(y, b.y, t), Lerp(z, b.z, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec3D()
		Local length:Double = x * x + y * y + z * z
		If length > 0 Then
			length = Sqr(length)
			Return New SVec3D(x / length, y / length, z / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Double(b:SVec3D)
		Return x * b.x + y * b.y + z * b.z
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Double()
		Return Float(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Double()
		Return x * x + y * y + z * z
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method DistanceTo:Double(b:SVec3D)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Double(b:SVec3D)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec3D(n:SVec3D)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec3D(b:SVec3D)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z)
		sb.Append(")")
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A 4-element structure.
End Rem
Struct SVec4D
	Field ReadOnly x:Double
	Field ReadOnly y:Double
	Field ReadOnly z:Double
	Field ReadOnly w:Double
	
	Rem
	bbdoc: Creates a new #SVec4D from the supplied arguments.
	End Rem
	Method New(x:Double, y:Double, z:Double, w:Double)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec4D(b:SVec4D)
		Return New SVec4D(x + b.x, y + b.y, z + b.z, w + b.w)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec4D(b:SVec4D)
		Return New SVec4D(x - b.x, y - b.y, z - b.z, w - b.w)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec4D(b:SVec4D)
		Return New SVec4D(x * b.x, y * b.y, z * b.z, w * b.w)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec4D(b:SVec4D)
		Return New SVec4D(x / b.x, y / b.y, z / b.z, w / b.w)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec4D()
		Return New SVec4D(-x, -y, -z, -w)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec4D(s:Double)
		Return New SVec4D(x * s, y * s, z * s, w * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec4D(s:Double)
		Return New SVec4D(x / s, y / s, z/s, w/s)
	End Method

	Rem
	bbdoc: Retrieves the x, y, z or w component using [0], [1], [2] or [3] respectively.
	End Rem
	Method Operator[]:Double(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
			Case 2
				Return z
			Case 3
				Return w
		End Select
		
		Throw New TArrayBoundsException
	End Method

	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec4D(minv:SVec4D, maxv:SVec4D)
		Return New SVec4D(Clamp(x, minv.x, maxv.x), Clamp(y, minv.y, maxv.y), Clamp(z, minv.z, maxv.z), Clamp(w, minv.w, maxv.w))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec4D(b:SVec4D)
		Return New SVec4D(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x, Sqr(w * b.w))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec4D(b:SVec4D)
		Return New SVec4D(Min(x, b.x), Min(y, b.y), Min(z, b.z), Min(w, b.w))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec4D(b:SVec4D)
		Return New SVec4D(Max(x, b.x), Max(y, b.y), Max(z, b.z), Max(w, b.w))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec4D(b:SVec4D, t:Double)
		Return New SVec4D(Lerp(x, b.x, t), Lerp(y, b.y, t), Lerp(z, b.z, t), Lerp(w, b.w, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec4D()
		Local length:Double = x * x + y * y + z * z + w * w
		If length > 0 Then
			length = Sqr(length)
			Return New SVec4D(x / length, y / length, z / length, w / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Double(b:SVec4D)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Double()
		Return Float(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Double()
		Return x * x + y * y + z * z + w * w
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method DistanceTo:Double(b:SVec4D)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Double(b:SVec4D)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec4D(n:SVec4D)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec4D(b:SVec4D)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z).Append(", ")
		sb.Append(w)
		sb.Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: A #Float backed 2-element structure that can be used to represent positions and directions in 2D-space.
End Rem
Struct SVec2F
	Field ReadOnly x:Float
	Field ReadOnly y:Float
	
	Rem
	bbdoc: Creates a new #SVec2F from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Returns #True if @b is different.
	End Rem
	Method Operator<>:Int(b:SVec2F)
		Return x <> b.x Or y <> b.y
	End Method

	Rem
	bbdoc: Returns #True if the vector and @b are aproximately equal.
	End Rem
	Method Operator=:Int(b:SVec2F)
		Return (Self - b).LengthSquared() < 0.00000001
	End Method

	Rem
	bbdoc: Adds @b to the vector, returning a new vector.
	End Rem
	Method Operator+:SVec2F(b:SVec2F)
		Return New SVec2F(x + b.x, y + b.y)
	End Method
	
	Rem
	bbdoc: Subtracts @b from the vector, returning a new vector.
	End Rem
	Method Operator-:SVec2F(b:SVec2F)
		Return New SVec2F(x - b.x, y - b.y)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec2F(b:SVec2F)
		Return New SVec2F(x * b.x, y * b.y)
	End Method

	Rem
	bbdoc: Divides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec2F(b:SVec2F)
		Return New SVec2F(x / b.x, y / b.y)
	End Method
	
	Rem
	bbdoc: Returns a new vector, negated.
	End Rem
	Method Operator-:SVec2F()
		Return New SVec2F(-x, -y)
	End Method

	Rem
	bbdoc: Scales the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec2F(s:Float)
		Return New SVec2F(x * s, y * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec2F(s:Float)
		Return New SVec2F(x / s, y / s)
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
	bbdoc: Returns the unsigned angle between this vector and @b.
	End Rem
	Method AngleTo:Float(b:SVec2F)
		Local d:Float = Sqr(LengthSquared() * b.LengthSquared())

		If d < 1e-15 Then
			Return 0
		End If

		Local dot:Float = ClampF(Self.Dot(b) / d, -1, 1)
		Return _acos(dot)
	End Method
		
	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec2F(minv:SVec2F, maxv:SVec2F)
		Return New SVec2F(ClampF(x, minv.x, maxv.x), ClampF(y, minv.y, maxv.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec2F(b:SVec2F)
		Return New SVec2F(MinF(x, b.x), MinF(y, b.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec2F(b:SVec2F)
		Return New SVec2F(MaxF(x, b.x), MaxF(y, b.y))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec2F(b:SVec2F, t:Float)
		Return New SVec2F(LerpF(x, b.x, t), LerpF(y, b.y, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec2F()
		Local length:Float = x * x + y * y
		If length > 0 Then
			length = Sqr(length)
			Return New SVec2F(x / length, y / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors #Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Float(b:SVec2F)
		Return x * b.x + y * b.y
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Float()
		Return Float(Sqr(LengthSquared()))
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
	Method DistanceTo:Float(b:SVec2F)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector And @b.
	End Rem
	Method DistanceToSquared:Float(b:SVec2F)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector perpendicular to the vector.
	End Rem
	Method Perpendicular:SVec2F()
		Return New SVec2F(-y, x)
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec2F(n:SVec2F)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: Returns a vector rotated by @angle degrees.
	End Rem
	Method Rotate:SVec2F(angle:Double)
		Return New SVec2F(Float(x * Cos(angle) - y * Sin(angle)), Float(x * Sin(angle) + y * Cos(angle)))
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder

		sb.Append("(")
		sb.Append(x).Append(", ").Append(y)
		sb.Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: A #Float backed 3-element structure that can be used to represent positions and directions in 3D-space.
End Rem
Struct SVec3F
	Field ReadOnly x:Float
	Field ReadOnly y:Float
	Field ReadOnly z:Float
	
	Rem
	bbdoc: Creates a New #SVec3F from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float, z:Float)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec3F(b:SVec3F)
		Return New SVec3F(x + b.x, y + b.y, z + b.z)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec3F(b:SVec3F)
		Return New SVec3F(x - b.x, y - b.y, z - b.z)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec3F(b:SVec3F)
		Return New SVec3F(x * b.x, y * b.y, z * b.z)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec3F(b:SVec3F)
		Return New SVec3F(x / b.x, y / b.y, z / b.z)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec3F()
		Return New SVec3F(-x, -y, -z)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec3F(s:Float)
		Return New SVec3F(x * s, y * s, z * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec3F(s:Float)
		Return New SVec3F(x / s, y / s, z / s)
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
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec3F(minv:SVec3F, maxv:SVec3F)
		Return New SVec3F(ClampF(x, minv.x, maxv.x), ClampF(y, minv.y, maxv.y), ClampF(z, minv.z, maxv.z))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec3F(b:SVec3F)
		Return New SVec3F(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec3F(b:SVec3F)
		Return New SVec3F(MinF(x, b.x), MinF(y, b.y), MinF(z, b.z))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec3F(b:SVec3F)
		Return New SVec3F(MaxF(x, b.x), MaxF(y, b.y), MaxF(z, b.z))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec3F(b:SVec3F, t:Float)
		Return New SVec3F(LerpF(x, b.x, t), LerpF(y, b.y, t), LerpF(z, b.z, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec3F()
		Local length:Float = x * x + y * y + z * z
		If length > 0 Then
			length = Sqr(length)
			Return New SVec3F(x / length, y / length, z / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Float(b:SVec3F)
		Return x * b.x + y * b.y + z * b.z
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Float()
		Return Float(Sqr(LengthSquared()))
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
	Method DistanceTo:Float(b:SVec3F)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Float(b:SVec3F)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec3F(n:SVec3F)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec3F(b:SVec3F)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z)
		sb.Append(")")
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A 4-element structure.
End Rem
Struct SVec4F
	Field ReadOnly x:Float
	Field ReadOnly y:Float
	Field ReadOnly z:Float
	Field ReadOnly w:Float
	
	Rem
	bbdoc: Creates a new #SVec4F from the supplied arguments.
	End Rem
	Method New(x:Float, y:Float, z:Float, w:Float)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec4F(b:SVec4F)
		Return New SVec4F(x + b.x, y + b.y, z + b.z, w + b.w)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec4F(b:SVec4F)
		Return New SVec4F(x - b.x, y - b.y, z - b.z, w - b.w)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec4F(b:SVec4F)
		Return New SVec4F(x * b.x, y * b.y, z * b.z, w * b.w)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec4F(b:SVec4F)
		Return New SVec4F(x / b.x, y / b.y, z / b.z, w / b.w)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec4F()
		Return New SVec4F(-x, -y, -z, -w)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec4F(s:Float)
		Return New SVec4F(x * s, y * s, z * s, w * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec4F(s:Float)
		Return New SVec4F(x / s, y / s, z/s, w/s)
	End Method

	Rem
	bbdoc: Retrieves the x, y, z or w component using [0], [1], [2] or [3] respectively.
	End Rem
	Method Operator[]:Float(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
			Case 2
				Return z
			Case 3
				Return w
		End Select
		
		Throw New TArrayBoundsException
	End Method

	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec4F(minv:SVec4F, maxv:SVec4F)
		Return New SVec4F(ClampF(x, minv.x, maxv.x), ClampF(y, minv.y, maxv.y), ClampF(z, minv.z, maxv.z), ClampF(w, minv.w, maxv.w))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec4F(b:SVec4F)
		Return New SVec4F(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x, Float(Sqr(w * b.w)))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec4F(b:SVec4F)
		Return New SVec4F(Min(x, b.x), Min(y, b.y), Min(z, b.z), Min(w, b.w))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec4F(b:SVec4F)
		Return New SVec4F(Max(x, b.x), Max(y, b.y), Max(z, b.z), Max(w, b.w))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec4F(b:SVec4F, t:Float)
		Return New SVec4F(LerpF(x, b.x, t), LerpF(y, b.y, t), LerpF(z, b.z, t), LerpF(w, b.w, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec4F()
		Local length:Float = x * x + y * y + z * z + w * w
		If length > 0 Then
			length = Sqr(length)
			Return New SVec4F(x / length, y / length, z / length, w / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Float(b:SVec4F)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Float()
		Return Float(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Float()
		Return x * x + y * y + z * z + w * w
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method DistanceTo:Float(b:SVec4F)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Float(b:SVec4F)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec4F(n:SVec4F)
		Return n * Dot(n) * 2.0 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec4F(b:SVec4F)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z).Append(", ")
		sb.Append(w)
		sb.Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: An #Int backed 2-element structure that can be used to represent positions and directions in 2D-space.
End Rem
Struct SVec2I
	Field ReadOnly x:Int
	Field ReadOnly y:Int
	
	Rem
	bbdoc: Creates a new #SVec2I from the supplied arguments.
	End Rem
	Method New(x:Int, y:Int)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Returns #True if @b is different.
	End Rem
	Method Operator<>:Int(b:SVec2I)
		Return x <> b.x Or y <> b.y
	End Method

	Rem
	bbdoc: Returns #True if the vector and @b are aproximately equal.
	End Rem
	Method Operator=:Int(b:SVec2I)
		Return (Self - b).LengthSquared() < 0.00000001
	End Method

	Rem
	bbdoc: Adds @b to the vector, returning a new vector.
	End Rem
	Method Operator+:SVec2I(b:SVec2I)
		Return New SVec2I(x + b.x, y + b.y)
	End Method
	
	Rem
	bbdoc: Subtracts @b from the vector, returning a new vector.
	End Rem
	Method Operator-:SVec2I(b:SVec2I)
		Return New SVec2I(x - b.x, y - b.y)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec2I(b:SVec2I)
		Return New SVec2I(x * b.x, y * b.y)
	End Method

	Rem
	bbdoc: Divides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec2I(b:SVec2I)
		Return New SVec2I(x / b.x, y / b.y)
	End Method
	
	Rem
	bbdoc: Returns a new vector, negated.
	End Rem
	Method Operator-:SVec2I()
		Return New SVec2I(-x, -y)
	End Method

	Rem
	bbdoc: Scales the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec2I(s:Int)
		Return New SVec2I(x * s, y * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec2I(s:Int)
		Return New SVec2I(x / s, y / s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec2I(s:Float)
		Return New SVec2I(Int(x / s), Int(y / s))
	End Method
	
	Rem
	bbdoc: Retrieves the x or y component using [0] or [1] respectively.
	End Rem
	Method Operator[]:Int(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
		End Select
		
		Throw New TArrayBoundsException
	End Method
		
	Rem
	bbdoc: Returns the unsigned angle between this vector and @b.
	End Rem
	Method AngleTo:Int(b:SVec2I)
		Local d:Double = Sqr(LengthSquared() * b.LengthSquared())

		If d < 1e-15 Then
			Return 0
		End If

		Local dot:Double = Clamp(Self.Dot(b) / d, -1, 1)
		Return Int(_acos(dot))
	End Method
		
	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec2I(minv:SVec2I, maxv:SVec2I)
		Return New SVec2I(ClampI(x, minv.x, maxv.x), ClampI(y, minv.y, maxv.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec2I(b:SVec2I)
		Return New SVec2I(MinI(x, b.x), MinI(y, b.y))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec2I(b:SVec2I)
		Return New SVec2I(MaxI(x, b.x), MaxI(y, b.y))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec2I(b:SVec2I, t:Int)
		Return New SVec2I(LerpI(x, b.x, t), LerpI(y, b.y, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec2I()
		Local length:Int = x * x + y * y
		If length > 0 Then
			length = Sqr(length)
			Return New SVec2I(x / length, y / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors #Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Int(b:SVec2I)
		Return x * b.x + y * b.y
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Int()
		Return Int(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Int()
		Return x * x + y * y
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector And @b.
	End Rem
	Method DistanceTo:Int(b:SVec2I)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Int(b:SVec2I)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector perpendicular to the vector.
	End Rem
	Method Perpendicular:SVec2I()
		Return New SVec2I(-y, x)
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec2I(n:SVec2I)
		Return n * Dot(n) * 2 - Self
	End Method

	Rem
	bbdoc: Returns a vector rotated by @angle degrees.
	End Rem
	Method Rotate:SVec2I(angle:Double)
		Return New SVec2I(Int(x * Cos(angle) - y * Sin(angle)), Int(x * Sin(angle) + y * Cos(angle)))
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder

		sb.Append("(")
		sb.Append(x).Append(", ").Append(y)
		sb.Append(")")
		
		Return sb.ToString()
	End Method

End Struct

Rem
bbdoc: An #Int backed 3-element structure that can be used to represent positions and directions in 3D-space.
End Rem
Struct SVec3I
	Field ReadOnly x:Int
	Field ReadOnly y:Int
	Field ReadOnly z:Int
	
	Rem
	bbdoc: Creates a new #SVec3I from the supplied arguments.
	End Rem
	Method New(x:Int, y:Int, z:Int)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec3I(b:SVec3I)
		Return New SVec3I(x + b.x, y + b.y, z + b.z)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec3I(b:SVec3I)
		Return New SVec3I(x - b.x, y - b.y, z - b.z)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec3I(b:SVec3I)
		Return New SVec3I(x * b.x, y * b.y, z * b.z)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec3I(b:SVec3I)
		Return New SVec3I(x / b.x, y / b.y, z / b.z)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec3I()
		Return New SVec3I(-x, -y, -z)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec3I(s:Int)
		Return New SVec3I(x * s, y * s, z * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec3I(s:Int)
		Return New SVec3I(x / s, y / s, z / s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec3I(s:Float)
		Return New SVec3I(Int(x / s), Int(y / s), Int(z / s))
	End Method

	Rem
	bbdoc: Retrieves the x, y or z component using [0], [1] or [2] respectively.
	End Rem
	Method Operator[]:Int(index:Int)
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
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec3I(minv:SVec3I, maxv:SVec3I)
		Return New SVec3I(ClampI(x, minv.x, maxv.x), ClampI(y, minv.y, maxv.y), ClampI(z, minv.z, maxv.z))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec3I(b:SVec3I)
		Return New SVec3I(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec3I(b:SVec3I)
		Return New SVec3I(MinI(x, b.x), MinI(y, b.y), MinI(z, b.z))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec3I(b:SVec3I)
		Return New SVec3I(MaxI(x, b.x), MaxI(y, b.y), MaxI(z, b.z))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec3I(b:SVec3I, t:Int)
		Return New SVec3I(LerpI(x, b.x, t), LerpI(y, b.y, t), LerpI(z, b.z, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec3I()
		Local length:Int = x * x + y * y + z * z
		If length > 0 Then
			length = Sqr(length)
			Return New SVec3I(x / length, y / length, z / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Int(b:SVec3I)
		Return x * b.x + y * b.y + z * b.z
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Int()
		Return Int(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Int()
		Return x * x + y * y + z * z
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method DistanceTo:Int(b:SVec3I)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Int(b:SVec3I)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec3I(n:SVec3I)
		Return n * Dot(n) * 2 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec3I(b:SVec3I)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z)
		sb.Append(")")
		
		Return sb.ToString()
	End Method
	
End Struct

Rem
bbdoc: A 4-element structure.
End Rem
Struct SVec4I
	Field ReadOnly x:Int
	Field ReadOnly y:Int
	Field ReadOnly z:Int
	Field ReadOnly w:Int
	
	Rem
	bbdoc: Creates a new #SVec4I from the supplied arguments.
	End Rem
	Method New(x:Int, y:Int, z:Int, w:Int)
		Self.x = x
		Self.y = y
		Self.z = z
		Self.w = w
	End Method
	
	Rem
	bbdoc: Adds @b to this vector, returning a new vector.
	End Rem
	Method Operator+:SVec4I(b:SVec4I)
		Return New SVec4I(x + b.x, y + b.y, z + b.z, w + b.w)
	End Method
	
	Rem
	bbdoc: Subtracts @b from this vector, returning a new vector.
	End Rem
	Method Operator-:SVec4I(b:SVec4I)
		Return New SVec4I(x - b.x, y - b.y, z - b.z, w - b.w)
	End Method
	
	Rem
	bbdoc: Multiplies the vector by @b, returning a new vector.
	End Rem
	Method Operator*:SVec4I(b:SVec4I)
		Return New SVec4I(x * b.x, y * b.y, z * b.z, w * b.w)
	End Method

	Rem
	bbdoc: Devides the vector by @b, returning a new vector.
	End Rem
	Method Operator/:SVec4I(b:SVec4I)
		Return New SVec4I(x / b.x, y / b.y, z / b.z, w / b.w)
	End Method
	
	Rem
	bbdoc: Returns a negated version of this vector.
	End Rem
	Method Operator-:SVec4I()
		Return New SVec4I(-x, -y, -z, -w)
	End Method

	Rem
	bbdoc: Multiplies the vector by @s, returning a new vector.
	End Rem
	Method Operator*:SVec4I(s:Int)
		Return New SVec4I(x * s, y * s, z * s, w * s)
	End Method

	Rem
	bbdoc: Divides the vector by @s, returning a new vector.
	End Rem
	Method Operator/:SVec4I(s:Int)
		Return New SVec4I(x / s, y / s, z/s, w/s)
	End Method

	Rem
	bbdoc: Retrieves the x, y, z or w component using [0], [1], [2] or [3] respectively.
	End Rem
	Method Operator[]:Int(index:Int)
		Select index
			Case 0
				Return x
			Case 1
				Return y
			Case 2
				Return z
			Case 3
				Return w
		End Select
		
		Throw New TArrayBoundsException
	End Method

	Rem
	bbdoc: Returns a vector clamped between the vectors @minv and @maxv.
	End Rem
	Method Clamp:SVec4I(minv:SVec4I, maxv:SVec4I)
		Return New SVec4I(ClampI(x, minv.x, maxv.x), ClampI(y, minv.y, maxv.y), ClampI(z, minv.z, maxv.z), ClampI(w, minv.w, maxv.w))
	End Method
	
	Rem
	bbdoc: Returns the Cross Product of the two vectors.
	End Rem
	Method Cross:SVec4I(b:SVec4I)
		Return New SVec4I(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x, Int(Sqr(w * b.w)))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the smallest components of the two vectors.
	End Rem
	Method Min:SVec4I(b:SVec4I)
		Return New SVec4I(Min(x, b.x), Min(y, b.y), Min(z, b.z), Min(w, b.w))
	End Method
	
	Rem
	bbdoc: Returns a vector that is made from the largest components of the two vectors.
	End Rem
	Method Max:SVec4I(b:SVec4I)
		Return New SVec4I(Max(x, b.x), Max(y, b.y), Max(z, b.z), Max(w, b.w))
	End Method
	
	Rem
	bbdoc: Linearly interpolates between two vectors.
	about: Interpolates between this vector and @b by the interpolant @t.
	This is commonly used to find a point some fraction of the way along a line between two endpoints (e.g. to move an object gradually between those points).
	End Rem
	Method Interpolate:SVec4I(b:SVec4I, t:Int)
		Return New SVec4I(LerpI(x, b.x, t), LerpI(y, b.y, t), LerpI(z, b.z, t), LerpI(w, b.w, t))
	End Method
	
	Rem
	bbdoc: Returns a vector with a magnitude of 1.
	about: When normalized, a vector keeps the same direction but its length is 1.0.
	End Rem
	Method Normal:SVec4I()
		Local length:Int = x * x + y * y + z * z + w * w
		If length > 0 Then
			length = Sqr(length)
			Return New SVec4I(x / length, y / length, z / length, w / length)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the dot product of two vectors.
	about: For normalized vectors Dot returns 1 if they point in exactly the same direction, -1 if they point in completely opposite directions,
	and a number in between for other cases (e.g. Dot returns zero if vectors are perpendicular).
	End Rem
	Method Dot:Int(b:SVec4I)
		Return x * b.x + y * b.y + z * b.z + w * b.w
	End Method
	
	Rem
	bbdoc: Returns the length of the vector.
	End Rem
	Method Length:Int()
		Return Int(Sqr(LengthSquared()))
	End Method
	
	Rem
	bbdoc: Returns the squared length of the vector.
	about: Calculating the squared length instead of the length is much faster.
	Often if you are comparing lengths of two vectors you can just compare their squared lengths.
	End Rem
	Method LengthSquared:Int()
		Return x * x + y * y + z * z + w * w
	End Method
	
	Rem
	bbdoc: Returns the distance between the vector and @b.
	End Rem
	Method DistanceTo:Int(b:SVec4I)
		Return (Self - b).Length()
	End Method
	
	Rem
	bbdoc: Returns the squared distance between the vector and @b.
	End Rem
	Method DistanceToSquared:Int(b:SVec4I)
		Return (Self - b).LengthSquared()
	End Method
	
	Rem
	bbdoc: Returns a vector reflected from the given plane, specified by its normal vector.
	End Rem
	Method Reflect:SVec4I(n:SVec4I)
		Return n * Dot(n) * 2 - Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Orthogonal:SVec4I(b:SVec4I)
		Return Cross(b).Normal()
	End Method

	Rem
	bbdoc: Returns a #String representation of the vector.
	End Rem
	Method ToString:String() Override
		Local sb:TStringBuilder = New TStringBuilder
		
		sb.Append("(")
		sb.Append(x).Append(", ")
		sb.Append(y).Append(", ")
		sb.Append(z).Append(", ")
		sb.Append(w)
		sb.Append(")")
		
		Return sb.ToString()
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

Function MinI:Int(a:Int, b:Int)
	If b < a Then
		Return b
	End If
	Return a
End Function

Function MaxI:Int(a:Int, b:Int)
	If b > a Then
		Return b
	End If
	Return a
End Function

Function Lerp:Double(a:Double, b:Double, t:Double)
	Return a + (b - a) * t
End Function

Function LerpF:Float(a:Float, b:Float, t:Float)
	Return a + (b - a) * t
End Function

Function LerpI:Int(a:Int, b:Int, t:Int)
	Return a + (b - a) * t
End Function

Function Clamp:Double(a:Double, mind:Double, maxd:Double)
	If a < mind Then
		Return mind
	Else If a > maxd Then
		Return maxd
	End If
	Return a
End Function

Function ClampF:Float(a:Float, minf:Float, maxf:Float)
	If a < minf Then
		Return minf
	Else If a > maxf Then
		Return maxf
	End If
	Return a
End Function

Function ClampI:Int(a:Int, mini:Int, maxi:Int)
	If a < mini Then
		Return mini
	Else If a > maxi Then
		Return maxi
	End If
	Return a
End Function

Extern
	Function _acos:Double(x:Double)="double bbACos(double)!"
End Extern
Public
