' Copyright (c) 2026 Bruce A Henderson and contributors
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
bbdoc: System/Range
End Rem
Module BRL.Range

?bmxng2

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Rem
bbdoc: Thrown when Range arithmetic produces a coordinate or length outside the Int domain.
End Rem
Type TRangeCoordinateException Extends TBlitzException
	Private
	Field _operation:String

	Public
	Rem
	bbdoc: Creates a coordinate exception identifying the failed @operation.
	param: The name of the Range operation which overflowed.
	End Rem
	Method New(operation:String)
		_operation = operation
	End Method

	Rem
	bbdoc: Returns a description of the failed Range operation.
	returns: A message containing the failed operation name.
	End Rem
	Method ToString:String() Override
		Return "Range coordinate overflow in " + _operation
	End Method
End Type

Rem
bbdoc: Thrown when the value of an open #RangeEndpoint is requested.
End Rem
Type TRangeEndpointValueException Extends TBlitzException
	Rem
	bbdoc: Returns the exception message.
	returns: A description explaining that the endpoint is open.
	End Rem
	Method ToString:String() Override
		Return "Range endpoint is open and does not contain a value"
	End Method
End Type

Private

Function CheckedRangeCoordinate:Int(value:Long, operation:String)
	If value < -2147483648:Long Or value > 2147483647:Long Then
		Throw New TRangeCoordinateException(operation)
	End If
	Return Int(value)
End Function

Public

Rem
bbdoc: Identifies how a #RangeEndpoint coordinate is interpreted.
End Rem
Enum ERangeEndpointOrigin:Byte
	Open
	FromStart
	FromEnd
End Enum

Rem
bbdoc: One open, start-relative, or end-relative endpoint of a Range.
about: A from-start value is an absolute coordinate and retains BlitzMax's
negative padding semantics. A from-end value is subtracted from receiver length,
so zero identifies the end and two identifies the coordinate two places before it.
End Rem
Struct RangeEndpoint
	Private
	Field _origin:ERangeEndpointOrigin
	Field _value:Int

	Method New(origin:ERangeEndpointOrigin, value:Int)
		_origin = origin
		_value = value
	End Method

	Public
	Rem
	bbdoc: Creates the default open endpoint.
	End Rem
	Method New()
	End Method

	Rem
	bbdoc: Returns an open endpoint.
	returns: An endpoint with #ERangeEndpointOrigin.Open origin.
	End Rem
	Function Open:RangeEndpoint()
		Return New RangeEndpoint(ERangeEndpointOrigin.Open, 0)
	End Function

	Rem
	bbdoc: Returns an endpoint at absolute @coordinate from the receiver start.
	param: The absolute coordinate, including negative padding coordinates.
	returns: A start-relative endpoint storing @coordinate.
	End Rem
	Function FromStart:RangeEndpoint(coordinate:Int)
		Return New RangeEndpoint(ERangeEndpointOrigin.FromStart, coordinate)
	End Function

	Rem
	bbdoc: Returns an endpoint at @distance subtracted from receiver length.
	param: The distance subtracted from the receiver length.
	returns: An end-relative endpoint storing @distance.
	about: Zero identifies the receiver end. Positive values move toward the start;
	negative values identify padded coordinates beyond the end.
	End Rem
	Function FromEnd:RangeEndpoint(distance:Int)
		Return New RangeEndpoint(ERangeEndpointOrigin.FromEnd, distance)
	End Function

	Rem
	bbdoc: Returns this endpoint's origin.
	returns: The endpoint's #ERangeEndpointOrigin.
	End Rem
	Method Origin:ERangeEndpointOrigin()
		Return _origin
	End Method

	Rem
	bbdoc: Returns True when this endpoint is open.
	returns: True when open; otherwise False.
	End Rem
	Method IsOpen:Int()
		Return _origin = ERangeEndpointOrigin.Open
	End Method

	Rem
	bbdoc: Compatibility alias for #IsOpen.
	returns: True when open; otherwise False.
	End Rem
	Method IsUndefined:Int()
		Return IsOpen()
	End Method

	Rem
	bbdoc: Returns True when this endpoint has a stored coordinate or distance.
	returns: True when the endpoint has a value; otherwise False.
	End Rem
	Method HasValue:Int()
		Return Not IsOpen()
	End Method

	Rem
	bbdoc: Returns True when this endpoint has a stored coordinate or distance.
	returns: True when the endpoint has a value; otherwise False.
	End Rem
	Method IsDefined:Int()
		Return HasValue()
	End Method

	Rem
	bbdoc: Returns True when this endpoint stores an absolute coordinate from the start.
	returns: True for a start-relative endpoint; otherwise False.
	End Rem
	Method IsFromStart:Int()
		Return _origin = ERangeEndpointOrigin.FromStart
	End Method

	Rem
	bbdoc: Returns True when this endpoint stores a distance from the end.
	returns: True for an end-relative endpoint; otherwise False.
	End Rem
	Method IsFromEnd:Int()
		Return _origin = ERangeEndpointOrigin.FromEnd
	End Method

	Rem
	bbdoc: Returns the stored absolute coordinate or from-end distance.
	returns: The stored coordinate or distance.
	about: Throws #TRangeEndpointValueException when this endpoint is open.
	End Rem
	Method Value:Int()
		If IsOpen() Then Throw New TRangeEndpointValueException
		Return _value
	End Method

	Rem
	bbdoc: Resolves this endpoint against @length, using @openCoordinate when open.
	param: The receiver length used for an end-relative endpoint.
	param: The coordinate returned for an open endpoint.
	returns: The resolved coordinate.
	End Rem
	Method Resolve:Int(length:Int, openCoordinate:Int)
		Select _origin
			Case ERangeEndpointOrigin.FromStart
				Return _value
			Case ERangeEndpointOrigin.FromEnd
				Return CheckedRangeCoordinate(Long(length) - Long(_value), "RangeEndpoint.Resolve")
			Default
				Return openCoordinate
		End Select
	End Method

	Rem
	bbdoc: Moves the resolved coordinate by @amount while retaining its origin.
	param: The signed amount added to the resolved coordinate.
	returns: A shifted endpoint, or this endpoint when open.
	End Rem
	Method Offset:RangeEndpoint(amount:Int)
		Select _origin
			Case ERangeEndpointOrigin.FromStart
				Return FromStart(CheckedRangeCoordinate(Long(_value) + Long(amount), "RangeEndpoint.Offset"))
			Case ERangeEndpointOrigin.FromEnd
				Return FromEnd(CheckedRangeCoordinate(Long(_value) - Long(amount), "RangeEndpoint.Offset"))
			Default
				Return Self
		End Select
	End Method
