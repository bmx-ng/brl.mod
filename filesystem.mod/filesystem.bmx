
SuperStrict

Rem
bbdoc: System/File system
End Rem
Module BRL.FileSystem

ModuleInfo "Version: 1.10"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.11"
ModuleInfo "History: Added optional parameter timetype to FileTime"
ModuleInfo "History: 1.10"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed RealPath breaking win32 //server paths"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Rebuild for StdC chmod_ linkage"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Fixed RealPath failing with 'hidden' dirs"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Win32 CreateDir"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Cleaned up FixPath and RealPath"
ModuleInfo "History: Added optional resurse parameter to CreateDir"

Import Pub.StdC
Import BRL.BankStream

Const FILETYPE_NONE:Int=0,FILETYPE_FILE:Int=1,FILETYPE_DIR:Int=2
Const FILETIME_MODIFIED:Int=0,FILETIME_CREATED:Int=1

Private

Function _RootPath$( path$ )
	If MaxIO.ioInitialized Then
		Return "/"
	End If
?Win32
	If path.StartsWith( "//" )
		Return path[ ..path.Find( "/",2 )+1 ]
	EndIf
	Local i:Int=path.Find( ":" )
	If i<>-1 And path.Find( "/" )=i+1 Return path[..i+2]
?
	If path.StartsWith( "/" ) Return "/"
End Function

Function _IsRootPath:Int( path$ )
	Return path And _RootPath( path )=path
End Function

Function _IsRealPath:Int( path$ )
	Return _RootPath( path )<>""
End Function

?Win32
Function _CurrentDrive$()
	Local cd$=getcwd_()
	Local i:Int=cd.Find( ":" )
	If i<>-1 Return cd[..i]
End Function
?

Public

