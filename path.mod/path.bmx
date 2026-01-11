' Copyright (c) 2026 Bruce A Henderson
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
bbdoc: Filesystem/Paths
about: Provides the #TPath class for representing and manipulating filesystem paths,
End Rem
Module BRL.Path

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import BRL.Glob

Rem
bbdoc: Class representing and manipulating file system paths.
End Rem
Type TPath
Private
	Field _path:String
Public
	Rem
	bbdoc: Creates a #TPath object from a string path.
	End Rem
	Method New(path:String)
		_path = path
		FixPath _path, True
		If Not _IsRootPath(_path) Then
			_path = StripSlash(_path)
		End If
	End Method

	Rem
	bbdoc: Creates a #TPath object from a string path.
	End Rem
	Function FromString:TPath(path:String)
		Return New TPath(path)
	End Function

	Rem
	bbdoc: Creates a #TPath by joining an array of multiple parts.
	about: Each part can be either a #TPath or a string.

	Note that if any part is rooted, it replaces any previously accumulated path.
	End Rem
	Function FromParts:TPath(parts:Object[])
		If parts = Null Or parts.Length = 0 Then
			Return New TPath("") ' empty path
		End If

		Local acc:TPath = Null

		For Local part:Object = EachIn parts
			Local s:String

			Local tp:TPath = TPath(part)
			If tp Then
				s = tp._path
			Else
				If ObjectIsString(part) Then
					s = String(part)
				Else
					Throw "TPath.FromParts: Invalid part. Must be TPath or String."
				End If
			End If

			If acc = Null Then
				acc = New TPath(s)
			Else
				acc = acc.Join(s)
			End If
		Next

		Return acc
	End Function

	Rem
	bbdoc: Returns the string representation of the path.
	End Rem
	Method ToString:String() Override
		Return _path
	End Method

	Rem
	bbdoc: Compares this path with another object for equality.
	about: Returns #True if the other object is a #TPath and represents the same path.
	End Rem
	Method Equals:Int(other:Object) Override
		If Not other Then
			Return False
		End If
		If other = Self Then
			Return True
		End If
		Local p:TPath = TPath(other)
		If Not p Then
			Return False
		End If
		Return _path = p._path
	End Method

	Rem
	bbdoc: Compares this path with another object for ordering.
	about: Returns a negative value if this path is less than the other path,
	zero if they are equal, and a positive value if this path is greater than the other path.
	End Rem
	Method Compare:Int(other:Object) Override
		If Not other Then
			Return 1
		End If
		Local p:TPath = TPath(other)
		If Not p Then
			' Arbitrary but consistent: TPath > non-TPath
			Return 1
		End If
		Return _path.Compare(p._path)
	End Method

	Rem
	bbdoc: Returns a hash code for the path.
	about: This uses the hash code of the underlying string path.
	End Rem
	Method HashCode:UInt() Override
		Return _path.HashCode()
	End Method

	Rem
	bbdoc: Returns the name of the file or directory represented by the path.
	about: This is equivalent to the last component of the path.
	For example, for the path "/etc/init.d/reboot", this method would return "reboot".
	End Rem
	Method Name:String()
		Return StripDir(_path)
	End Method

	Rem
	bbdoc: Returns the base name of the file without its extension.
	about: For example, for the path "/etc/init.d/reboot.sh", this method would return "reboot".
	Files beginning with a dot (e.g., ".bashrc") are treated as having no extension.
	End Rem
	Method BaseName:String()
		Local name:String = Name()
		If name.StartsWith(".") Then
			If name.Find(".", 1) = -1 Then
				' simple dotfile => no extension
				Return name
			End If
		End If
		Return StripExt(name)
	End Method

	Rem
	bbdoc: Returns the extension of the file.
	about: For example, for the path "/etc/init.d/reboot.sh", this method would return "sh".
	Files beginning with a dot (e.g., ".bashrc") are treated as having no extension.
	End Rem
	Method Extension:String()
		Local name:String = Name()
		If name.StartsWith(".") Then
			' if there is no other dot after the first char, treat as no extension
			If name.Find(".", 1) = -1 Then
				Return ""
			End If
		End If
		Return ExtractExt(_path)
	End Method

	Rem
	bbdoc: Returns the parent directory of the path as a #TPath object.
	about: For example, for the path "/etc/init.d/reboot", this method would return a #TPath representing "/etc/init.d".
	For root paths, returns the same #TPath instance.
	End Rem
	Method Parent:TPath()
		If _IsRootPath(_path) Then
			Return Self
		End If
		Local d:String = ExtractDir(_path)
		If d = "" Then
			d = "."
		End If
		Return New TPath(d)
	End Method

	Rem
	bbdoc: Joins the current path with another string path.
	about: If the provided path is rooted, it replaces the current path.
	Otherwise, it appends the provided path to the current path.
	End Rem
	Method Join:TPath(part:String)
		Local p:String = part
		FixPath p, True

		' If RHS is rooted, it replaces LHS
		If _RootPath(p) <> "" Then
			Return New TPath(p)
		End If

		If _path = "" Then
			Return New TPath(p)
		End If
		Return New TPath(_path + "/" + p)
	End Method

	Rem
	bbdoc: Joins the current path with another #TPath.
	about: If the provided path is rooted, it replaces the current path.
	Otherwise, it appends the provided path to the current path.
	End Rem
	Method Join:TPath(other:TPath)
		If other = Null Then
			Return Self
		End If
		' If rooted, return other as-is
		If _RootPath(other._path) <> "" Then
			Return other
		End If
		' Else append
		Return Self.Join(other._path)
	End Method

	Rem
	bbdoc: Joins the current path with another #TPath.
	about: If the provided path is rooted, it replaces the current path.
	Otherwise, it appends the provided path to the current path.
	End Rem
	Method Child:TPath(name:String)
		Return Join(name)
	End Method

	Rem
	bbdoc: Joins the current path with another #TPath.
	about: If the provided path is rooted, it replaces the current path.
	Otherwise, it appends the provided path to the current path.
	End Rem
	Method Child:TPath(other:TPath)
		Return Join(other)
	End Method

	Rem
	bbdoc: Resolves the provided #TPath against the current path.
	about: If the provided path is rooted, it is returned as-is.
	Otherwise, it is appended to the current path.
	End Rem
	Method Resolve:TPath(other:TPath)
		If other = Null Then
			Return Self
		End If
		' If rooted, return other as-is
		If _RootPath(other._path) <> "" Then
			Return other
		End If
		' Else append
		Return Self.Join(other._path)
	End Method

	Rem
	bbdoc: Resolves the provided string path against the current path.
	about: If the provided path is rooted, it is returned as a new #TPath.
	Otherwise, it is appended to the current path.
	End Rem
	Method Resolve:TPath(part:String)
		Return Self.Join(part)
	End Method

	Rem
	bbdoc: Returns a #TPath representing the relative path from this path to another path.
	about: For example, if this path is "/a/b/c" and the other path is "/a/d/e",
	this method would return a #TPath representing "../../d/e".
	End Rem
	Method Relativize:TPath(other:TPath)
		If other = Null Then
			Throw "TPath.Relativize: other is Null"
		End If

		Local a:String = _path
		Local b:String = other._path

		' Equal => empty
		If a = b Then
			Return New TPath("")
		End If

		Local ra:String = _RootPath(a)
		Local rb:String = _RootPath(b)

		' One rooted, one not => cannot
		If (ra <> "") <> (rb <> "") Then
			Throw "TPath.Relativize: Cannot relativize rooted and non-rooted paths."
		End If

		' Both rooted but different roots => cannot
		If ra <> "" And ra <> rb Then
			Throw "TPath.Relativize: Paths have different roots."
		End If

		' Strip roots for segment comparison
		Local aa:String = a
		Local bb:String = b
		If ra <> "" Then
			aa = a[ra.Length..]
			bb = b[rb.Length..]
		End If

		Local asegs:String[] = _SplitSegments(aa)
		Local bsegs:String[] = _SplitSegments(bb)

		' Find common prefix length
		Local i:Int = 0
		While i < asegs.Length And i < bsegs.Length And asegs[i] = bsegs[i]
			i :+ 1
		Wend

		' Build relative segments
		Local rel:TList = New TList

		For Local j:Int = i Until asegs.Length
			rel.AddLast("..")
		Next

		For Local j:Int = i Until bsegs.Length
			rel.AddLast(bsegs[j])
		Next

		' Join segments
		Local out:String = ""
		For Local s:String = EachIn rel
			If out <> "" Then
				out :+ "/"
			End If
			out :+ s
		Next

		Return New TPath(out)
	End Method

	Rem
	bbdoc: Returns the real (absolute) path as a #TPath object.
	End Rem
	Method Real:TPath()
		Return New TPath(RealPath(_path))
	End Method

	Rem
	bbdoc: Joins the current path with another string path using the / operator.
	about: Allows you to write in the form: 
	```
		Local p:TPath = New TPath("/etc") / "init.d" / "reboot"
	```
	End Rem
	Method Operator/:TPath(part:String)
		Return Join(part)
	End Method

	Rem
	bbdoc: Joins the current path with another #TPath using the / operator.
	End Rem
	Method Operator/:TPath(other:TPath)
		Return Join(other._path)
	End Method

	Rem
	bbdoc: Returns #True if the path exists.
	End Rem
	Method Exists:Int()
		Return FileExists(_path)
	End Method

	Rem
	bbdoc: Returns the type of the path: #FILETYPE_FILE, #FILETYPE_DIR, or #FILETYPE_NONE.
	End Rem
	Method FileType:Int()
		Return Brl.FileSystem.FileType(_path)
	End Method

	Rem
	bbdoc: Returns #True if the path represents a file.
	End Rem
	Method IsFile:Int()
		Return FileType() = FILETYPE_FILE
	End Method

	Rem
	bbdoc: Returns #True if the path represents a directory.
	End Rem
	Method IsDir:Int()
		Return FileType() = FILETYPE_DIR
	End Method

	Rem
	bbdoc: Returns the size of the file in bytes.
	End Rem
	Method Size:Long()
		Return FileSize(_path)
	End Method

	Rem
	bbdoc: Returns the last modified time of the file, representing the number of seconds since the epoch (January 1, 1970).
	End Rem
	Method ModifiedTime:Long()
		Return FileTime(_path, FILETIME_MODIFIED)
	End Method

	Rem
	bbdoc: Returns the last modified date and time of the file as an SDateTime structure.
	End Rem
	Method ModifiedDateTime:SDateTime()
		Return FileDateTime(_path, FILETIME_MODIFIED)
	End Method

	Rem
	bbdoc: Returns the creation time of the file, representing the number of seconds since the epoch (January 1, 1970).
	End Rem
	Method CreatedTime:Long()
		Return FileTime(_path, FILETIME_CREATED)
	End Method

	Rem
	bbdoc: Returns the creation date and time of the file as an SDateTime structure.
	End Rem
	Method CreatedDateTime:SDateTime()
		Return FileDateTime(_path, FILETIME_CREATED)
	End Method

	Rem
	bbdoc: Opens the path as a stream.
	about: By default, the stream is opened for both reading and writing.
	The @readable and @writeable parameters can be used to control the access mode.
	Note that if both are set to #True, the file should already exist.

	The stream must be closed after use to ensure data is flushed to disk and to avoid resource leaks.
	End Rem
	Method Open:TStream(readable:Int = True, writeable:Int = True)
		Return OpenFile(_path, readable, writeable)
	End Method

	Rem
	bbdoc: Opens the path for reading as a stream.
	about: The stream must be closed after use to avoid resource leaks.
	End Rem
	Method Read:TStream()
		Return ReadFile(_path)
	End Method

	Rem
	bbdoc: Opens the path for writing as a stream.
	about: If the file does not exist, it will be created. If it does exist, it will be truncated.

	The stream must be closed after use to ensure data is flushed to disk and to avoid resource leaks.
	End Rem
	Method Write:TStream()
		Return WriteFile(_path)
	End Method

	Rem
	bbdoc: Creates an empty file at the path.
	End Rem
	Method CreateFile:Int()
		Return Brl.FileSystem.CreateFile(_path)
	End Method

	Rem
	bbdoc: Creates a directory at the path.
	about: If the directory already exists, this method does nothing and returns success.
	If the @recurse parameter is set to #True, any necessary parent directories will also be created.
	End Rem
	Method CreateDir:Int(recurse:Int = False)
		Return Brl.FileSystem.CreateDir(_path, recurse)
	End Method

	Rem
	bbdoc: Deletes the file at the path.
	End Rem
	Method DeleteFile:Int()
		Return Brl.FileSystem.DeleteFile(_path)
	End Method

	Rem
	bbdoc: Deletes the directory at the path.
	about: If the @recurse parameter is set to #True, the directory and all its contents will be deleted.
	End Rem
	Method DeleteDir:Int(recurse:Int = False)
		Return Brl.FileSystem.DeleteDir(_path, recurse)
	End Method

	Rem
	bbdoc: Renames or moves the path to the destination path.
	about: Returns #True on success, and populates @newPath with the new path.
	End Rem
	Method RenameTo:Int(dst:TPath, newPath:TPath Var)
		If Brl.FileSystem.RenameFile(_path, dst._path) Then
			newPath = New TPath(dst._path)
			Return True
		Else
			newPath = Self
			Return False
		End If
	End Method

	Rem
	bbdoc: Renames or moves the path to the destination path.
	about: Returns #True on success.
	End Rem
	Method RenameTo:Int(dst:TPath)
		Return Brl.FileSystem.RenameFile(_path, dst._path)
	End Method

	Rem
	bbdoc: Copies the file at the path to the destination path.
	End Rem
	Method CopyFileTo:Int(dst:TPath)
		Return Brl.FileSystem.CopyFile(_path, dst._path)
	End Method

	Rem
	bbdoc: Copies the directory at the path to the destination path.
	about: If the destination directory does not exist, it will be created.
	End Rem
	Method CopyDirTo:Int(dst:TPath)
		Return Brl.FileSystem.CopyDir(_path, dst._path)
	End Method

	Rem
	bbdoc: Returns a new #TPath with the specified extension.
	about: If the provided extension starts with a dot, it will be removed.
	End Rem
	Method WithExtension:TPath(ext:String)
		Local dir:String = ExtractDir(_path)
		Local base:String = BaseName()
		If ext.StartsWith(".") Then
			ext = ext[1..]
		End If
		Local name:String = base
		If ext <> "" Then
			name :+ "." + ext
		End If
		If dir = "" Or dir = "." Then
			Return New TPath(name)
		Else
			Return New TPath(dir + "/" + name)
		End If
	End Method

	Rem
	bbdoc: Returns a new #TPath with the specified name in the same directory.
	End Rem
	Method WithName:TPath(name:String)
		Return Parent().Join(name)
	End Method

	Rem
	bbdoc: Returns an iterator over the direct children of this directory.
	about:
	Enumerates entries directly contained in this path (non-recursive) and yields a #TPath
	for each entry.

	The returned iterator should be closed if not fully consumed, either by calling #Close
	or by using a #Using block.
	End Rem
	Method IterDir:TPathDirIterator(skipDots:Int = True)
		Return TPathDirIterator.Create(Self, skipDots)
	End Method

	Rem
	bbdoc: Returns the direct children of this directory as an array of #TPath.
	about: This is the eager equivalent of #IterDir.
	End Rem
	Method List:TPath[](skipDots:Int = True)
		Local lst:TList = New TList
		Using
			Local iter:TPathDirIterator = IterDir(skipDots)
		Do
			While iter.MoveNext()
				lst.AddLast(iter.Current())
			Wend
		End Using

		Local out:TPath[] = New TPath[lst.Count()]
		Local i:Int = 0
		For Local path:TPath = EachIn lst
			out[i] = path
			i :+ 1
		Next
		Return out
	End Method

	Rem
	bbdoc: Returns an iterator that yields paths matching the specified glob pattern.
	about:
	Expands a glob @pattern into an iterator of matching files and/or directories.

	The glob pattern supports the following constructs:

	* `*` matches zero or more characters within a single path segment.
	* `?` matches exactly one character within a single path segment.
	* Character classes such as `[abc]`, `[a-z]`, and negated classes `[!abc]` or `[^abc]`.
	* Backslash escaping of metacharacters (unless the #EGlobOptions.NoEscape flag is set).
	* The `**` globstar operator (when #EGlobOptions.GlobStar is enabled) to match zero or more directory levels.

	By default, wildcard patterns do not match entries whose names begin with `.`.
	This behavior can be changed by enabling the #EGlobOptions.Period flag.

	Brace expansion using curly braces is supported.

	A pattern of the form `{a,b}` is expanded into multiple patterns before globbing is performed. For example:

	* `"src/{core,ui}/*.bmx"` expands to `"src/core/*.bmx"` and `"src/ui/*.bmx"`.

	Brace expressions may be nested. Expansion is purely textual and occurs before any wildcard matching.

	Only brace expressions containing at least one top-level comma are expanded.
	Malformed or unterminated brace expressions are treated as literal text.

	Note that `**/pattern` matches only files below the starting directory.
	To include files in the starting directory, combine with pattern using brace expansion.
	For example, `{pattern,**/pattern}`.

	Backslash-escaped braces (`\{` and `\}`) are treated literally unless #EGlobOptions.NoEscape is specified.

	If @pattern is not rooted, globbing begins relative to @baseDir if supplied,
	or the current directory as returned by #CurrentDir.
	If @pattern is rooted, @baseDir is ignored and matching begins at the root.

	The returned paths are:

	* Rooted paths if @pattern is rooted.
	* Paths relative to @baseDir (or the current directory) if @pattern is not rooted.

	The @flags parameter controls additional matching behavior and result filtering.
	See #EGlobOptions for details.

	The globbing implementation works consistently for both the native filesystem
	and the virtual filesystem when #BRL.Io / #MaxIO is enabled.

	The returned iterator should be closed if not fully consumed, to release any held resources.
	This can be done manually by calling #Close(), or automatically via a #Using block.
	End Rem
	Method GlobIter:TPathIterator(pattern:String, flags:EGlobOptions = EGlobOptions.None)
		Local inner:IIterator<String> = Brl.Glob.GlobIter(pattern, flags, _path)
		Return TPathIterator.Create(inner, _path)
	End Method

	Rem
	bbdoc: Returns an iterator that yields strings matching the specified glob pattern.
	about: See #GlobIter for full glob pattern syntax and semantics.
	End Rem
	Method GlobIterStrings:TGlobIter(pattern:String, flags:EGlobOptions = EGlobOptions.None)
		Return Brl.Glob.GlobIter(pattern, flags, _path)
	End Method

	Rem
	bbdoc: Returns an array of #TPath objects matching the specified glob pattern.
	about: See #GlobIter for full glob pattern syntax and semantics.
	End Rem
	Method Glob:TPath[](pattern:String, flags:EGlobOptions = EGlobOptions.None)
		Local ss:String[] = Brl.Glob.Glob(pattern, flags, _path)
		Local out:TPath[] = New TPath[ss.Length]
		For Local i:Int = 0 Until ss.Length
			Local s:String = ss[i]
			If s.StartsWith("/") Or _RootPath(s) <> "" Then
				out[i] = New TPath(s)
			Else
				out[i] = Join(s)
			End If
		Next
		Return out
	End Method

	Rem
	bbdoc: Returns an array of strings matching the specified glob pattern.
	about: See #GlobIter for full glob pattern syntax and semantics.
	End Rem
	Method GlobStrings:String[](pattern:String, flags:EGlobOptions = EGlobOptions.None)
		Return Brl.Glob.Glob(pattern, flags, _path)
	End Method

	Rem
	bbdoc: Checks if the current path matches the specified glob pattern.
	about:
	The matching rules are identical to those used by #Glob, including support for
	wildcards (`*`, `?`), character classes (`[ ]`), escaping, and the `**` globstar
	operator when #EGlobOptions.GlobStar is enabled.

	Brace expansion using curly braces is supported.

	Brace expressions such as `{a,b}` are expanded into multiple patterns before
	matching is performed. For example, `"sub/{a,b}.txt"` is equivalent to matching
	against `"sub/a.txt"` or `"sub/b.txt"`.

	Only well-formed brace expressions containing at least one top-level comma are
	expanded. Escaped or malformed brace expressions are treated as literal text.

	Note that `**/pattern` matches only files below the starting directory.
	To include files in the starting directory, combine with pattern using brace expansion.
	For example, `{pattern,**/pattern}`.

	If @pattern does not contain any path separators (`/`), it is matched only against
	the final path segment of @path (the file or directory name).

	If @pattern contains path separators and is not rooted, it is matched against the
	trailing segments of @path. This allows relative patterns such as `"sub/*.txt"`
	to match absolute paths like `"/path/to/sub/file.txt"`.

	If @pattern is rooted, @path must also be rooted at the same location for a match
	to succeed.

	The @flags parameter controls matching behavior such as case folding, dotfile
	matching, globstar support, and escaping. See #EGlobOptions for details.

	This function performs no filesystem access and does not require the path to exist.
	End Rem
	Method MatchGlob:Int(pattern:String, flags:EGlobOptions = EGlobOptions.None)
		Return Brl.Glob.MatchGlob(pattern, _path, flags)
	End Method

	Rem
	bbdoc: Walks the file tree starting from the current path, invoking the provided #IPathWalker for each file/directory encountered.
	about: The @options parameter can be used to modify the behavior of the file walk, such as following symbolic links.
	The @maxDepth parameter limits how deep the traversal goes into the directory hierarchy. A value of 0 means no limit.
	End Rem
	Method Walk:Int(pathWalker:IPathWalker, options:EFileWalkOption = EFileWalkOption.None, maxDepth:Int = 0)
		Local fileWalker:TPathFileWalker = New TPathFileWalker(pathWalker)
		Return Brl.FileSystem.WalkFileTree(_path, fileWalker, options, maxDepth)
	End Method

	Rem
	bbdoc: Returns the current working directory as a #TPath object.
	End Rem
	Function Cwd:TPath()
		Return New TPath(CurrentDir())
	End Function

	Rem
	bbdoc: Returns the root path as a #TPath object.
	End Rem
	Function Root:TPath()
		Return New TPath("/")
	End Function
End Type


Type TPathIterator Implements IIterator<TPath>, ICloseable

	Field _inner:IIterator<String>
	Field _closeable:ICloseable
	Field _basePath:TPath
	Field _current:TPath
	Field _closed:Int

	Function Create:TPathIterator(inner:IIterator<String>, base:String)
		Local it:TPathIterator = New TPathIterator
		it._inner = inner
		it._closeable = ICloseable(inner)
		it._basePath = New TPath(base)
		Return it
	End Function

	Method Current:TPath()
		Return _current
	End Method

	Method MoveNext:Int()
		_current = Null
		If Not _inner Then
			Return False
		End If
		If Not _inner.MoveNext() Then
			Return False
		End If

		Local s:String = _inner.Current()

		' If filesystem iterator yields rooted paths, keep them rooted.
		' If it yields relative paths, resolve against base.
		If s.StartsWith("/") Or _RootPath(s) <> "" Then
			_current = New TPath(s)
		Else
			_current = _basePath.Join(s)
		End If
		Return True
	End Method

	Method Close()
		If _closed Then
			Return
		End If
		_closed = True

		If _closeable Then
			_closeable.Close()
		End If
		_inner = Null
		_closeable = Null
		_current = Null
	End Method

	Method Delete()
		Close()
	End Method

End Type

Rem
bbdoc: Interface for receiving callbacks during a file tree walk.
End Rem
Interface IPathWalker
	Rem
	bbdoc: Called once for each file/folder traversed.
	about: Return EFileWalkResult.OK to continue the tree traversal, or EFileWalkResult.Terminate to exit early.

	Note that the contents of @attributes is only valid for the duration of the call.
	End Rem
	Method WalkPath:EFileWalkResult(attributes:SPathAttributes Var)
End Interface

Type TPathFileWalker Implements IFileWalker

	Field _pathWalker:IPathWalker

	Method New(pathWalker:IPathWalker)
		Self._pathWalker = pathWalker
	End Method

	Method WalkFile:EFileWalkResult(fileAttributes:SFileAttributes Var)
		Local pathAttributes:SPathAttributes
		pathAttributes.fileAttributes = fileAttributes
		Return _pathWalker.WalkPath(pathAttributes)
	End Method

End Type

Rem
bbdoc: Structure representing file or directory attributes.
End Rem
Struct SPathAttributes
	Field fileAttributes:SFileAttributes

	Rem
	bbdoc: Return a #TPath object representing the path of the file/directory.
	End Rem
	Method GetPath:TPath()
		Return New TPath(fileAttributes.GetName())
	End Method

	Rem
	bbdoc: Returns the size of the file/directory in bytes.
	End Rem
	Method GetSize:ULong()
		Return fileAttributes.size
	End Method

	Rem
	bbdoc: Returns the creation time of the file/directory in seconds since the epoch (January 1, 1970).
	End Rem
	Method GetCreationTime:Int()
		Return fileAttributes.creationTime
	End Method

	Rem
	bbdoc: Returns the modified time of the file/directory in seconds since the epoch (January 1, 1970).
	End Rem
	Method GetModifiedTime:Int()
		Return fileAttributes.modifiedTime
	End Method

	Rem
	bbdoc: Returns the depth of the file/directory in the filesystem hierarchy.
	End Rem
	Method GetDepth:Short()
		Return fileAttributes.depth
	End Method

	Rem
	bbdoc: Returns the name of the file/directory.
	End Rem
	Method GetName:String()
		Return fileAttributes.GetName()
	End Method

	Rem
	bbdoc: Returns #True if the path represents a regular file.
	End Rem
	Method IsRegularFile:Int()
		Return fileAttributes.IsRegularFile()
	End Method

	Rem
	bbdoc: Returns #True if the path represents a directory.
	End Rem
	Method IsDirectory:Int()
		Return fileAttributes.IsDirectory()
	End Method

	Rem
	bbdoc: Returns #True if the path represents a symbolic link.
	End Rem
	Method IsSymbolicLink:Int()
		Return fileAttributes.IsSymbolicLink()
	End Method

End Struct

Rem
bbdoc: Iterator over the direct children of a directory #TPath.
about:
This iterator enumerates entries in a directory using #ReadDir and #NextFile
and yields a #TPath for each child.

The iterator holds an open directory handle while iterating. It should be closed
when no longer needed, either explicitly via #Close or automatically using a
#Using block.
End Rem
Type TPathDirIterator Implements IIterator<TPath>, ICloseable

	Field _base:TPath
	Field _dir:Byte Ptr
	Field _current:TPath
	Field _closed:Int
	Field _skipDots:Int

	Rem
	bbdoc: Creates a directory iterator for @baseDir.
	about: If @baseDir is not a directory or cannot be opened, the iterator yields no items.
	End Rem
	Function Create:TPathDirIterator(baseDir:TPath, skipDots:Int = True)
		Local it:TPathDirIterator = New TPathDirIterator
		it._base = baseDir
		it._skipDots = skipDots

		' Open lazily or eagerly. Eager is fine: ReadDir returns Null if not a dir.
		If baseDir And baseDir.IsDir() Then
			it._dir = ReadDir(baseDir.ToString())
		Else
			it._dir = Null
		End If

		Return it
	End Function

	Method Current:TPath()
		Return _current
	End Method

	Method MoveNext:Int()
		_current = Null
		If _closed Or Not _dir Then
			Return False
		End If

		While True
			Local name:String = NextFile(_dir)
			If Not name Then
				Close()
				Return False
			End If

			If _skipDots And (name = "." Or name = "..") Then
				Continue
			End If

			' Yield full child path
			_current = _base / name
			Return True
		Wend
	End Method

	Method Close()
		If _closed Then
			Return
		End If
		_closed = True

		' No allocations here; just close handle if needed.
		If _dir Then
			CloseDir(_dir)
			_dir = Null
		End If

		_current = Null
		_base = Null
	End Method

	Method Delete()
		Close()
	End Method

End Type

Private

Function _RootPath:String( path:String )
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

Function _IsRootPath:Int( path:String )
	Return path And _RootPath( path )=path
End Function

Function _IsRealPath:Int( path:String )
	Return _RootPath( path )<>""
End Function

Function _SplitSegments:String[](path:String)
	' path is expected to be FixPath-normalized and NOT include the root prefix (if rooted patterns)
	If path = "" Then
		Return New String[0]
	End If

	Local parts:String[] = New String[0]
	Local start:Int = 0
	Local i:Int = 0

	While i <= path.Length
		If i = path.Length Or path[i] = Asc("/") Then
			If i > start Then
				Local seg:String = path[start..i]
				' ignore empty segments
				parts = parts[..parts.Length + 1]
				parts[parts.Length - 1] = seg
			End If
			start = i + 1
		End If
		i :+ 1
	Wend

	Return parts
End Function
