' Copyright (c) 2024-2025 Bruce A Henderson
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Rem
bbdoc: A module for packing rectangles into sheets.
about: Useful for creating texture atlases, sprite sheets, and other similar things.
End Rem
Module BRL.RectPacker

ModuleInfo "Version: 1.01"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2024-2025 Bruce A Henderson"
ModuleInfo "rect_pack: Albert Kalchmair 2021, Sean Barrett 2014, Jukka Jylänki"

ModuleInfo "History: 1.01"
ModuleInfo "History: borderPadding now applies to individual rects."
ModuleInfo "History: Added sheetPadding to add padding around the edge of the sheet."
ModuleInfo "History: 1.00 Initial Release"

ModuleInfo "CPP_OPTS: -std=c++11"

Import BRL.Collections

Import "source.bmx"

Rem
bbdoc: Packs rectangles into sheets.
about: The packer provides a number of settings that can be used to control how the rectangles are packed.
The rectangles are added to the packer using the #Add method, and then the #Pack method is called to pack them into sheets.
The packer will return an array of #TPackedSheet objects, each of which contains the rectangles that have been packed into it.
An @id can be assigned to each rectangle, which can be used to identify the rectangle in the packed sheets.
End Rem
Type TRectPacker

	Rem
	bbdoc: The packing method to use.
	End Rem
	Field packingMethod:EPackingMethod = EPackingMethod.Best

	Rem
	bbdoc: The maximum number of sheets to produce.
	about: If the packer is unable to fit all the rectangles into the specified number of sheets, those that don't fit will be discarded.
	End Rem
	Field maxSheets:Int = 1

	Rem
	bbdoc: Whether to pack into power-of-two sized sheets.
	about: If this is set to #True, the width and height of the sheets will be rounded up to the nearest power of two.
	This is useful for creating sheets that are intended to be used for creating textures.
	End Rem
	Field powerOfTwo:Int = True

	Rem
	bbdoc: Whether to pack into square sheets.
	about: If this is set to #True, the width and height of the sheets will be the same.
	End Rem
	Field square:Int = False

	Rem
	bbdoc: Whether to allow rectangles to be rotated.
	about: If this is set to #True, the packer may attempt to rotate rectangles to help fit them into the sheets.
	End Rem
	Field allowRotate:Int = False

	Rem
	bbdoc: Whether to align the width of the rectangles.
	about: If this is set to #True, the packer will attempt to align the width of the rectangles to the width of the sheet.
	This can help to reduce the amount of wasted space in the sheet.
	End Rem
	Field alignWidth:Int = False

	Rem
	bbdoc: The amount of padding to add around individual rects.
	End Rem
	Field borderPadding:Int

	Rem
	bbdoc: The amount of padding to add around the edge of the sheet.
	End Rem
	Field sheetPadding:Int

	Rem
	bbdoc: The amount to over-allocate the sheet by.
	about: This is useful if you want to add a border around the sheet, or if you want to add some padding around the rectangles.
	End Rem
	Field overAllocate:Int

	Rem
	bbdoc: The minimum width of the sheets.
	End Rem
	Field minWidth:Int

	Rem
	bbdoc: The minimum height of the sheets.
	End Rem
	Field minHeight:Int

	Rem
	bbdoc: The maximum width of the sheets.
	End Rem
	Field maxWidth:Int

	Rem
	bbdoc: The maximum height of the sheets.
	End Rem
	Field maxHeight:Int

	Field sizes:TArrayList<SRectSize> = New TArrayList<SRectSize>

	Rem
	bbdoc: Adds a rectangle with the given @id to the packer.
	End Rem
	Method Add(width:Int, height:Int, id:Int)

		Local size:SRectSize = New SRectSize(width, height, id)
		sizes.Add(size)

	End Method

	Rem
	bbdoc: Packs the rectangles into sheets, based on the settings of the packer.
	about: This method will return an array of #TPackedSheet objects, each of which contains the rectangles that have been packed into it.
	Any rectangles that don't fit into the sheets will be discarded, and not be included in the returned array.
	End Rem
	Method Pack:TPackedSheet[]()
		Return bmx_rectpacker_pack(Self, packingMethod, maxSheets, powerOfTwo, square, allowRotate, alignWidth, borderPadding, sheetPadding, overAllocate, minWidth, minHeight, maxWidth, maxHeight, sizes.Count())
	End Method

