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
	Function bmx_volumes_bvolume_new:Byte Ptr(name:String)
	Function bmx_volumes_bvolume_name:String(handle:Byte Ptr)
	Function bmx_volumes_bvolume_size:Long(handle:Byte Ptr)
	Function bmx_volumes_bvolume_freebytes:Long(handle:Byte Ptr)
	Function bmx_volumes_bvolume_free(handle:Byte Ptr)
	
	Function bmx_volumes_list_init:Byte Ptr()
	Function bmx_volumes_next_vol:Byte Ptr(rost:Byte Ptr)
	Function bmx_volumes_list_free(rost:Byte Ptr)
End Extern

Global haikuVolume_driver:THaikuVolumeDriver = New THaikuVolumeDriver

Type THaikuVolumeDriver

	Method New()
		volume_driver = THaikuVolume.Create()
	End Method

End Type

Type THaikuVolume Extends TVolume

	Field vol:TBVolume

	Function Create:THaikuVolume()
		Return New THaikuVolume
	End Function

	Method ListVolumes:TList() Override
		Local volumes:TList = New TList
		
		Local vptr:Byte Ptr = bmx_volumes_list_init()
		
		While True
			Local volPtr:Byte Ptr = bmx_volumes_next_vol(vptr)
			
			If Not volPtr Then
				Exit
			End If
			
			Local bvol:TBVolume = New TBVolume(volPtr)
			If bvol.Name() Then
			
				Local volume:THaikuVolume = New THaikuVolume
				volume.vol = bvol

				volume.volumeName = bvol.Name()

				volume.volumeSize = bvol.Size()
				volume.volumeFree = bvol.Free()
			
				volume.available = True

				volumes.AddLast(volume)
			End If
		Wend
		
		bmx_volumes_list_free(vptr)
		
		Return volumes
	End Method
	
	Method GetVolumeFreeSpace:Long(vol:String) Override
		Local volume:TBVolume = New TBVolume(vol)
		If volume.Valid() Then
			Return volume.Free()
		End If
		Return 0
	End Method
	
	Method GetVolumeSize:Long(vol:String) Override
		Local volume:TBVolume = New TBVolume(vol)
		If volume.Valid() Then
			Return volume.Size()
		End If
		Return 0
	End Method

	Method GetVolumeInfo:TVolume(vol:String) Override
		Local volume:TBVolume = New TBVolume(vol)
		If volume.Valid() Then
			Local hv:THaikuVolume = New THaikuVolume
			hv.vol = volume

			hv.volumeName = volume.Name()
			'hv.volumeDevice = vs.fs.mountedFileSystem()
			'volume.volumeType = vs.fs.fileSystemType()

			hv.volumeSize = volume.Size()
			hv.volumeFree = volume.Free()
			
			hv.available = True
			Return hv
		End If
		Return Null
	End Method
	
	Method Refresh() Override
		' noop
	End Method
	
	Method GetUserHomeDir:String() Override
		Return bmx_volumes_getdir(B_USER_DIRECTORY)
	End Method
	
	Method GetUserDesktopDir:String() Override
		Return bmx_volumes_getdir(B_USER_DIRECTORY) + "/Desktop"
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

Type TBVolume

	Field volPtr:Byte Ptr
	
	Method New(name:String)
		volPtr = bmx_volumes_bvolume_new(name)
	End Method
	
	Method New(volPtr:Byte Ptr)
		Self.VolPtr = volPtr
	End Method
	
	Method Valid:Int()
		Return volPtr <> Null
	End Method
	
	Method Name:String()
		Return bmx_volumes_bvolume_name(volPtr)
	End Method
	
	Method Size:Long()
		Return bmx_volumes_bvolume_size(volPtr)
	End Method
	
	Method Free:Long()
		Return bmx_volumes_bvolume_freebytes(volPtr)
	End Method
	
	Method Delete()
		If volPtr Then
			bmx_volumes_bvolume_free(volPtr)
			volPtr = Null
		End If
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

