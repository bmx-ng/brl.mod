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

Rem
bbdoc: IO Abstraction
End Rem
Module BRL.IO

ModuleInfo "Version: 1.02"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Added PermitSymbolicLinks()"
ModuleInfo "History: Documented SMaxIO_Stat and added SDateTime getters."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added GetWriteDir(), GetRealDir(), IsInit(), GetMountPoint() & SetRoot()"
ModuleInfo "History: Added Unmount() and GetSearchPath()"
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
	Function Init:Int()
		If Not ioInitialized Then
			If Not bmx_PHYSFS_init() Then
				Throw bmx_PHYSFS_getLastError()
			End If
		End If
		ioInitialized = True
		Return True
	End Function

	Rem
	bbdoc: Determines if the #MaxIO is initialized.
	returns: non-zero if #MaxIO is initialized, zero if it is not.
	about: Once #Init() returns successfully, this will return non-zero. Before a successful #Init() and after #DeInit() returns
	successfully, this will return zero. This function is safe to call at any time.
	End Rem
	Function IsInit:Int()
		Return ioInitialized And PHYSFS_isInit()
	End Function
	
	Rem
	bbdoc: Deinitializes the abstraction layer.
	about: This closes any files opened via the abstraction layer, blanks the search/write paths, frees memory, and invalidates all of your file handles.

	Note that this call can FAIL if there's a file open for writing that refuses to close (for example, the underlying operating system was
	buffering writes to network filesystem, and the fileserver has crashed, or a hard drive has failed, etc). It is usually best to close
	all write handles yourself before calling this function, so that you can gracefully handle a specific failure.

	Once successfully deinitialized, #Init() can be called again to restart the subsystem. All default API states are restored at this point.
	End Rem
	Function DeInit:Int()
		If ioInitialized Then
			ioInitialized = False
			Return PHYSFS_deinit()
		End If
	End Function

	Rem
	bbdoc: Adds an archive or directory to the search path.
	returns: Nonzero if added to path, zero on failure (bogus archive, dir missing, etc). 
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

	Setting @appendToPath to #False will instead prepend the archive to the search path.
	This is useful if you want to add an archive that should take precedence over all previously added archives and directories.
	The default is #True, which appends the archive to the end of the search path.
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
	bbdoc: Removes a directory or archive from the search path.
	returns: Nonzero on success, zero on failure. Use #GetLastErrorCode() to obtain the specific error.
	about: This must be a (case-sensitive) match to a dir or archive already in the
	search path, specified in platform-dependent notation.

	This call will fail (and fail to remove from the path) if the element still has files open in it.
	End Rem
	Function Unmount:Int(oldDir:String)
		Return bmx_PHYSFS_unmount(oldDir)
	End Function

	Rem
	bbdoc: Determines a mounted archive's mountpoint.
	returns: The mount point if added to path, or #Null on failure (bogus archive, etc). Use #GetLastErrorCode() to obtain the specific error.
	about: You give this function the name of an archive or dir you successfully
 	added to the search path, and it reports the location in the interpolated
 	tree where it is mounted. Files mounted with a #Null mountpoint will report "/".

	@dir must exactly match the string used when adding, even if your string would also reference the same file with a different string of characters.
	End Rem
	Function GetMountPoint:String(dir:String)
		Return bmx_PHYSFS_getMountPoint(dir)
	End Function

	Rem
	bbdoc: Makes a subdirectory of an archive its root directory.
	returns: Nonzero on success, zero on failure. Use #GetLastErrorCode() to obtain the specific error.
	about: This lets you narrow down the accessible files in a specific archive.
	
	For example, if you have x.zip with a file in y/z.txt, mounted to /a, if you
	call #SetRoot("x.zip", "/y"), then the call #OpenRead("/a/z.txt") will succeed.

	You can change an archive's root at any time, altering the interpolated 
	file tree (depending on where paths shift, a different archive may be
	providing various files). If you set the root to #Null or "/", the
	archive will be treated as if no special root was set (as if the archive
	was just mounted normally).

	Changing the root only affects future operations on pathnames; a file
	that was opened from a path that changed due to a #SetRoot will not be affected.

	Setting a new root is not limited to archives in the search path; you may
	set one on the write dir, too, which might be useful if you have files
	open for write and thus can't change the write dir at the moment.

	It is not an error to set a subdirectory that does not exist to be the
	root of an archive; however, no files will be visible in this case. If
	the missing directories end up getting created (a mkdir to the physical
	filesystem, etc) then this will be reflected in the interpolated tree.
	End Rem
	Function SetRoot:Int(archive:String, subdir:String)
		Return bmx_PHYSFS_setRoot(archive, subdir)
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
	returns: The pref dir in platform-dependent notation, or #Null if there's a problem (creating directory failed, etc).
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
	
	> You should assume the path returned by this function is the only safe place to write files (and that #GetBaseDir(), 
	while they might be writable, or even parents of the returned path, aren't where you should be writing things)..
	End Rem
	Function GetPrefDir:String(org:String, app:String)
		Return bmx_PHYSFS_getPrefDir(org, app)
	End Function
	
	Rem
	bbdoc: Gets the current search path.
	returns: An array of Strings.
	about: The default search path is an empty list.
	End Rem
	Function GetSearchPath:String[]()
		Return bmx_PHYSFS_getSearchPath()
	End Function

	Rem
	bbdoc: Indicates where files may be written.
	about: Sets a new write dir. This will override the previous setting.

	This call will fail (and fail to change the write dir) if the current write dir still has files open in it.

	The directory will be the root of the write dir, specified in platform-dependent notation.
	Setting to #Null disables the write dir, so no files can be opened for writing.
	End Rem
	Function SetWriteDir:Int(newDir:String)
		Return bmx_PHYSFS_setWriteDir(newDir)
	End Function

	Rem
	bbdoc: Gets the path where files may be written.
	about: Gets the current write dir. The default write dir is #Null.
	End Rem
	Function GetWriteDir:String()
		Return bmx_PHYSFS_getWriteDir()
	End Function

	Rem
	bbdoc: Figures out where in the search path a file resides.
	returns: The file location, or #Null if not found.
	about: The file is specified in platform-independent notation. The returned
    filename will be the element of the search path where the file was found,
    which may be a directory, or an archive. Even if there are multiple
    matches in different parts of the search path, only the first one found
    is used, just like when opening a file.
	End Rem
	Function GetRealDir:String(filename:String)
		Return bmx_PHYSFS_getRealDir(filename)
	End Function

	Rem
	bbdoc: Gets various information about a directory or a file, populating the passed in #SMaxIO_Stat instance.
	about: This function will never follow symbolic links. If you haven't enabled
	symlinks with #PermitSymbolicLinks(), stat'ing a symlink will be treated like stat'ing a non-existant file. If symlinks are enabled,
	stat'ing a symlink will give you information on the link itself and not what it points to.
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
	bbdoc: Opens a file for reading.
	about: Opens a file for reading, in platform-independent notation.
	The search path is checked one at a time until a matching file is found, in which case an abstract filehandle is associated with it, and reading may be done.
	The reading offset is set to the first byte of the file.

	Note that entries that are symlinks are ignored if PHYSFS_permitSymbolicLinks(1) hasn't been called, and opening a symlink with this function will fail in such a case.
	End Rem
	Function OpenRead:Byte Ptr(path:String)
		Return bmx_PHYSFS_openRead(path)
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

	Rem
	bbdoc: Returns the last error code.
	about: Calling this function resets the last error code.
	End Rem
	Function GetLastErrorCode:EMaxIOErrorCode()
		Return bmx_PHYSFS_getLastErrorCode()
	End Function

	Rem
	bbdoc: Returns the message for the specified @errorCode.
	End Rem
	Function GetErrorForCode:String(errorCode:EMaxIOErrorCode)
		Return bmx_PHYSFS_getErrorForCode(errorCode)
	End Function

	Rem
	bbdoc: Returns the last error message, or #Null if there is none.
	about: Calling this function resets the last error.
	End Rem
	Function GetLastError:String()
		Return bmx_PHYSFS_getLastError()
	End Function

	Rem
	bbdoc: Enables or disables following of symbolic links.
	about: Some physical filesystems and archives contain files that are just pointers
	to other files. On the physical filesystem, opening such a link will
	(transparently) open the file that is pointed to.

	By default, MaxIO will check if a file is really a symlink during open
	calls and fail if it is. Otherwise, the link could take you outside the
	write and search paths, and compromise security.

	If you want to take that risk, call this function with a non-zero parameter.
	Note that this is more for sandboxing a program's scripting language, in
	case untrusted scripts try to compromise the system. Generally speaking,
	a user could very well have a legitimate reason to set up a symlink, so
	unless you feel there's a specific danger in allowing them, you should
	permit them.

	Symlinks are only explicitly checked when dealing with filenames
	in platform-independent notation. That is, when setting up your
	search and write paths, etc, symlinks are never checked for.

	Please note that #Stat() will always check the path specified; if
	that path is a symlink, it will not be followed in any case. If symlinks
	aren't permitted through this function, #Stat() ignores them, and
	would treat the query as if the path didn't exist at all.

	Symbolic link permission can be enabled or disabled at any time after
	you've called #Init(), and is disabled by default.
	End Rem
	Function PermitSymbolicLinks:Int(allow:Int)
		Return PHYSFS_permitSymbolicLinks(allow)
	End Function

	Rem
	bbdoc: Determine if symbolic links are permitted.
	returns: #True if symlinks are permitted, #False if not.
	about: This reports the setting from the last call to #PermitSymbolicLinks().

	If #PermitSymbolicLinks() hasn't been called since the library was last initialized, symbolic links are implicitly disabled.
	End Rem
	Function SymbolicLinksPermitted:Int()
		Return PHYSFS_symbolicLinksPermitted()
	End Function

End Type