Function FixPath( path$ Var,dirPath:Int=False )
	path=path.Replace("\","/")
	If Not MaxIO.ioInitialized Then
?Win32
	If path.StartsWith( "//" )
		If path.Find( "/",2 )=-1 path:+"/"
	Else
		Local i:Int=path.Find( ":" )
		If i<>-1 And ( i=path.length-1 Or path[i+1]<>Asc(":") )
			Local i2:Int=path.Find( "/" )
			If i2=-1 Or i2>i+1 path=path[..i+1]+"/"+path[i+1..]
		EndIf
	EndIf
?
	End If
	If dirPath And path.EndsWith( "/" ) 
		If Not _IsRootPath( path ) path=path[..path.length-1]
	EndIf

End Function

Rem
bbdoc: Strip directory from a file path
End Rem
Function StripDir$( path$ )
	FixPath path
	Local i:Int=path.FindLast( "/" )
	If i<>-1 Return path[i+1..]
	Return path
End Function

Rem
bbdoc: Strip extension from a file path
End Rem
Function StripExt$( path$ )
	FixPath path
	Local i:Int=path.FindLast( "." )
	If i<>-1 And path.Find( "/",i+1 )=-1 Return path[..i]
	Return path
End Function

Rem
bbdoc: Strip directory and extension from a file path
End Rem
Function StripAll$( path$ )
	Return StripDir( StripExt( path ) )
End Function

Rem
bbdoc: Strip trailing slash from a file path
about:
#StripSlash will not remove the trailing slash from a 'root' path. For example, "/"
or (on Win32 only) "C:/".
End Rem
Function StripSlash$( path$ )
	FixPath path
	If path.EndsWith( "/" ) And Not _IsRootPath( path ) path=path[..path.length-1]
	Return path
End Function

Rem
bbdoc: Extract directory from a file path
End Rem
Function ExtractDir$( path$ )
	FixPath path
	If path="." Or path=".." Or _IsRootPath( path ) Return path

	Local i:Int=path.FindLast( "/" )
	If i=-1 Return ""
	
	If _IsRootPath( path[..i+1] ) i:+1
	Return path[..i]
End Function

Rem
bbdoc: Extract extension from a file path
End Rem
Function ExtractExt$( path$ )
	FixPath path
	Local i:Int=path.FindLast( "." )
	If i<>-1 And path.Find( "/",i+1 )=-1 Return path[i+1..]
End Function

Rem
bbdoc: Get Current Directory
returns: The current directory
End Rem
Function CurrentDir$()
	If MaxIO.ioInitialized Then
		Return "/"
	End If
	Local path$=getcwd_()
	FixPath path
	Return path
End Function

Rem
bbdoc: Get real, absolute path of a file path
End Rem
Function RealPath$( path$ )
?Win32
	If path.StartsWith( "/" ) And Not path.StartsWith( "//" )
		path=_CurrentDrive()+":"+path
	EndIf
?
	FixPath path
	Local cd$=_RootPath( path )

	If cd
		path=path[cd.length..]
	Else
		cd=CurrentDir()
	EndIf
	
	path:+"/"
	While path
		Local i:Int=path.Find( "/" )
		Local t$=path[..i]
		path=path[i+1..]
		Select t
		Case ""
		Case "."
		Case ".."
			If Not _IsRootPath( cd ) cd=cd[..cd.FindLast("/")]
		Default
			If Not cd.EndsWith( "/" ) cd:+"/"
			cd:+t
		End Select
	Wend
	
	Return cd
End Function

Rem
bbdoc: Get file type
returns: 0 if file at @path doesn't exist, FILETYPE_FILE (1) if the file is a plain file or FILETYPE_DIR (2) if the file is a directory
End Rem
Function FileType:Int( path$ )
	FixPath path
	If MaxIO.ioInitialized Then
		Local stat:SMaxIO_Stat
		If Not MaxIO.Stat(path, stat) Return 0
		Select stat._filetype
			Case EMaxIOFileType.REGULAR Return FILETYPE_FILE
			Case EMaxIOFileType.DIRECTORY Return FILETYPE_DIR
		End Select
	Else
		Local Mode:Int,size:Long,mtime:Int,ctime:Int
		If stat_( path,Mode,size,mtime,ctime ) Return 0
		Select Mode & S_IFMT_
		Case S_IFREG_ Return FILETYPE_FILE
		Case S_IFDIR_ Return FILETYPE_DIR
		End Select
	End If
	Return FILETYPE_NONE
End Function

Rem
bbdoc: Get file time
returns: The time the file at @path was last modified 
End Rem
Function FileTime:Long( path$, timetype:Int=FILETIME_MODIFIED )
	FixPath path
	If MaxIO.ioInitialized Then
		Local stat:SMaxIO_Stat
		If Not MaxIO.Stat(path, stat) Return 0
		If timetype = FILETIME_CREATED Then
			Return stat._createtime
		Else
			Return stat._modtime
		End If
	Else
		Local Mode:Int,size:Long,mtime:Int,ctime:Int
		If stat_( path,Mode,size,mtime,ctime ) Return 0
		If(timetype = FILETIME_CREATED)
			Return ctime
		Else
			Return mtime
		EndIf
	End If
End Function

Rem
bbdoc: Get file size
returns: Size, in bytes, of the file at @path, or -1 if the file does not exist
end rem
Function FileSize:Long( path$ )
	FixPath path
	If MaxIO.ioInitialized Then
		Local stat:SMaxIO_Stat
		If Not MaxIO.Stat(path, stat) Return -1
		Return stat._filesize
	Else
		Local Mode:Int,size:Long,mtime:Int,ctime:Int
		If stat_( path,Mode,size,mtime,ctime ) Return -1
		Return size
	End If
End Function

Rem
bbdoc: Get file mode
returns: file mode flags
end rem
Function FileMode:Int( path$ )
	FixPath path
	If Not MaxIO.ioInitialized Then
		Local Mode:Int,size:Long,mtime:Int,ctime:Int
		If stat_( path,Mode,size,mtime,ctime ) Return -1
		Return Mode & 511
	End If
End Function

Rem
bbdoc: Set file mode
end rem
Function SetFileMode( path$,Mode:Int )
	FixPath path
	If Not MaxIO.ioInitialized Then
		chmod_ path,Mode
	End If
End Function

Rem
bbdoc: Create a file
returns: True if successful
End Rem
Function CreateFile:Int( path$ )
	FixPath path
	If MaxIO.ioInitialized Then
		MaxIO.DeletePath(path)
		Local t:Byte Ptr = MaxIO.OpenWrite(path)
		If t MaxIO.Close(t)
	Else
		remove_ path
		Local t:Byte Ptr=fopen_( path,"wb" )
		If t fclose_ t
	End If
	If FileType( path )=FILETYPE_FILE Return True
End Function

Rem
bbdoc: Create a directory
returns: True if successful
about:
If @recurse is true, any required subdirectories are also created.
End Rem
Function CreateDir:Int( path$,recurse:Int=False )
	FixPath path,True
	If MaxIO.ioInitialized Then
		Return MaxIO.MkDir(path)
	Else
		If Not recurse
			mkdir_ path,1023
			Return FileType(path)=FILETYPE_DIR
		EndIf
		Local t$
		path=RealPath(path)+"/"
		While path
			Local i:Int=path.find("/")+1
			t:+path[..i]
			path=path[i..]
			Select FileType(t)
			Case FILETYPE_DIR
			Case FILETYPE_NONE
				Local s$=StripSlash(t)
				mkdir_ StripSlash(s),1023
				If FileType(s)<>FILETYPE_DIR Return False
			Default
				Return False
			End Select
		Wend
		Return True
	End If
End Function

Rem
bbdoc: Delete a file
returns: True if successful
End Rem
Function DeleteFile:Int( path$ )
	FixPath path
	If MaxIO.ioInitialized Then
		MaxIO.DeletePath(path)
	Else
		remove_ path
	End If
	Return FileType(path)=FILETYPE_NONE
End Function

Rem
bbdoc: Renames a file
returns: True if successful
End Rem
Function RenameFile:Int( oldpath$,newpath$ )
	If MaxIO.ioInitialized Then
		Return False
	End If
	FixPath oldpath
	FixPath newpath
	Return rename_( oldpath,newpath)=0
End Function

Rem
bbdoc: Copy a file
returns: True if successful
End Rem
Function CopyFile:Int( src$,dst$ )
	Local in:TStream=ReadStream( src ),ok:Int
	If in
		Local out:TStream=WriteStream( dst )
		If out
			Try
				CopyStream in,out
				ok=True
			Catch ex:TStreamWriteException
			End Try
			out.Close
		EndIf
		in.Close
	EndIf
	Return ok
End Function

Rem
bbdoc: Copy a directory
returns: True if successful
End Rem
Function CopyDir:Int( src$,dst$ )

	Function CopyDir_:Int( src$,dst$ )
		If FileType( dst )=FILETYPE_NONE CreateDir dst
		If FileType( dst )<>FILETYPE_DIR Return False
		For Local file$=EachIn LoadDir( src )
			Select FileType( src+"/"+file )
			Case FILETYPE_DIR
				If Not CopyDir_( src+"/"+file,dst+"/"+file ) Return False
			Case FILETYPE_FILE
				If Not CopyFile( src+"/"+file,dst+"/"+file ) Return False
			End Select
		Next
		Return True
	End Function
	
	FixPath src
	If FileType( src )<>FILETYPE_DIR Return False

	FixPath dst
	
	Return CopyDir_( src,dst )

End Function

Rem
bbdoc: Delete a directory
returns: True if successful
about: Set @recurse to true to delete all subdirectories and files recursively - 
but be careful!
End Rem
Function DeleteDir:Int( path$,recurse:Int=False )
	FixPath path,True
	If recurse
		Local dir:Byte Ptr=ReadDir( path )
		If Not dir Return False
		Repeat
			Local t$=NextFile( dir )
			If t="" Exit
			If t="." Or t=".." Continue
			Local f$=path+"/"+t
			Select FileType( f )
				Case 1 DeleteFile f
				Case 2 DeleteDir f,True
			End Select
		Forever
		CloseDir dir
	EndIf
	rmdir_ path
	If FileType( path )=0 Return True
End Function

Rem
bbdoc: Change current directory
returns: True if successful
End Rem
Function ChangeDir:Int( path$ )
	If MaxIO.ioInitialized Then
		Return False
	Else
		FixPath path,True
		If chdir_( path )=0 Return True
	End If
End Function

Rem
bbdoc: Open a directory
returns: A directory handle, or Null if the directory does not exist
End Rem
Function ReadDir:Byte Ptr( path$ )
	FixPath path,True
	If MaxIO.ioInitialized Then
		Return bmx_blitzio_readdir(path)
	Else
		Return opendir_( path )
	End If
End Function

Rem
bbdoc: Return next file in a directory
returns: File name of next file in directory opened using #ReadDir, or an empty string if there are no more files to read.
End Rem
Function NextFile$( dir:Byte Ptr )
	If MaxIO.ioInitialized Then
		Return bmx_blitzio_nextFile(dir)
	Else
		Return readdir_( dir )
	End If
End Function

Rem
bbdoc: Close a directory
End Rem
Function CloseDir( dir:Byte Ptr )
	If MaxIO.ioInitialized Then
		bmx_blitzio_closeDir(dir)
	Else
		closedir_ dir
	End If
End Function

Rem
bbdoc: Load a directory
returns: A string array containing contents of @dir
about: The @skip_dots parameter, if true, removes the '.' (current) and '..'
(parent) directories from the returned array.
end rem
Function LoadDir$[]( dir$,skip_dots:Int=True )
	FixPath dir,True
	Local d:Byte Ptr=ReadDir( dir )
	If Not d Return Null
	Local i$[100],n:Int
	Repeat
		Local f$=NextFile( d )
		If Not f Exit
		If skip_dots And (f="." Or f="..") Continue
		If n=i.length i=i[..n+100]
		i[n]=f
		n=n+1
	Forever
	CloseDir d
	Return i[..n]
End Function

Rem
bbdoc: Open a file for input and/or output.
about:
This command is similar to the #OpenStream command but will attempt
to cache the contents of the file to ensure serial streams such as 
http: based url's are seekable. Use the #CloseStream command when
finished reading and or writing to a Stream returned by #OpenFile.
End Rem
Function OpenFile:TStream( url:Object,readable:Int=True,writeable:Int=True )
	Local stream:TStream=OpenStream( url,readable,writeable )
	If Not stream Return Null
	If stream.Pos()=-1 Return TBankStream.Create( TBank.Load(stream) )
	Return stream
End Function

Rem
bbdoc: Open a file For Input.
about:
This command is similar to the #ReadStream command but will attempt
to cache the contents of the file to ensure serial streams such as 
http: based url's are seekable. Use the #CloseStream command when
finished reading and or writing to a Stream returned by #OpenFile.
End Rem
Function ReadFile:TStream( url:Object )
	Return OpenFile( url,True,False )
End Function

Rem
bbdoc: Open a file for output.
about:
This command is identical to the #WriteStream command.
End Rem
Function WriteFile:TStream( url:Object )
	Return OpenFile( url,False,True )
End Function

Rem
bbdoc: Closes a file stream.
about:
After performing file operations on an open file make sure to
close the file stream with either #CloseFile or the identical
#CloseStream command.
End Rem
Function CloseFile( stream:TStream )
	stream.Close
End Function
