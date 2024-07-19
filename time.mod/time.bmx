' Copyright (c)2024 Bruce A Henderson
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

Module BRL.Time

ModuleInfo "Version: 1.0"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"


Rem
bbdoc: A unit of date-time, such as Days or Hours.
End Rem
Enum ETimeUnit
	Milliseconds
	Seconds
	Minutes
	Hours
	Days
End Enum

Rem
bbdoc: Converts a time value to milliseconds.
End Rem
Function TimeUnitToMillis:ULong( value:ULong, unit:ETimeUnit )
	Select unit
		Case ETimeUnit.Milliseconds
			Return value
		Case ETimeUnit.Seconds
			Return value * 1000
		Case ETimeUnit.Minutes
			Return value * 60000
		Case ETimeUnit.Hours
			Return value * 3600000
		Case ETimeUnit.Days
			Return value * 86400000
	End Select
End Function

Type TTimeoutException Extends TRuntimeException

	Method New(message:String)
		Super.New(message)
	End Method
	
End Type
