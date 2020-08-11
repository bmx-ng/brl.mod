' Copyright (c) 2020 Bruce A Henderson
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

Import "../../pub.mod/physfs.mod/physfs/src/*.h"
Import "glue.c"


Extern

	Function bmx_PHYSFS_init:Int()
	Function PHYSFS_deinit:Int()
	Function bmx_PHYSFS_getLastError:String()
	Function bmx_PHYSFS_mount:Int(newDir:String, mountPoint:String, appendToPath:Int)
	Function bmx_PHYSFS_getBaseDir:String()
	Function bmx_PHYSFS_getPrefDir:String(org:String, app:String)
	Function bmx_PHYSFS_mountMemory:Int(dirPtr:Byte Ptr, dirLen:Int, newDir:String, mountPoint:String, appendToPath:Int)
	Function bmx_PHYSFS_setWriteDir:Int(newDir:String)
	
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

Struct SMaxIO_Stat
	Field _filesize:Long
	Field _modtime:Long
	Field _createtime:Long
	Field _accesstime:Long
	Field _filetype:EMaxIOFileType
	Field _readonly:Int
End Struct

Enum EMaxIOFileType:Int
	REGULAR
	DIRECTORY
	SYMLINK
	OTHER
End Enum
