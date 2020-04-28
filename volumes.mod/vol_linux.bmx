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
Import "linuxglue.c"

Extern
	Function _setmntent:Int(filename:Byte Ptr, _type:Byte Ptr) = "setmntent"
	Function _getmntent:Byte Ptr(file:Int) = "getmntent"
	Function _endmntent:Int(file:Int) = "endmntent"
	Function _statvfs:Int(path:Byte Ptr, stat:Byte Ptr) = "statvfs"
	
	Function bmx_userdirlookup:String(dirType:String)
	Function bmx_volumes_volspace_refresh:Int(vol:String, _size:Long Ptr, _free:Long Ptr)
	Function bmx_volumes_gethome:String()
End Extern

Type Tmntent
	Field mnt_fsname:Byte Ptr
	Field mnt_dir:Byte Ptr
	Field mnt_type:Byte Ptr
	Field mnt_opts:Byte Ptr
	Field mnt_freq:Int
	Field mnt_passno:Int
End Type

Type Tstatvfs
	Field f_bsize:Int    ' file system block size 
	Field f_frsize:Int   ' fragment size 
	Field f_blocks:Int   ' size of fs in f_frsize units 
	Field f_bfree:Int    ' # free blocks 
	Field f_bavail:Int   ' # free blocks For non-root 
	Field f_files:Int    ' # inodes 
	Field f_ffree:Int    ' # free inodes 
	Field f_favail:Int   ' # free inodes For non-root 
	Field f_fsid:Int     ' file system ID 
	Field f_flag:Int     ' mount flags 
	Field f_namemax:Int  ' maximum filename length 
End Type

Global linuxVolume_driver:TLinuxVolumeDriver = New TLinuxVolumeDriver

Type TLinuxVolumeDriver

	Method New()
		volume_driver = TLinuxVolume.Create()
	End Method

End Type

Type TLinuxVolume Extends TVolume

	Field vs:TVolSpace

	Function Create:TLinuxVolume()
		Local this:TLinuxVolume = New TLinuxVolume
		
		Return this
	End Function


	
	Method ListVolumes:TList() Override
		Local volumes:TList
		
		Local fp:Int = _setmntent("/etc/mtab", "r")
		
		If fp Then
			
			Local m:Byte Ptr = _getmntent(fp)
			
			While m
				Local mntent:TMntent = New TMntent
				MemCopy mntent,m,Size_T(SizeOf TMntent)
			
				If Not volumes Then
					volumes = New TList
				End If
				
				Local volume:TLinuxVolume = New TLinuxVolume
				volume.volumeDevice = String.fromCString(mntent.mnt_fsname)
				volume.volumeName = String.fromCString(mntent.mnt_dir)
				volume.volumeType = String.fromCString(mntent.mnt_type)

				volume.vs = TVolSpace.GetDiskSpace(volume.volumeName)
				If volume.vs Then
					volume.volumeSize = volume.vs.size()
					volume.volumeFree = volume.vs.free()
			
					volume.available = True
				End If
				
				volumes.addLast(volume)
			
				m = _getmntent(fp)
			Wend
			
			_endmntent(fp)
			
		End If
		
		Return volumes
	End Method
	
	Method GetVolumeFreeSpace:Long(vol:String) Override
	
		Local _vs:TVolSpace = TVolSpace.GetDiskSpace(vol)
		
		If _vs Then
			Return _vs.free()
		End If
		
		Return 0
	End Method
	
	Method GetVolumeSize:Long(vol:String) Override
	
		Local _vs:TVolSpace = TVolSpace.GetDiskSpace(vol)

		If _vs Then
			Return _vs.size()
		End If
		
		Return 0
	End Method

	Method GetVolumeInfo:TVolume(vol:String) Override
		Local volume:TLinuxVolume = New TLinuxVolume
		
		volume.volumeDevice = vol

		Local vs:TVolSpace = TVolSpace.GetDiskSpace(volume.volumeDevice)
		If vs Then
			volume.volumeSize = vs.size()
			volume.volumeFree = vs.free()
			
			volume.available = True
		End If
		
		Return volume
	End Method
	
	Method Refresh() Override
		If Not vs Then
			Return
		End If
		
		vs.refresh()

		If vs Then
			volumeSize = vs.size()
			volumeFree = vs.free()
			available = True
		Else
			available = False
		End If

	End Method
	
	Method getHome:String()
		Local dir:String = String.FromUTF8String(getenv_("HOME"))
		
		' HOME not set?
		If Not dir Or dir.length = 0 Then
			' work it out ourselves...
			
			dir = bmx_volumes_gethome()

		End If
		
		Return dir
	End Method

	Method GetUserHomeDir:String() Override
		Return getHome()
	End Method
	
	Method GetUserDesktopDir:String() Override
		Return bmx_userdirlookup("DESKTOP")
	End Method
	
	Method GetUserAppDir:String() Override
		Return getHome()
	End Method
	
	Method GetUserDocumentsDir:String() Override
		Return bmx_userdirlookup("DOCUMENTS")
	End Method

	Method GetCustomDir:String(dirType:Int, flags:Int = 0) Override

		Select dirType
			Case DT_SHAREDUSERDATA
				Return bmx_userdirlookup("PUBLICSHARE")
			Case DT_USERPICTURES
				Return bmx_userdirlookup("PICTURES")
			Case DT_USERMUSIC
				Return bmx_userdirlookup("MUSIC")
			Case DT_USERMOVIES
				Return bmx_userdirlookup("VIDEOS")
		End Select

	End Method

End Type

Type TVolSpace
	Field vol:String
	Field svfs:TStatvfs = New TStatvfs
	
	Field _size:Long
	Field _free:Long
	
	Function GetDiskSpace:TVolSpace(vol:String)
		Local this:TVolSpace = New TVolSpace
		
		this.vol = vol
		If this.refresh() <> 0 Then
			Return Null
		End If

		Return this
	End Function
	
	Method refresh:Int()
		Return bmx_volumes_volspace_refresh(vol, Varptr _size, Varptr _free)
	End Method
	
	Method size:Long()
		Return _size
	End Method
	
	Method free:Long()
		Return _free
	End Method
End Type