Private
	Function _GetSize(packer:TRectPacker, index:Int, width:Int Var, height:Int Var, id:Int Var) { nomangle }
		Local size:SRectSize = packer.sizes[index]
		width = size.width
		height = size.height
		id = size.id
	End Function

	Function _NewSheetArray:TPackedSheet[](size:Int) { nomangle }
		Return New TPackedSheet[size]
	End Function

	Function _SetSheet(sheets:TPackedSheet[], index:Int, sheet:TPackedSheet) { nomangle }
		sheets[index] = sheet
	End Function

End Type

Struct SRectSize
	Field width:Int
	Field height:Int
	Field id:Int

	Method New(width:Int, height:Int, id:Int)
		Self.width = width
		Self.height = height
		Self.id = id
	End Method

	Method Operator=:Int(other:SRectSize)
		Return width = other.width And height = other.height And id = other.id
	End Method
End Struct

Rem
bbdoc: The packing method to use.
about: The packing method determines how the rectangles are packed into the sheets.

| Value                         | Description                                  |
|-------------------------------|----------------------------------------------|
| #Best                         | The best fitting from all of the available methods. |
| #BestSkyline                  | The best available skyline method.           |
| #BestMaxRects                 | The best available max rects method.         |
| #SkylineBottomLeft            | The skyline bottom-left method.              |
| #SkylineBestFit               | The skyline best-fit method.                 |
| #MaxRectsBestShortSideFit     | The max rects best short-side fit method.    |
| #MaxRectsBestLongSideFit      | The max rects best long-side fit method.     |
| #MaxRectsBestAreaFit          | The max rects best area fit method.          |
| #MaxRectsBottomLeftRule       | The max rects bottom-left rule method.       |
| #MaxRectsContactPointRule     | The max rects contact-point rule method.     |
End Rem
Enum EPackingMethod
	Best
	BestSkyline
	BestMaxRects
	SkylineBottomLeft
	SkylineBestFit
	MaxRectsBestShortSideFit
	MaxRectsBestLongSideFit
	MaxRectsBestAreaFit
	MaxRectsBottomLeftRule
	MaxRectsContactPointRule
End Enum

Rem
bbdoc: Represents a rectangle that has been packed into a sheet.
End Rem
Struct SPackedRect

	Rem
	bbdoc: The ID of the rectangle.
	End Rem
	Field id:Int

	Rem
	bbdoc: The X position of the rectangle.
	End Rem
	Field x:Int

	Rem
	bbdoc: The Y position of the rectangle.
	End Rem
	Field y:Int

	Rem
	bbdoc: The width of the rectangle.
	End Rem
	Field width:Int

	Rem
	bbdoc: The height of the rectangle.
	End Rem
	Field height:Int

	Rem
	bbdoc: Whether the rectangle has been rotated.
	End Rem
	Field rotated:Int

	Method New(id:Int, x:Int, y:Int, width:Int, height:Int, rotated:Int)
		Self.id = id
		Self.x = x
		Self.y = y
		Self.width = width
		Self.height = height
		Self.rotated = rotated
	End Method
End Struct

Rem
bbdoc: Represents a sheet that has been packed with rectangles.
End Rem
Type TPackedSheet

	Rem
	bbdoc: The width of the sheet.
	End Rem
	Field width:Int

	Rem
	bbdoc: The height of the sheet.
	End Rem
	Field height:Int

	Rem
	bbdoc: The rectangles that have been packed into the sheet.
	End Rem
	Field rects:SPackedRect[]

Private
	Function _Create:TPackedSheet(width:Int, height:Int, size:Int) { nomangle }
		Local sheet:TPackedSheet = New TPackedSheet
		sheet.width = width
		sheet.height = height
		sheet.rects = New SPackedRect[size]
		Return sheet
	End Function

	Function _SetRect(sheet:TPackedSheet, index:Int, id:Int, x:Int, y:Int, width:Int, height:Int, rotated:Int) { nomangle }
		Local rect:SPackedRect = New SPackedRect(id, x, y, width, height, rotated)
		sheet.rects[index] = rect
	End Function

End Type

Extern

	Function bmx_rectpacker_pack:TPackedSheet[](packer:TRectPacker, packingMethod:EPackingMethod, maxSheets:Int, powerOfTwo:Int, square:Int, allowRotate:Int, alignWidth:Int, borderPadding:Int, sheetPadding:Int, overAllocate:Int, minWidth:Int, minHeight:Int, maxWidth:Int, maxHeight:Int, count:Int)

End Extern
