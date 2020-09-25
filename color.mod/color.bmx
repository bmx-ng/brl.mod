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
bbdoc: Graphics/Colors
End Rem
Module BRL.Color

Rem
bbdoc: An RGBA color with 8-bit components.
End Rem
Struct SColor8
	Field ReadOnly b:Byte
	Field ReadOnly g:Byte
	Field ReadOnly r:Byte
	Field ReadOnly a:Byte
	
	Rem
	bbdoc: Creates an #SColor8 instance using the specified @r, @g, @b and @a components.
	End Rem
	Method New(r:Byte, g:Byte, b:Byte, a:Byte = 255)
		Self.r = r
		Self.g = g
		Self.b = b
		Self.a = a
	End Method

	Method New(r:Int, g:Int, b:Int, a:Int = 255)
		Self.r = r
		Self.g = g
		Self.b = b
		Self.a = a
	End Method
	
	Rem
	bbdoc: Creates an #SColor8 instance using the specified 32-bit RGBA value.
	End Rem
	Method New(rgba:Int)
		Int Ptr(Varptr b)[0] = rgba
	End Method
	
	Rem
	bbdoc: Returns the color as a 32-bit RGBA value.
	End Rem
	Method ToRGBA:Int()
		Return Int Ptr(Varptr b)[0]
	End Method
	
	Rem
	bbdoc: Returns the color as a 32-bit ARGB value.
	End Rem
	Method ToARGB:Int()
		Return r Shl 16 | g Shl 8 | b | a Shl 24 
	End Method
	
	Rem
	bbdoc: Calculates the Hue-Saturation-Luminance (HSL) of the color.
	End Rem
	Method ToHSL(hue:Float Var, saturation:Float Var, luminance:Float Var)
		ToHSVL(hue, saturation, luminance, False)	
	End Method
	
	Rem
	bbdoc: Calculates the Hue-Saturation-Value (HSV) of the color.
	End Rem
	Method ToHSV(hue:Float Var, saturation:Float Var, value:Float Var)
		ToHSVL(hue, saturation, value, True)	
	End Method
	
	Rem
	bbdoc: Returns #True if the components of this color and @col are equal.
	End Rem
	Method Operator = :Int(col:SColor8)
		Return r = col.r And g = col.g And b = col.b And a = col.a
	End Method

	Rem
	bbdoc: Returns #True if the components of this color and @col are not equal.
	End Rem
	Method Operator <> :Int(col:SColor8)
		Return r <> col.r Or g <> col.g Or b <> col.b Or a <> col.a
	End Method
	
Private
	Method ToHSVL(hue:Float Var, saturation:Float Var, value:Float Var, isValue:Int)
		Local rf:Float = r / 255.0
		Local gf:Float = g / 255.0
		Local bf:Float = b / 255.0
		
		Local maxVal:Float = rf
		Local minVal:Float = rf
		
		If gf > maxVal Then
			maxVal = gf
		End If
		
		If bf > maxVal Then
			maxVal = bf
		End If
		
		If gf < minVal Then
			minVal = gf
		End If
		
		If bf < minVal Then
			minVal = bf
		End If

		Local luminance:Float = (maxVal + minVal) / 2
		If isValue Then
			value = maxVal
		Else
			value = luminance
		End If
		Local delta:Float = maxVal - minVal

		If delta <> 0 Then
			If luminance <= 0.5 Then
				saturation = Min(1, (maxVal - minVal) / (maxVal + minVal))
			Else
				saturation = Min(1, (maxVal - minVal) / (2 - maxVal - minVal))
			End If
		Else
			saturation = 0
		End If
		
		If r = g And r = b Then
			hue = 0
		Else
			If rf = maxVal Then
				hue = (gf - bf) / delta
			Else If gf = maxVal Then
				hue = 2 + (bf - rf) / delta
			Else If bf = maxVal Then
				hue = 4 + (rf - gf) / delta
			End If
			hue :* 60
			
			If hue < 0 Then
				hue :+ 360
			End If
		End If		
	End Method