End Struct

Rem
bbdoc: The concrete coordinates of a resolved half-open Range.
about: Coordinates are retained as resolved, including out-of-bounds and reversed
values. #Length reports zero for a reversed or zero-width range.
End Rem
Struct ResolvedRange
	Private
	Field _start:Int
	Field _end:Int

	Public
	Rem
	bbdoc: Creates resolved coordinates with inclusive @startIndex and exclusive @endIndex.
	param: The inclusive start coordinate.
	param: The exclusive end coordinate.
	End Rem
	Method New(startIndex:Int, endIndex:Int)
		_start = startIndex
		_end = endIndex
	End Method

	Rem
	bbdoc: Returns the inclusive start coordinate.
	returns: The stored inclusive start coordinate.
	End Rem
	Method Start:Int()
		Return _start
	End Method

	Rem
	bbdoc: Returns the exclusive end coordinate.
	returns: The stored exclusive end coordinate.
	End Rem
	Method EndExclusive:Int()
		Return _end
	End Method

	Rem
	bbdoc: Returns the half-open width, or zero when these coordinates are reversed or empty.
	returns: The non-negative width of this resolved range.
	about: Throws #TRangeCoordinateException when the width cannot be represented by Int.
	End Rem
	Method Length:Int()
		If _end <= _start Then Return 0
		Return CheckedRangeCoordinate(Long(_end) - Long(_start), "ResolvedRange.Length")
	End Method

	Rem
	bbdoc: Returns True when the coordinates are reversed or have zero width.
	returns: True when this resolved range contains no coordinates; otherwise False.
	End Rem
	Method IsEmpty:Int()
		Return _end <= _start
	End Method

	Rem
	bbdoc: Returns True when @index lies within these half-open coordinates.
	param: The coordinate to test.
	returns: True when @index is at least #Start and less than #EndExclusive.
	End Rem
	Method Contains:Int(index:Int)
		Return Not IsEmpty() And index >= _start And index < _end
	End Method
