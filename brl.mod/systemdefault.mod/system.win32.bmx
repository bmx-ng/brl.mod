
SuperStrict

Import BRL.System
Import "system.win32.c"

Import "-lshell32"
Import "-lcomctl32"

Const WM_BBSYNCOP:Int=$7001	'wp=function, lp=arg

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()
Function bbSystemMoveMouse( x:Int,y:Int )
Function bbSystemSetMouseVisible( visible:Int )

Function bbSystemNotify( text$,serious:Int )
Function bbSystemConfirm:Int( text$,serious:Int )
Function bbSystemProceed:Int( text$,serious:Int )
Function bbSystemRequestFile$( text$,exts$,defext:Int,save:Int,file$,dir$ )
Function bbSystemRequestDir$( text$,dir$ )
Function bbOpenURL:Int( url$ )

Function bbSystemEmitOSEvent( hwnd:Byte Ptr,msg:Int,WParam:WParam,LParam:LParam,source:Object )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object,asyncRet:Int )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo:Int ),asyncInfo:Int,syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object )

Function bbSystemDesktopWidth:Int()
Function bbSystemDesktopHeight:Int()
Function bbSystemDesktopDepth:Int()
Function bbSystemDesktopHertz:Int()

End Extern

Type TWin32SystemDriver Extends TSystemDriver

	Method New()
		bbSystemStartup
	End Method

	Method Poll() Override
		bbSystemPoll()
	End Method
	
	Method Wait() Override
		bbSystemWait()
	End Method
	
	Method MoveMouse( x:Int,y:Int ) Override
		bbSystemMoveMouse x,y
	End Method
	
	Method SetMouseVisible( visible:Int ) Override
		bbSystemSetMouseVisible visible
	End Method

	Method Notify( Text$,serious:Int ) Override
		bbSystemNotify Text,serious
	End Method
	
	Method Confirm:Int( Text$,serious:Int ) Override
		Return bbSystemConfirm( Text,serious )
	End Method
	
	Method Proceed:Int( Text$,serious:Int ) Override
		Return bbSystemProceed( Text,serious )
	End Method

	Method RequestFile$( Text$,exts$,save:Int,path$ ) Override
		Local file$,dir$
		
		path=path.Replace( "/","\" )
		
		Local i:Int=path.FindLast( "\" )
		If i<>-1
			dir=path[..i]
			file=path[i+1..]
		Else
			file=path
		EndIf

' calculate default index of extension in extension list from path name

		Local ext$,defext:Int,p:Int,q:Int
		p=path.Find(".")
		If (p>-1)
			ext=","+path[p+1..].toLower()+","
			Local exs$=exts.toLower()
			exs=exs.Replace(":",":,")
			exs=exs.Replace(";",",;")
			p=exs.find(ext)
			If p>-1
				Local q:Int=-1
				defext=1
				While True
					q=exs.find(";",q+1)
					If q>p Exit
					If q=-1 defext=0;Exit
					defext:+1
				Wend
			EndIf
		EndIf
	
		If exts
			If exts.Find(":")=-1
				exts="Files~0*."+exts
			Else
				exts=exts.Replace(":","~0*.")
			EndIf
			exts=exts.Replace(";","~0")
			exts=exts.Replace(",",";*.")+"~0"
		EndIf
		
		Return bbSystemRequestFile( Text,exts,defext,save,file,dir )

	End Method

	Method RequestDir$( Text$,dir$ ) Override
	
		dir=dir.Replace( "/","\" )
		
		Return bbSystemRequestDir( Text,dir )
	
	End Method
	
	Method OpenURL:Int( url$ ) Override
		Return bbOpenURL( url )
	End Method

	Method DesktopWidth:Int() Override
		Return bbSystemDesktopWidth()
	End Method
	
	Method DesktopHeight:Int() Override
		Return bbSystemDesktopHeight()
	End Method
	
	Method DesktopDepth:Int() Override
		Return bbSystemDesktopDepth()
	End Method
	
	Method DesktopHertz:Int() Override
		Return bbSystemDesktopHertz()
	End Method

	Method Name:String() Override
		Return "Win32SystemDriver"
	End Method
	
End Type
