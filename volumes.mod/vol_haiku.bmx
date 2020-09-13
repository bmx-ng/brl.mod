' Copyright (c) 2007-2020 Bruce A Henderson
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

Import brl.LinkedList
Import Pub.Stdc

Import "main.bmx"
Import "haikuglue.cpp"

Extern
	Function bmx_volumes_getdir:String(which:Int)
End Extern

Global haikuVolume_driver:THaikuVolumeDriver = New THaikuVolumeDriver

Type THaikuVolumeDriver

	Method New()
		volume_driver = THaikuVolume.Create()
	End Method

End Type

Type THaikuVolume Extends TVolume

	Field vs:TVolSpace

	Function Create:THaikuVolume()
		Local this:THaikuVolume = New THaikuVolume
		
		Return this
	End Function


	
	Method ListVolumes:TList() Override
		Local volumes:TList
		

		
		Return volumes
	End Method
	
	Method GetVolumeFreeSpace:Long(vol:String) Override
	
	End Method
	
	Method GetVolumeSize:Long(vol:String) Override
	
	End Method

	Method GetVolumeInfo:TVolume(vol:String) Override

	End Method
	
	Method Refresh() Override

	End Method
	
	Method GetUserHomeDir:String() Override
		Return bmx_volumes_getdir(B_USER_DIRECTORY)
	End Method
	
	Method GetUserDesktopDir:String() Override
		Return bmx_volumes_getdir(B_USER_DIRECTORY)
	End Method
	
	Method GetUserAppDir:String() Override
		Return bmx_volumes_getdir(B_USER_APPS_DIRECTORY)
	End Method
	
	Method GetUserDocumentsDir:String() Override
		Return bmx_volumes_getdir(B_USER_DOCUMENTATION_DIRECTORY)
	End Method

	Method GetCustomDir:String(dirType:Int, flags:Int = 0) Override
		Return bmx_volumes_getdir(dirType)
	End Method

End Type

Type TVolSpace
	Field vol:String	
	Field _size:Long
	Field _free:Long
	
	Function _create:TVolSpace() {  }
		Local this:TVolSpace = New TVolSpace
		
		'this.vol = vol
		If this.refresh() <> 0 Then
			Return Null
		End If

		Return this
	End Function
	
	Method refresh:Int()
		'Return bmx_volumes_volspace_refresh(vol, Varptr _size, Varptr _free)
	End Method
	
	Method size:Long()
		Return _size
	End Method
	
	Method free:Long()
		Return _free
	End Method
End Type

Private

Const B_USER_DIRECTORY:Int = 3000
Const B_USER_CONFIG_DIRECTORY:Int = 3001
Const B_USER_ADDONS_DIRECTORY:Int = 3002
Const B_USER_BOOT_DIRECTORY:Int = 3003
Const B_USER_FONTS_DIRECTORY:Int = 3004
Const B_USER_LIB_DIRECTORY:Int = 3005
Const B_USER_SETTINGS_DIRECTORY:Int = 3006
Const B_USER_DESKBAR_DIRECTORY:Int = 3007
Const B_USER_PRINTERS_DIRECTORY:Int = 3008
Const B_USER_TRANSLATORS_DIRECTORY:Int = 3009
Const B_USER_MEDIA_NODES_DIRECTORY:Int = 3010
Const B_USER_SOUNDS_DIRECTORY:Int = 3011
Const B_USER_DATA_DIRECTORY:Int = 3012
Const B_USER_CACHE_DIRECTORY:Int = 3013
Const B_USER_PACKAGES_DIRECTORY:Int = 3014
Const B_USER_HEADERS_DIRECTORY:Int = 3015
Const B_USER_NONPACKAGED_DIRECTORY:Int = 3016
Const B_USER_NONPACKAGED_ADDONS_DIRECTORY:Int = 3017
Const B_USER_NONPACKAGED_TRANSLATORS_DIRECTORY:Int = 3018
Const B_USER_NONPACKAGED_MEDIA_NODES_DIRECTORY:Int = 3019
Const B_USER_NONPACKAGED_BIN_DIRECTORY:Int = 3020
Const B_USER_NONPACKAGED_DATA_DIRECTORY:Int = 3021
Const B_USER_NONPACKAGED_FONTS_DIRECTORY:Int = 3022
Const B_USER_NONPACKAGED_SOUNDS_DIRECTORY:Int = 3023
Const B_USER_NONPACKAGED_DOCUMENTATION_DIRECTORY:Int = 3024
Const B_USER_NONPACKAGED_LIB_DIRECTORY:Int = 3025
Const B_USER_NONPACKAGED_HEADERS_DIRECTORY:Int = 3026
Const B_USER_NONPACKAGED_DEVELOP_DIRECTORY:Int = 3027
Const B_USER_DEVELOP_DIRECTORY:Int = 3028
Const B_USER_DOCUMENTATION_DIRECTORY:Int = 3029
Const B_USER_SERVERS_DIRECTORY:Int = 3030
Const B_USER_APPS_DIRECTORY:Int = 3031
Const B_USER_BIN_DIRECTORY:Int = 3032
Const B_USER_PREFERENCES_DIRECTORY:Int = 3033
Const B_USER_ETC_DIRECTORY:Int = 3034
Const B_USER_LOG_DIRECTORY:Int = 3035
Const B_USER_SPOOL_DIRECTORY:Int = 3036
Const B_USER_VAR_DIRECTORY:Int = 3037

