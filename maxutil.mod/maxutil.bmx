
Strict

Module BRL.MaxUtil

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.02"
ModuleInfo "History: Added support for many levels of nested module directories"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: 1.00 Release"

Import BRL.LinkedList
Import BRL.FileSystem

Import Pub.StdC

Function BlitzMaxPath:String()
	Global bmxpath:String
	If bmxpath And FileType(bmxpath)=FILETYPE_DIR Return bmxpath
	Local p:String=getenv_("BMXPATH")
	If p And FileType(p)=FILETYPE_DIR
		bmxpath=p
		Return p
	EndIf
	p=AppDir
	Repeat
		Local t:String=p+"/bin/bmk"
		?Win32
		t:+".exe"
		?
		If FileType(t)=FILETYPE_FILE
			putenv_ "BMXPATH="+p
			bmxpath=p
			Return p
		EndIf
		Local q:String=ExtractDir( p )
		If q=p Throw "Unable to locate BlitzMax path"
		p=q
	Forever
End Function

Function ModulePath:String( modid:String )
	Local p:String=BlitzMaxPath()+"/mod"
	If modid p:+"/"+modid.Replace(".",".mod/")+".mod"
	Return p
End Function

Function ModuleIdent:String( modid:String )
	Return modid[modid.FindLast(".")+1..]
End Function

Function ModuleSource:String( modid:String )
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+".bmx"
End Function

Function ModuleArchive:String( modid:String,mung:String="" )
	If mung And mung[0]<>Asc(".") mung="."+mung
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+mung+".a"
End Function

Function ModuleInterface:String( modid:String,mung:String="" )
	If mung And mung[0]<>Asc(".") mung="."+mung
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+mung+".i"
End Function

Const MAX_MODULE_DIRECTORY_DEPTH:Int = 256

Rem
bbdoc: Describes one physical .mod directory and its path-derived logical name.
End Rem
Type TModuleDirectory
	Field name:String
	Field path:String
	Field identifier:String
	Field depth:Int

	Method SourcePath:String()
		Return path + "/" + identifier + ".bmx"
	End Method
End Type

