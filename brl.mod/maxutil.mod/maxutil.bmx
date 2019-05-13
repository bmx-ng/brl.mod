
Strict

Module BRL.MaxUtil

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.01 Release"
ModuleInfo "History: 1.00 Release"

Import BRL.LinkedList
Import BRL.FileSystem

Import Pub.StdC

Function BlitzMaxPath$()
	Global bmxpath$
	If bmxpath And FileType(bmxpath)=FILETYPE_DIR Return bmxpath
	Local p$=getenv_("BMXPATH")
	If p And FileType(p)=FILETYPE_DIR
		bmxpath=p
		Return p
	EndIf
	p=AppDir
	Repeat
		Local t$=p+"/bin/bmk"
		?Win32
		t:+".exe"
		?
		If FileType(t)=FILETYPE_FILE
			putenv_ "BMXPATH="+p
			bmxpath=p
			Return p
		EndIf
		Local q$=ExtractDir( p )
		If q=p Throw "Unable to locate BlitzMax path"
		p=q
	Forever
End Function

Function ModulePath$( modid$ )
	Local p$=BlitzMaxPath()+"/mod"
	If modid p:+"/"+modid.Replace(".",".mod/")+".mod"
	Return p
End Function

Function ModuleIdent$( modid$ )
	Return modid[modid.FindLast(".")+1..]
End Function

Function ModuleSource$( modid$ )
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+".bmx"
End Function

Function ModuleArchive$( modid$,mung$="" )
	If mung And mung[0]<>Asc(".") mung="."+mung
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+mung+".a"
End Function

Function ModuleInterface$( modid$,mung$="" )
	If mung And mung[0]<>Asc(".") mung="."+mung
	Return ModulePath(modid)+"/"+ModuleIdent(modid)+mung+".i"
End Function

Function EnumModules:TList( modid$="",mods:TList=Null )
	If Not mods mods=New TList
	
	Local dir$=ModulePath( modid )
	Local files$[]=LoadDir( dir )
	
	For Local file$=EachIn files
		Local path$=dir+"/"+file
		If file[file.length-4..]<>".mod" Or FileType(path)<>FILETYPE_DIR Continue

		Local t$=file[..file.length-4]
		If modid t=modid+"."+t

		Local i=t.Find( "." )
		If i<>-1 And t.Find( ".",i+1)=-1 mods.AddLast t

		mods=EnumModules( t,mods )
	Next

	Return mods
End Function

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
?win32
		path = BlitzMaxPath() + cpuMinGW + "/bin"
		If FileType(path) = FILETYPE_DIR Then
			' bin dir exists, go with that
			_minGWPath = BlitzMaxPath() + cpuMinGW 
			Return _minGWPath
		End If
		
		path = BlitzMaxPath() + "/MinGW32/bin"
		If FileType(path) = FILETYPE_DIR Then
			' bin dir exists, go with that
			_minGWPath = BlitzMaxPath() + "/MinGW32"
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
