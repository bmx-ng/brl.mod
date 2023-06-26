SuperStrict

Import BRL.Event

Import BRL.System
Import "system.macos.m"

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()
Function bbSystemIntr()
Function bbSystemMoveMouse( x:Int,y:Int )
Function bbSystemSetMouseVisible( visible:Int )
Function bbSystemNotify( text:String,serious:Int )
Function bbSystemConfirm:Int( text:String,serious:Int )
Function bbSystemProceed:Int( text:String,serious:Int )
Function bbSystemRequestFile:String( text:String,exts:String,save:Int,file:String,dir:String )
Function bbSystemRequestDir:String( text:String,dir:String )
Function bbOpenURL:Int( url:String )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object,asyncRet:Int )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo:Int ),asyncInfo:Int,syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object )

Function bbSystemDesktopWidth:Int()
Function bbSystemDesktopHeight:Int()
Function bbSystemDesktopDepth:Int()
Function bbSystemDesktopHertz:Int()

End Extern

Private

Function Hook:Object( id:Int,data:Object,context:Object )
	bbSystemIntr
	Return data
End Function

AddHook EmitEventHook,Hook,Null,10000

Public

Type TMacOSSystemDriver Extends TSystemDriver

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
		Return bbSystemConfirm( Text,serious)
	End Method
	
	Method Proceed:Int( Text:String,serious:Int ) Override
		Return bbSystemProceed( Text,serious )
	End Method

	Method RequestFile:String( Text:String,exts:String,save:Int,path:String ) Override
		Local file:String,dir:String,filter:String
		
		path=path.Replace( "\","/" )
		Local i:Int=path.FindLast( "/" )
		If i<>-1
			dir=path[..i]
			file=path[i+1..]
		Else
			file=path
		EndIf
		
		exts=exts.Replace( ";","," )
		While exts
			Local p:Int=exts.Find(",")+1
			If p=0 p=exts.length
			Local q:Int=exts.Find(":")+1
			If q=0 Or q>p q=0
			filter:+exts[q..p]
			exts=exts[p..]
		Wend
		If filter.find("*")>-1 filter=""
		
		Return bbSystemRequestFile( Text,filter,save,file,dir )
	End Method

	Method RequestDir:String( Text:String,dir:String ) Override
		dir=dir.Replace( "\","/" )
		Return bbSystemRequestDir( Text,dir )
	End Method
	
	Method OpenURL:Int( url:String ) Override
'		Return system_( "open "" + url.Replace("~q","") + "~q" )
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
		Return "MacOSSystemDriver "
	End Method

End Type