Rem
bbdoc: Returns the canonical module path beneath an explicit SDK module root.
End Rem
Function ModulePathAtRoot:String( moduleRoot:String,modid:String )
	Local root:String=moduleRoot.Replace("\", "/")
	While root.EndsWith("/")
		root=root[..root.length-1]
	Wend
	If modid Return root+"/"+modid.Replace(".",".mod/")+".mod"
	Return root
End Function

Rem
bbdoc: Derives a logical module name from a primary module source or interface path.
End Rem
Function ModuleNameForPath:String( path:String )
	Local parts:String[]=path.Replace("\", "/").Split("/")
	If parts.length<3 Return ""
	Local fileName:String=parts[parts.length-1].ToLower()
	Local directoryIndex:Int=parts.length-2
	If parts[directoryIndex].ToLower()=".bmx" directoryIndex:-1
	If directoryIndex<1 Return ""

	Local leafDirectory:String=parts[directoryIndex]
	If Not leafDirectory.ToLower().EndsWith(".mod") Return ""
	Local leaf:String=leafDirectory[..leafDirectory.length-4]
	If Not IsModuleDirectoryIdentifier(leaf) Return ""
	Local lowerLeaf:String=leaf.ToLower()
	If fileName<>lowerLeaf+".bmx" And Not (fileName.StartsWith(lowerLeaf+".") And fileName.EndsWith(".i")) Return ""

	Local first:Int=directoryIndex
	While first>0 And parts[first-1].ToLower().EndsWith(".mod")
		first:-1
	Wend
	' A module requires at least a namespace and a concrete leaf directory.
	If directoryIndex-first+1<2 Return ""
	Local result:String
	For Local index:Int=first To directoryIndex
		Local component:String=parts[index][..parts[index].length-4]
		If Not IsModuleDirectoryIdentifier(component) Return ""
		If result.length result:+"."
		result:+component
	Next
	Return result.ToLower()
End Function

Function IsModuleDirectoryIdentifier:Int( identifier:String )
	If Not identifier.length Return False
	Local char:Int=identifier[0]
	If char<>95 And (char<65 Or char>90) And (char<97 Or char>122) And char<=127 Return False
	For Local index:Int=1 Until identifier.length
		char=identifier[index]
		If char=95 Or (char>=48 And char<=57) Or (char>=65 And char<=90) Or (char>=97 And char<=122) Or char>127 Continue
		Return False
	Next
	Return True
End Function

Rem
bbdoc: Enumerates every recursively nested .mod directory beneath a module root.
about: Each .mod path segment contributes one component to name. Namespace-only
containers are included; callers decide whether a source or interface makes an
entry concrete. Traversal is bounded only to defend against malformed cyclic
layouts.
End Rem
Function EnumModuleDirectories:TList( moduleRoot:String="",modid:String="",directories:TList=Null,depth:Int=0 )
	If Not directories directories=New TList
	If Not moduleRoot moduleRoot=BlitzMaxPath()+"/mod"
	Local dir:String=ModulePathAtRoot(moduleRoot,modid)
	Return EnumModuleDirectoriesFrom(dir,modid,directories,depth)
End Function

Private
Function EnumModuleDirectoriesFrom:TList( dir:String,modid:String,directories:TList,depth:Int )
	If depth>=MAX_MODULE_DIRECTORY_DEPTH Throw "Module directory nesting exceeds defensive limit of "+MAX_MODULE_DIRECTORY_DEPTH+": "+dir
	If FileType(dir)<>FILETYPE_DIR Return directories
	Local files:String[]=LoadDir(dir)
	files.Sort()

	For Local file:String=EachIn files
		If file.length<5 Or Not file.ToLower().EndsWith(".mod") Continue
		Local path:String=dir+"/"+file
		If FileType(path)<>FILETYPE_DIR Continue

		Local identifier:String=file[..file.length-4]
		If Not IsModuleDirectoryIdentifier(identifier) Then
			Throw "Invalid module directory '"+path+"': '.mod' basename '"+identifier+"' must be a single BlitzMax identifier"
		EndIf
		Local name:String=identifier
		If modid name=modid+"."+identifier
		Local item:TModuleDirectory=New TModuleDirectory
		item.name=name
		item.path=path.Replace("\", "/")
		item.identifier=identifier
		item.depth=depth+1
		directories.AddLast item
		EnumModuleDirectoriesFrom path,name,directories,depth+1
	Next

	Return directories
End Function
Public

?bmxng2
Function EnumModules:TList( modid:String="",mods:TList=Null )
	If Not mods mods=New TList
	Local paths:TList=New TList
	EnumModuleDirectories BlitzMaxPath()+"/mod",modid,paths
	For Local item:TModuleDirectory=EachIn paths
		If FileType(item.SourcePath())<>FILETYPE_FILE Continue
		For Local existing:String=EachIn mods
			If existing.ToLower()=item.name.ToLower() Then
				Throw "Ambiguous module '"+item.name+"' maps to multiple physical locations beneath '"+BlitzMaxPath()+"/mod'"
			EndIf
		Next
		mods.AddLast item.name
	Next
	Return mods
End Function
?Not bmxng2
Function EnumModules:TList( modid:String="",mods:TList=Null )
	If Not mods mods=New TList

	Local dir:String=ModulePath( modid )
	Local files:String[]=LoadDir( dir )

	For Local file:String=EachIn files
		Local path:String=dir+"/"+file
		If file[file.length-4..]<>".mod" Or FileType(path)<>FILETYPE_DIR Continue

		Local t:String=file[..file.length-4]
		If modid t=modid+"."+t

		Local i=t.Find( "." )
		If i<>-1 And t.Find( ".",i+1)=-1 mods.AddLast t

		mods=EnumModules( t,mods )
	Next

	Return mods
End Function
?

Private
?win32
Global _minGWPath:String
?
Public

Function MinGWPath:String()
?Not win32
	Return ""
?win32
	If Not _minGWPath Then
		Local path:String
		' look for local MinGW32 dir
		' some distros (eg. MinGW-w64) only support a single target architecture - x86 or x64
		' to compile for both, requires two separate MinGW installations. Check against
		' CPU target based dir first, before working through the fallbacks.
		
		Local cpuMinGW:String
		
?win32x86
		cpuMinGW  ="/MinGW32x86"
?win32x64
		cpuMinGW = "/MinGW32x64"
?win32arm
		cpuMinGW = "/llvm-mingw"
?win32arm64
		cpuMinGW = "/llvm-mingw"
?win32
		If cpuMinGW Then
			path = BlitzMaxPath() + cpuMinGW + "/bin"
			If FileType(path) = FILETYPE_DIR Then
				' bin dir exists, go with that
				_minGWPath = BlitzMaxPath() + cpuMinGW 
				Return _minGWPath
			End If
		End If
		
		path = BlitzMaxPath() + "/MinGW32/bin"
		If FileType(path) = FILETYPE_DIR Then
			' bin dir exists, go with that
			_minGWPath = BlitzMaxPath() + "/MinGW32"
			Return _minGWPath
		End If

		path = BlitzMaxPath() + "/llvm-mingw/bin"
		If FileType(path) = FILETYPE_DIR Then
			' bin dir exists, go with that
			_minGWPath = BlitzMaxPath() + "/llvm-mingw"
			Return _minGWPath
		End If

		' try MINGW environment variable
		path = getenv_("MINGW")
		If path And FileType(path) = FILETYPE_DIR Then
			' check for bin dir
			If FileType(path + "/bin") = FILETYPE_DIR Then
				' go with that
				_minGWPath = path
				Return _minGWPath
			End If
		End If

		' none of the above? fallback to BlitzMax dir (for bin and lib)
		_minGWPath = BlitzMaxPath()
	End If
	
	Return _minGWPath
?
End Function
