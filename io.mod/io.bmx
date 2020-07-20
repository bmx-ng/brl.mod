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

Rem
bbdoc: IO Abstraction
End Rem
Module BRL.IO

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import "common.bmx"

Rem
bbdoc: IO abstraction implementation.
about: 
End Rem
Type MaxIO

	Global ioInitialized:Int

	Rem
	bbdoc: Initialises the abstraction layer.
	about: This must be called before any other #MaxIO functions.
	End Rem
	Function Init()
		If Not ioInitialized Then
			If Not bmx_PHYSFS_init() Then
				Throw bmx_PHYSHS_getLastError()
			End If
		End If
		ioInitialized = True
	End Function

	Rem
	bbdoc: Adds an archive or directory to the search path.
	about: If this is a duplicate, the entry is not added again, even though the function succeeds.
	You may not add the same archive to two different mountpoints: duplicate checking is done against the archive and not the mountpoint.
	
	When you mount an archive, it is added to a virtual file system...all files in all of the archives are interpolated into a single
	hierachical file tree. Two archives mounted at the same place (or an archive with files overlapping another mountpoint) may have
	overlapping files: in such a case, the file earliest in the search path is selected, and the other files are inaccessible to the
	application. This allows archives to be used to override previous revisions; you can use the mounting mechanism to place archives
	at a specific point in the file tree and prevent overlap; this is useful for downloadable mods that might trample over application data
	or each other, for example.

	The mountpoint does not need to exist prior to mounting, which is different than those familiar with the Unix concept of "mounting"
	may expect. As well, more than one archive can be mounted to the same mountpoint, or mountpoints and archive contents can overlap...the
	interpolation mechanism still functions as usual.
	End Rem
	Function Mount:Int(newDir:String, mountPoint:String = Null, appendToPath:Int = True)
		Assert ioInitialized Else "MaxIO not initialized"
		If newDir.StartsWith("incbin::") Then
			Return MountIncBin(newDir[8..], mountPoint, appendToPath)
		End If
		Return bmx_PHYSFS_mount(newDir, mountPoint, appendToPath)
	End Function

	Rem
	bbdoc: Adds an incbinned archive to the search path.
	about: See #Mount for more information.
	End Rem
	Function MountIncbin:Int(newDir:String, mountPoint:String = Null, appendToPath:Int = True)
		Assert ioInitialized Else "MaxIO not initialized"
		Assert IncbinPtr(newDir) Else "No Incbin for " + newDir
		Return bmx_PHYSFS_mountMemory(IncbinPtr(newDir), IncbinLen(newDir), newDir, mountPoint, appendToPath)
	End Function

	Rem
	bbdoc: Gets the path where the application resides.
	End Rem
	Function GetBaseDir:String()
		Assert ioInitialized Else "MaxIO not initialized"
		Return bmx_PHYSFS_getBaseDir()
	End Function
	
	Rem
	bbdoc: Gets the user-and-app-specific path where files can be written.
	about: Get the "pref dir". This is meant to be where users can write personal files (preferences and save games, etc) that are specific
	to your application. This directory is unique per user, per application.

	This function will decide the appropriate location in the native filesystem, create the directory if necessary, and return a string in platform-dependent
	notation, suitable for passing to #SetWriteDir().

	On Windows, this might look like: "C:\\Users\\bob\\AppData\\Roaming\\My Company\\My Program Name"

	On Linux, this might look like: "/home/bob/.local/share/My Program Name"

	On Mac OS X, this might look like: "/Users/bob/Library/Application Support/My Program Name"

	(etc.)

	You should probably use the pref dir for your write dir, and also put it near the beginning of your search path.
	This finds the correct location for whatever platform, which not only changes between operating systems, but also versions of the same operating system.

	You specify the name of your organization (if it's not a real organization, your name or an Internet domain you own might do) and the name of
	your application. These should be proper names.

	Both the (org) and (app) strings may become part of a directory name, so please follow these rules:

	Try to use the same org string (including case-sensitivity) for all your applications that use this function.
	Always use a unique app string for each one, and make sure it never changes for an app once you've decided on it.
	Unicode characters are legal, as long as it's UTF-8 encoded, but...
	...only use letters, numbers, and spaces. Avoid punctuation like "Game Name 2: Bad Guy's Revenge!" ... "Game Name 2" is sufficient.
	
	> You should assume the path returned by this function is the only safe place to write files.
	End Rem
	Function GetPrefDir:String(org:String, app:String)
		Return bmx_PHYSFS_getPrefDir(org, app)
	End Function

	Rem
	bbdoc: Gets various information about a directory or a file.
	End Rem
	Function Stat:Int(filename:String, _stat:SMaxIO_Stat Var)
		Return bmx_PHYSFS_stat(filename, _stat)
	End Function
	
	Rem
	bbdoc: Deletes a file or directory.
	about: @path is specified in platform-independent notation in relation to the write dir.
	
	A directory must be empty before this call can delete it.

	Deleting a symlink will remove the link, not what it points to, regardless of whether you "permitSymLinks" or not.

	So if you've got the write dir set to "C:\mygame\writedir" and call DeletePath("downloads/maps/level1.map") then the file
	"C:\mygame\writedir\downloads\maps\level1.map" is removed from the physical filesystem, if it exists and the operating system permits the deletion.

	Note that on Unix systems, deleting a file may be successful, but the actual file won't be removed until all processes that have
	an open filehandle to it (including your program) close their handles.

	Chances are, the bits that make up the file still exist, they are just made available to be written over at a later point. Don't
	consider this a security method or anything.
	End Rem
	Function DeletePath:Int(path:String)
		Return bmx_PHYSFS_delete(path)
	End Function
	
	Rem
	bbdoc: Opens a file for writing.
	about: Opens a file for writing, in platform-independent notation and in relation to the write dir as the root of the writable filesystem.
	The specified file is created if it doesn't exist. If it does exist, it is truncated to zero bytes, and the writing offset is set to the start.

	Note that entries that are symlinks are ignored if PermitSymbolicLinks(True) hasn't been called, and opening a symlink with this function will
	fail in such a case.
	End Rem
	Function OpenWrite:Byte Ptr(path:String)
		Return bmx_PHYSFS_openWrite(path)
	End Function
	
	Rem
	bbdoc: Closes a file handle.
	about: This call is capable of failing if the operating system was buffering writes to the physical media, and, now forced to write those
	changes to physical media, can not store the data for some reason. In such a case, the filehandle stays open. A well-written program
	should ALWAYS check the return value from the close call in addition to every writing call!
	End Rem
	Function Close:Int(filePtr:Byte Ptr)
		Return PHYSFS_close(filePtr)
	End Function
	
	Rem
	bbdoc: Creates a directory.
	about: This is specified in platform-independent notation in relation to the write dir. All missing parent directories are also created if they don't exist.
	End Rem
	Function MkDir:Int(dirName:String)
		Return bmx_PHYSFS_mkdir(dirName)
	End Function
	
End Type
