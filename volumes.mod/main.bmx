' Copyright (c) 2007-2026 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Import BRL.LinkedList

Global volume_driver:TVolume

Rem
bbdoc: A system Volume
End Rem
Type TVolume

	Rem
	bbdoc:  True if available, false if not.
	End Rem
	Field available:Int

	Rem
	bbdoc: The volume name.
	End Rem
	Field volumeName:String
	
	Rem
	bbdoc: The device name
	End Rem
	Field volumeDevice:String
	
	Rem
	bbdoc: The system type.
	End Rem
	Field volumeType:String

	Rem
	bbdoc: Cached volume size (in bytes)
	about: For the current size, #Refresh first.
	End Rem
	Field volumeSize:Long
	
	Rem
	bbdoc: Cached free space (in bytes)
	about: For the current free space, #Refresh first.
	End Rem
	Field volumeFree:Long

	Rem
	bbdoc: Refreshes size/free info for the volume.
	End Rem
	Method Refresh() Abstract

	' platform specific implementations
	Method ListVolumes:TList() Abstract
	
	Method GetVolumeFreeSpace:Long(vol:String) Abstract
	
	Method GetVolumeSize:Long(vol:String) Abstract

	Method GetVolumeInfo:TVolume(vol:String) Abstract
	
	Method GetUserHomeDir:String() Abstract
	Method GetUserDesktopDir:String() Abstract
	Method GetUserAppDir:String() Abstract
	Method GetUserDocumentsDir:String() Abstract
	
	Method GetCustomDir:String(dirType:Int, flags:Int = 0) Abstract
	
End Type


Rem
bbdoc: Returns a list of volumes on the system.
End Rem
Function ListVolumes:TList()

	Return volume_driver.ListVolumes()

End Function

Rem
bbdoc: Returns the amount of free space (in bytes) on the given volume.
param: The name of the volume
End Rem
Function GetVolumeFreeSpace:Long(vol:String)

	Return volume_driver.GetVolumeFreeSpace(vol)

End Function

Rem
bbdoc: Returns the size (in bytes) of the given volume.
param: The name of the volume
End Rem
Function GetVolumeSize:Long(vol:String)

	Return volume_driver.GetVolumeSize(vol)

End Function

Rem
bbdoc: Populates and returns a #TVolume object.
param: the name of the volume
End Rem
Function GetVolumeInfo:TVolume(vol:String)

	Return volume_driver.GetVolumeInfo(vol)

End Function

Rem
bbdoc: Returns the user home directory.
about: The table lists examples for the various platforms -
| Platform | Example | Equivalent |
| --------- | ------- | ---------- |
| Linux | `/home/username` | `~` |
| Mac OS | `/Users/username` | `~` |
| Win32 | `C:\Documents and Settings\username` |  |
End Rem
Function GetUserHomeDir:String()
	Return volume_driver.GetUserHomeDir()
End Function

Rem
bbdoc: Returns the user Desktop directory.
about: The table lists examples for the various platforms -
| Platform | Example | Equivalent |
| --------- | ------- | ---------- |
| Linux | `/home/username/Desktop` | `~/Desktop` |
| Mac OS | `/Users/username/Desktop` | `~/Desktop` |
| Win32 | `C:\Documents and Settings\username\Desktop` |  |
End Rem
Function GetUserDesktopDir:String()
	Return volume_driver.GetUserDesktopDir()
End Function

Rem
bbdoc: Returns the user directory for application data.
about: The table lists examples for the various platforms -
| Platform | Example | Equivalent |
| --------- | ------- | ---------- |
| Linux | `/home/username` | `~` |
| Mac OS | `/Users/username/Library/Application Support` | `~/Library/Application Support` |
| Win32 | `C:\Documents and Settings\username\Application Data` |  |
End Rem
Function GetUserAppDir:String()
	Return volume_driver.GetUserAppDir()
End Function

Rem
bbdoc: Returns the user Documents directory.
about: The table lists examples for the various platforms -
| Platform | Example | Equivalent |
| --------- | ------- | ---------- |
| Linux | `/home/username/Documents` | `~/Documents` |
| Mac OS | `/Users/username/Documents` | `~/Documents` |
| Win32 | `C:\Documents and Settings\username\My Documents` |  |
End Rem
Function GetUserDocumentsDir:String()
	Return volume_driver.GetUserDocumentsDir()
End Function

Rem
bbdoc: Returns the custom directory path.
returns: Null if @dirType is not valid for the platform.
param: The type of directory to return. See below for valid values.
param: Optional flags to modify the behaviour of the function. See below for valid values.
about: The following table lists valid @dirType -
| Platform | dirType | Description |
| --------- | ------- | ---------- |
| Mac, Linux | DT_SHAREDUSERDATA | The Shared documents folder. |
| All | DT_USERPICTURES | The &quot;Pictures&quot; or &quot;My Pictures&quot; folder of the user. |
| All | DT_USERMUSIC | The &quot;Music&quot; or &quot;My Music&quot; folder of the user. |
| All | DT_USERMOVIES | The &quot;Movies&quot;, &quot;Videos&quot; or &quot;My Videos&quot; folder of the user. |
| Win32 | CSIDL_xxxxxxxx | Any of the Windows-specific CSIDL identifiers that represent different folders on the system. |
End Rem
Function GetCustomDir:String(dirType:Int, flags:Int = 0)
	Return volume_driver.GetCustomDir(dirType, flags)
End Function

' custom dir types

Const DT_SHAREDUSERDATA:Int = -1
Const DT_USERPICTURES:Int = -2
Const DT_USERMUSIC:Int = -3
Const DT_USERMOVIES:Int = -4