Public

	Global AliceBlue:SColor8 = New SColor8($FFF0F8FF)
	Global AntiqueWhite:SColor8 = New SColor8($FFFAEBD7)
	Global Aqua:SColor8 = New SColor8($FF00FFFF)
	Global Aquamarine:SColor8 = New SColor8($FF7FFFD4)
	Global Azure:SColor8 = New SColor8($FFF0FFFF)
	Global Beige:SColor8 = New SColor8($FFF5F5DC)
	Global Bisque:SColor8 = New SColor8($FFFFE4C4)
	Global Black:SColor8 = New SColor8($FF000000)
	Global BlanchedAlmond:SColor8 = New SColor8($FFFFEBCD)
	Global Blue:SColor8 = New SColor8($FF0000FF)
	Global BlueViolet:SColor8 = New SColor8($FF8A2BE2)
	Global Brown:SColor8 = New SColor8($FFA52A2A)
	Global BurlyWood:SColor8 = New SColor8($FFDEB887)
	Global CadetBlue:SColor8 = New SColor8($FF5F9EA0)
	Global Chartreuse:SColor8 = New SColor8($FF7FFF00)
	Global Chocolate:SColor8 = New SColor8($FFD2691E)
	Global Coral:SColor8 = New SColor8($FFFF7F50)
	Global CornflowerBlue:SColor8 = New SColor8($FF6495ED)
	Global Cornsilk:SColor8 = New SColor8($FFFFF8DC)
	Global Crimson:SColor8 = New SColor8($FFDC143C)
	Global Cyan:SColor8 = New SColor8($FF00FFFF)
	Global DarkBlue:SColor8 = New SColor8($FF00008B)
	Global DarkCyan:SColor8 = New SColor8($FF008B8B)
	Global DarkGoldenRod:SColor8 = New SColor8($FFB8860B)
	Global DarkGray:SColor8 = New SColor8($FFA9A9A9)
	Global DarkGrey:SColor8 = New SColor8($FFA9A9A9)
	Global DarkGreen:SColor8 = New SColor8($FF006400)
	Global DarkKhaki:SColor8 = New SColor8($FFBDB76B)
	Global DarkMagenta:SColor8 = New SColor8($FF8B008B)
	Global DarkOliveGreen:SColor8 = New SColor8($FF556B2F)
	Global DarkOrange:SColor8 = New SColor8($FFFF8C00)
	Global DarkOrchid:SColor8 = New SColor8($FF9932CC)
	Global DarkRed:SColor8 = New SColor8($FF8B0000)
	Global DarkSalmon:SColor8 = New SColor8($FFE9967A)
	Global DarkSeaGreen:SColor8 = New SColor8($FF8FBC8F)
	Global DarkSlateBlue:SColor8 = New SColor8($FF483D8B)
	Global DarkSlateGray:SColor8 = New SColor8($FF2F4F4F)
	Global DarkSlateGrey:SColor8 = New SColor8($FF2F4F4F)
	Global DarkTurquoise:SColor8 = New SColor8($FF00CED1)
	Global DarkViolet:SColor8 = New SColor8($FF9400D3)
	Global DeepPink:SColor8 = New SColor8($FFFF1493)
	Global DeepSkyBlue:SColor8 = New SColor8($FF00BFFF)
	Global DimGray:SColor8 = New SColor8($FF696969)
	Global DimGrey:SColor8 = New SColor8($FF696969)
	Global DodgerBlue:SColor8 = New SColor8($FF1E90FF)
	Global FireBrick:SColor8 = New SColor8($FFB22222)
	Global FloralWhite:SColor8 = New SColor8($FFFFFAF0)
	Global ForestGreen:SColor8 = New SColor8($FF228B22)
	Global Fuchsia:SColor8 = New SColor8($FFFF00FF)
	Global Gainsboro:SColor8 = New SColor8($FFDCDCDC)
	Global GhostWhite:SColor8 = New SColor8($FFF8F8FF)
	Global Gold:SColor8 = New SColor8($FFFFD700)
	Global GoldenRod:SColor8 = New SColor8($FFDAA520)
	Global Gray:SColor8 = New SColor8($FF808080)
	Global Grey:SColor8 = New SColor8($FF808080)
	Global Green:SColor8 = New SColor8($FF00FF00)
	Global GreenYellow:SColor8 = New SColor8($FFADFF2F)
	Global HoneyDew:SColor8 = New SColor8($FFF0FFF0)
	Global HotPink:SColor8 = New SColor8($FFFF69B4)
	Global IndianRed:SColor8 = New SColor8($FFCD5C5C)
	Global Indigo:SColor8 = New SColor8($FF4B0082)
	Global Ivory:SColor8 = New SColor8($FFFFFFF0)
	Global Khaki:SColor8 = New SColor8($FFF0E68C)
	Global Lavender:SColor8 = New SColor8($FFE6E6FA)
	Global LavenderBlush:SColor8 = New SColor8($FFFFF0F5)
	Global LawnGreen:SColor8 = New SColor8($FF7CFC00)
	Global LemonChiffon:SColor8 = New SColor8($FFFFFACD)
	Global LightBlue:SColor8 = New SColor8($FFADD8E6)
	Global LightCoral:SColor8 = New SColor8($FFF08080)
	Global LightCyan:SColor8 = New SColor8($FFE0FFFF)
	Global LightGoldenRodYellow:SColor8 = New SColor8($FFFAFAD2)
	Global LightGray:SColor8 = New SColor8($FFD3D3D3)
	Global LightGrey:SColor8 = New SColor8($FFD3D3D3)
	Global LightGreen:SColor8 = New SColor8($FF90EE90)
	Global LightPink:SColor8 = New SColor8($FFFFB6C1)
	Global LightSalmon:SColor8 = New SColor8($FFFFA07A)
	Global LightSeaGreen:SColor8 = New SColor8($FF20B2AA)
	Global LightSkyBlue:SColor8 = New SColor8($FF87CEFA)
	Global LightSlateGray:SColor8 = New SColor8($FF778899)
	Global LightSlateGrey:SColor8 = New SColor8($FF778899)
	Global LightSteelBlue:SColor8 = New SColor8($FFB0C4DE)
	Global LightYellow:SColor8 = New SColor8($FFFFFFE0)
	Global LimeGreen:SColor8 = New SColor8($FF32CD32)
	Global Linen:SColor8 = New SColor8($FFFAF0E6)
	Global Magenta:SColor8 = New SColor8($FFFF00FF)
	Global Maroon:SColor8 = New SColor8($FF800000)
	Global MediumAquaMarine:SColor8 = New SColor8($FF66CDAA)
	Global MediumBlue:SColor8 = New SColor8($FF0000CD)
	Global MediumOrchid:SColor8 = New SColor8($FFBA55D3)
	Global MediumPurple:SColor8 = New SColor8($FF9370DB)
	Global MediumSeaGreen:SColor8 = New SColor8($FF3CB371)
	Global MediumSlateBlue:SColor8 = New SColor8($FF7B68EE)
	Global MediumSpringGreen:SColor8 = New SColor8($FF00FA9A)
	Global MediumTurquoise:SColor8 = New SColor8($FF48D1CC)
	Global MediumVioletRed:SColor8 = New SColor8($FFC71585)
	Global MidnightBlue:SColor8 = New SColor8($FF191970)
	Global MintCream:SColor8 = New SColor8($FFF5FFFA)
	Global MistyRose:SColor8 = New SColor8($FFFFE4E1)
	Global Moccasin:SColor8 = New SColor8($FFFFE4B5)
	Global NavajoWhite:SColor8 = New SColor8($FFFFDEAD)
	Global Navy:SColor8 = New SColor8($FF000080)
	Global OldLace:SColor8 = New SColor8($FFFDF5E6)
	Global Olive:SColor8 = New SColor8($FF808000)
	Global OliveDrab:SColor8 = New SColor8($FF6B8E23)
	Global Orange:SColor8 = New SColor8($FFFFA500)
	Global OrangeRed:SColor8 = New SColor8($FFFF4500)
	Global Orchid:SColor8 = New SColor8($FFDA70D6)
	Global PaleGoldenRod:SColor8 = New SColor8($FFEEE8AA)
	Global PaleGreen:SColor8 = New SColor8($FF98FB98)
	Global PaleTurquoise:SColor8 = New SColor8($FFAFEEEE)
	Global PaleVioletRed:SColor8 = New SColor8($FFDB7093)
	Global PapayaWhip:SColor8 = New SColor8($FFFFEFD5)
	Global PeachPuff:SColor8 = New SColor8($FFFFDAB9)
	Global Peru:SColor8 = New SColor8($FFCD853F)
	Global Pink:SColor8 = New SColor8($FFFFC0CB)
	Global Plum:SColor8 = New SColor8($FFDDA0DD)
	Global PowderBlue:SColor8 = New SColor8($FFB0E0E6)
	Global Purple:SColor8 = New SColor8($FF800080)
	Global RebeccaPurple:SColor8 = New SColor8($FF663399)
	Global Red:SColor8 = New SColor8($FFFF0000)
	Global RosyBrown:SColor8 = New SColor8($FFBC8F8F)
	Global RoyalBlue:SColor8 = New SColor8($FF4169E1)
	Global SaddleBrown:SColor8 = New SColor8($FF8B4513)
	Global Salmon:SColor8 = New SColor8($FFFA8072)
	Global SandyBrown:SColor8 = New SColor8($FFF4A460)
	Global SeaGreen:SColor8 = New SColor8($FF2E8B57)
	Global SeaShell:SColor8 = New SColor8($FFFFF5EE)
	Global Sienna:SColor8 = New SColor8($FFA0522D)
	Global Silver:SColor8 = New SColor8($FFC0C0C0)
	Global SkyBlue:SColor8 = New SColor8($FF87CEEB)
	Global SlateBlue:SColor8 = New SColor8($FF6A5ACD)
	Global SlateGray:SColor8 = New SColor8($FF708090)
	Global SlateGrey:SColor8 = New SColor8($FF708090)
	Global Snow:SColor8 = New SColor8($FFFFFAFA)
	Global SpringGreen:SColor8 = New SColor8($FF00FF7F)
	Global SteelBlue:SColor8 = New SColor8($FF4682B4)
	Global Tan:SColor8 = New SColor8($FFD2B48C)
	Global Teal:SColor8 = New SColor8($FF008080)
	Global Thistle:SColor8 = New SColor8($FFD8BFD8)
	Global Tomato:SColor8 = New SColor8($FFFF6347)
	Global Turquoise:SColor8 = New SColor8($FF40E0D0)
	Global Violet:SColor8 = New SColor8($FFEE82EE)
	Global Wheat:SColor8 = New SColor8($FFF5DEB3)
	Global White:SColor8 = New SColor8($FFFFFFFF)
	Global WhiteSmoke:SColor8 = New SColor8($FFF5F5F5)
	Global Yellow:SColor8 = New SColor8($FFFFFF00)
	Global YellowGreen:SColor8 = New SColor8($FF9ACD32)
	
End Struct