End Struct

Rem
bbdoc: A reusable half-open slice range.
about: Start is inclusive and End is exclusive. An open bound represents
the corresponding open end of a slice. When BRL.Range is imported, Range
expressions such as `1..4`, `..^2`, and `^5..^2` construct equivalent values.
Parenthesize a trailing open bound, as in `(2..)`, because `..` at the end of
a source line retains its existing line-continuation meaning.
End Rem
Struct Range
	Private
	Field _start:RangeEndpoint
	Field _end:RangeEndpoint

	Public
	Rem
	bbdoc: Creates the default Range with both bounds open.
	End Rem
	Method New()
	End Method

	Private
	Method New(startEndpoint:RangeEndpoint, endEndpoint:RangeEndpoint)
		_start = startEndpoint
		_end = endEndpoint
	End Method

	Public
	Rem
	bbdoc: Returns a Range with both bounds open.
	returns: A Range covering the complete receiver when resolved.
	End Rem
	Function All:Range()
		Return New Range(RangeEndpoint.Open(), RangeEndpoint.Open())
	End Function

	Rem
	bbdoc: Returns a Range with an open start and exclusive @endIndex.
	param: The exclusive absolute end coordinate.
	returns: A Range from the receiver start up to @endIndex.
	End Rem
	Function Until:Range(endIndex:Int)
		Return New Range(RangeEndpoint.Open(), RangeEndpoint.FromStart(endIndex))
	End Function

	Rem
	bbdoc: Returns a Range beginning at @startIndex with an open end.
	param: The inclusive absolute start coordinate.
	returns: A Range from @startIndex to the receiver end.
	End Rem
	Function From:Range(startIndex:Int)
		Return New Range(RangeEndpoint.FromStart(startIndex), RangeEndpoint.Open())
	End Function

	Rem
	bbdoc: Returns a Range from inclusive @startIndex to exclusive @endIndex.
	param: The inclusive absolute start coordinate.
	param: The exclusive absolute end coordinate.
	returns: A bounded half-open Range.
	End Rem
	Function FromUntil:Range(startIndex:Int, endIndex:Int)
		Return New Range(RangeEndpoint.FromStart(startIndex), RangeEndpoint.FromStart(endIndex))
	End Function

	Rem
	bbdoc: Returns a Range composed from explicit @startEndpoint and @endEndpoint values.
	param: The inclusive start endpoint.
	param: The exclusive end endpoint.
	returns: A Range containing the supplied endpoints.
	End Rem
	Function FromEndpoints:Range(startEndpoint:RangeEndpoint, endEndpoint:RangeEndpoint)
		Return New Range(startEndpoint, endEndpoint)
	End Function

	Rem
	bbdoc: Returns a Range with an open start and an end relative to receiver length.
	param: The distance subtracted from receiver length for the exclusive end.
	returns: A Range from the receiver start to the end-relative endpoint.
	End Rem
	Function UntilFromEnd:Range(distance:Int)
		Return New Range(RangeEndpoint.Open(), RangeEndpoint.FromEnd(distance))
	End Function

	Rem
	bbdoc: Returns a Range beginning relative to receiver length with an open end.
	param: The distance subtracted from receiver length for the inclusive start.
	returns: A Range from the end-relative endpoint to the receiver end.
	End Rem
	Function FromEnd:Range(distance:Int)
		Return New Range(RangeEndpoint.FromEnd(distance), RangeEndpoint.Open())
	End Function

	Rem
	bbdoc: Returns the one-element Range at @index.
	param: The absolute coordinate of the single element.
	returns: A Range from @index through @index plus one.
	about: Throws #TRangeCoordinateException when the exclusive end would exceed the Int domain.
	End Rem
	Function Single:Range(index:Int)
		Return FromUntil(index, CheckedRangeCoordinate(Long(index) + 1, "Range.Single"))
	End Function

	Rem
	bbdoc: Returns a Range beginning at @startIndex with the requested @length.
	param: The inclusive absolute start coordinate.
	param: The requested number of coordinates.
	returns: A Range with the requested start and non-negative length.
	about: A non-positive length produces an empty Range at @startIndex. Throws
	#TRangeCoordinateException when the exclusive end would exceed the Int domain.
	End Rem
	Function FromLength:Range(startIndex:Int, length:Int)
		If length <= 0 Then Return FromUntil(startIndex, startIndex)
		Return FromUntil(startIndex, CheckedRangeCoordinate(Long(startIndex) + Long(length), "Range.FromLength"))
	End Function

	Rem
	bbdoc: Returns the inclusive start endpoint.
	returns: The stored start endpoint.
	End Rem
	Method Start:RangeEndpoint()
		Return _start
	End Method

	Rem
	bbdoc: Returns the exclusive end endpoint.
	returns: The stored end endpoint.
	End Rem
	Method EndExclusive:RangeEndpoint()
		Return _end
	End Method

	Rem
	bbdoc: Returns True when this Range has an explicit start bound.
	returns: True when the start endpoint is not open; otherwise False.
	End Rem
	Method HasStart:Int()
		Return _start.HasValue()
	End Method

	Rem
	bbdoc: Returns True when this Range has an explicit end bound.
	returns: True when the end endpoint is not open; otherwise False.
	End Rem
	Method HasEnd:Int()
		Return _end.HasValue()
	End Method

	Rem
	bbdoc: Returns True when both bounds are open.
	returns: True when this Range represents all coordinates; otherwise False.
	End Rem
	Method IsAll:Int()
		Return Not HasStart() And Not HasEnd()
	End Method

	Rem
	bbdoc: Returns True when both bounds are explicit.
	returns: True when neither endpoint is open; otherwise False.
	End Rem
	Method IsBounded:Int()
		Return HasStart() And HasEnd()
	End Method

	Rem
	bbdoc: Resolves the start endpoint against @length, using zero when open.
	param: The receiver length used for an end-relative start.
	returns: The resolved inclusive start coordinate.
	End Rem
	Method ResolveStart:Int(length:Int)
		Return _start.Resolve(length, 0)
	End Method

	Rem
	bbdoc: Returns the explicit end coordinate or @length for an open end.
	param: The receiver length used for an open or end-relative endpoint.
	returns: The resolved exclusive end coordinate.
	End Rem
	Method ResolveEndExclusive:Int(length:Int)
		Return _end.Resolve(length, length)
	End Method

	Rem
	bbdoc: Moves each defined bound by @amount while preserving open bounds.
	param: The signed amount added to each resolved bound.
	returns: A Range with shifted defined endpoints.
	about: Throws #TRangeCoordinateException when a moved bound would exceed the Int domain.
	End Rem
	Method Offset:Range(amount:Int)
		Return New Range(_start.Offset(amount), _end.Offset(amount))
	End Method

	Rem
	bbdoc: Resolves open bounds using zero and @length without constraining explicit coordinates.
	param: The receiver length used for open and end-relative endpoints.
	returns: The resolved, unconstrained half-open coordinates.
	End Rem
	Method Resolve:ResolvedRange(length:Int)
		Return New ResolvedRange(ResolveStart(length), ResolveEndExclusive(length))
	End Method

	Rem
	bbdoc: Resolves this Range and constrains both coordinates to the receiver bounds.
	param: The receiver length; negative values are treated as zero.
	returns: Resolved coordinates individually constrained to zero through @length.
	about: A negative @length is treated as zero. Reversed coordinates remain
	reversed after each endpoint is constrained and therefore describe an empty range.
	End Rem
	Method Clamp:ResolvedRange(length:Int)
		Local safeLength:Int = length
		If safeLength < 0 Then safeLength = 0
		Local resolved:ResolvedRange = Resolve(safeLength)
		Local startIndex:Int = resolved.Start()
		Local endIndex:Int = resolved.EndExclusive()
		If startIndex < 0 Then startIndex = 0
		If startIndex > safeLength Then startIndex = safeLength
		If endIndex < 0 Then endIndex = 0
		If endIndex > safeLength Then endIndex = safeLength
		Return New ResolvedRange(startIndex, endIndex)
	End Method
End Struct

?
