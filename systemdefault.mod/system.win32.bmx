
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

Function bbSystemNotify( text:String,serious:Int )
Function bbSystemConfirm:Int( text:String,serious:Int )
Function bbSystemProceed:Int( text:String,serious:Int )
Function bbSystemRequestFile:String( text:String,exts:String,defext:Int,save:Int,file:String,dir:String )
Function bbSystemRequestDir:String( text:String,dir:String )
Function bbOpenURL:Int( url:String )

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

	Method Notify( Text:String,serious:Int ) Override
		bbSystemNotify Text,serious
	End Method
	
	Method Confirm:Int( Text:String,serious:Int ) Override
		Return bbSystemConfirm( Text,serious )
	End Method
	
	Method Proceed:Int( Text:String,serious:Int ) Override
		Return bbSystemProceed( Text,serious )
	End Method

	Method RequestFile:String( Text:String,exts:String,save:Int,path:String ) Override
		Local file:String,dir:String
		
		path=path.Replace( "/","\" )
		
		Local i:Int=path.FindLast( "\" )
		If i<>-1
			dir=path[..i]
			file=path[i+1..]
		Else
			file=path
		EndIf

' calculate default index of extension in extension list from path name

		Local ext:String,defext:Int,p:Int,q:Int
		p=path.Find(".")
		If (p>-1)
			ext=","+path[p+1..].toLower()+","
			Local exs:String=exts.toLower()
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

	Method RequestDir:String( Text:String,dir:String ) Override
	
		dir=dir.Replace( "/","\" )
		
		Return bbSystemRequestDir( Text,dir )
	
	End Method
	
	Method OpenURL:Int( url:String ) Override
		Return bbOpenURL( url )
	End Method

	Method DesktopWidth:Int(display:Int) Override
		Return bbSystemDesktopWidth()
	End Method
	
	Method DesktopHeight:Int(display:Int) Override
		Return bbSystemDesktopHeight()
	End Method
	
	Method DesktopDepth:Int(display:Int) Override
		Return bbSystemDesktopDepth()
	End Method
	
	Method DesktopHertz:Int(display:Int) Override
		Return bbSystemDesktopHertz()
	End Method

	Method Name:String() Override
		Return "Win32SystemDriver"
	End Method
	
End Type
