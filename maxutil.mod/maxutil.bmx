
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
	If bmxpath Return bmxpath
	Local p$=getenv_("BMXPATH")
	If p
		bmxpath=p
		Return p
	EndIf

	'check various paths
	'1st: AppDir (symlinks resolved)
	'2nd: CurrentDir (directory of the "call")
	for local i:int = 0 to 1
		'1st try to get it from the real path
		if i = 0 then p = AppDir
		'2nd try to get it from the current dir (eg. when symlinked)
		if i = 1 then p = CurrentDir()

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
			'reached base directory?
			If q=p
				'in run 1 ...go to run 2
				if i = 0 then exit
				'already in run 2 - throw an error
				if i = 1 then Throw "Unable to locate BlitzMax path"
			endif
			p=q
		Forever
	Next
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
