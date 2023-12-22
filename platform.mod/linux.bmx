' Copyright (c) 2019-2023 Bruce A Henderson
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

Import BRL.FileSystem

Function _linux_physical_processor_count:Int()

	If Not FileExists("/proc/stat") Then
		Return 0
	End If

	Local cpustat:Stream = ReadFile("/proc/stat")

	If Not cpustat Then
		Return 0
	End If

	Local count:Int = 0

	While Not cpustat.EOF()

		Local line:String = cpustat.ReadLine()

		If line.StartsWith("cpu") Then
			count :+ 1
		End If

	Wend

	cpustat.Close()

	Return count

End Function
