' Copyright (c) 2020-2023 Bruce A Henderson
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

Import Pub.Physfs
Import Pub.Stdc

Import "../../pub.mod/physfs.mod/physfs/src/*.h"
Import "glue.c"


Extern

	Function bmx_PHYSFS_init:Int()
	Function PHYSFS_deinit:Int()
	Function PHYSFS_isInit:Int()
	Function bmx_PHYSFS_getErrorForCode:String(errorCode:EMaxIOErrorCode)
	Function bmx_PHYSFS_getLastError:String()
	Function bmx_PHYSFS_getLastErrorCode:EMaxIOErrorCode()
	Function bmx_PHYSFS_mount:Int(newDir:String, mountPoint:String, appendToPath:Int)
	Function bmx_PHYSFS_getBaseDir:String()
	Function bmx_PHYSFS_getPrefDir:String(org:String, app:String)
	Function bmx_PHYSFS_mountMemory:Int(dirPtr:Byte Ptr, dirLen:Int, newDir:String, mountPoint:String, appendToPath:Int)
	Function bmx_PHYSFS_setWriteDir:Int(newDir:String)
	Function bmx_PHYSFS_getWriteDir:String()
	Function bmx_PHYSFS_getRealDir:String(filename:String)
	Function bmx_PHYSFS_getMountPoint:String(dir:String)
	Function bmx_PHYSFS_setRoot:Int(archive:String, subdir:String)
	Function bmx_PHYSFS_unmount:Int(oldDir:String)
	Function bmx_PHYSFS_getSearchPath:String[]()
	Function PHYSFS_permitSymbolicLinks:Int(allow:Int)
	Function PHYSFS_symbolicLinksPermitted:Int()
	
	Function PHYSFS_tell:Long(filePtr:Byte Ptr)
	Function PHYSFS_seek:Int(filePtr:Byte Ptr, newPos:Long)
	Function PHYSFS_fileLength:Long(filePtr:Byte Ptr)
	Function PHYSFS_readBytes:Long(filePtr:Byte Ptr, buf:Byte Ptr, length:ULong)
	Function PHYSFS_writeBytes:Long(filePtr:Byte Ptr, buf:Byte Ptr, length:ULong)
	Function PHYSFS_flush:Int(filePtr:Byte Ptr)
	Function PHYSFS_close:Int(filePtr:Byte Ptr)
	Function PHYSFS_setBuffer:Int(filePtr:Byte Ptr, bufsize:ULong)

	Function bmx_PHYSFS_openAppend:Byte Ptr(path:String)
	Function bmx_PHYSFS_openWrite:Byte Ptr(path:String)
	Function bmx_PHYSFS_openRead:Byte Ptr(path:String)
		
	Function bmx_PHYSFS_stat:Int(filename:String, stat:SMaxIO_Stat Var)
	Function bmx_PHYSFS_delete:Int(path:String)
	Function bmx_PHYSFS_mkdir:Int(dirName:String)
	
	Function bmx_blitzio_readdir:Byte Ptr(dir:String)
	Function bmx_blitzio_nextFile:String(dir:Byte Ptr)
	Function bmx_blitzio_closeDir(dir:Byte Ptr)
	
End Extern

Rem
bbdoc: File statistics, including file size, modification time, etc.
End rem
Struct SMaxIO_Stat
	Rem
	bbdoc: The size of the file, in bytes.
	End Rem
	Field _filesize:Long
	Rem
	bbdoc: The modification time of the file, in seconds since the epoch.
	End Rem
	Field _modtime:Long
	Rem
	bbdoc: The creation time of the file, in seconds since the epoch.
	End Rem
	Field _createtime:Long
	Rem
	bbdoc: The last access time of the file, in seconds since the epoch.
	End Rem
	Field _accesstime:Long
	Rem
	bbdoc: The type of the file.
	End Rem
	Field _filetype:EMaxIOFileType
	Rem
	bbdoc: Whether the file is read only or not.
	End Rem
	Field _readonly:Int

	Rem
	bbdoc: Returns the file modified time as an #SDateTime.
	End Rem
	Method ModeTimeAsDateTime:SDateTime()
		Return SDateTime.FromEpoch(_modTime)
	End Method

	Rem
	bbdoc: Returns the file creation time as an #SDateTime.
	End Rem
	Method CreatTimeAsDateTime:SDateTime()
		Return SDateTime.FromEpoch(_createTime)
	End Method

	Rem
	bbdoc: Returns the last access time as an #SDateTime.
	End Rem
	Method AccessTimeAsDateTime:SDateTime()
		Return SDateTime.FromEpoch(_accessTime)
	End Method

End Struct

Rem
bbdoc: The type of file.
End Rem
Enum EMaxIOFileType:Int
	REGULAR
	DIRECTORY
	SYMLINK
	OTHER
End Enum

Enum EMaxIOErrorCode:Int
	OK
	OTHER_ERROR
	OUT_OF_MEMORY
	NOT_INITIALIZED
	IS_INITIALIZED
	ARGV0_IS_NULL
	UNSUPPORTED
	PAST_EOF
	FILES_STILL_OPEN
	INVALID_ARGUMENT
	NOT_MOUNTED
	NOT_FOUND
	SYMLINK_FORBIDDEN
	NO_WRITE_DIR
	OPEN_FOR_READING
	OPEN_FOR_WRITING
	NOT_A_FILE
	READ_ONLY
	CORRUPT
	SYMLINK_LOOP
	IO
	PERMISSION
	NO_SPACE
	BAD_FILENAME
	BUSY
	DIR_NOT_EMPTY
	OS_ERROR
	DUPLICATE
	BAD_PASSWORD
	APP_CALLBACK
End Enum
