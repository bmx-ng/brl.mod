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
Function bbSystemNotify( text$,serious:Int )
Function bbSystemConfirm:Int( text$,serious:Int )
Function bbSystemProceed:Int( text$,serious:Int )
Function bbSystemRequestFile$( text$,exts$,save:Int,file$,dir$ )
Function bbSystemRequestDir$( text$,dir$ )
Function bbOpenURL:Int( url$ )

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

	Method Poll()
		bbSystemPoll()
	End Method
	
	Method Wait()
		bbSystemWait()
	End Method
	
	Method MoveMouse( x:Int,y:Int )
		bbSystemMoveMouse x,y
	End Method
	
	Method SetMouseVisible( visible:Int )
		bbSystemSetMouseVisible visible
	End Method
	
	Method Notify( text$,serious:Int )
		bbSystemNotify text,serious
	End Method
	
	Method Confirm:Int( text$,serious:Int )
		Return bbSystemConfirm( text,serious)
	End Method
	
	Method Proceed:Int( text$,serious:Int )
		Return bbSystemProceed( text,serious )
	End Method

	Method RequestFile$( text$,exts$,save:Int,path$ )
		Local file$,dir$,filter$
		
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
		
		Return bbSystemRequestFile( text,filter,save,file,dir )
	End Method

	Method RequestDir$( text$,dir$ )
		dir=dir.Replace( "\","/" )
		Return bbSystemRequestDir( text,dir )
	End Method
	
	Method OpenURL:Int( url$ )
'		Return system_( "open "" + url.Replace("~q","") + "~q" )
		Return bbOpenURL( url )
	End Method

	Method DesktopWidth:Int()
		Return bbSystemDesktopWidth()
	End Method
	
	Method DesktopHeight:Int()
		Return bbSystemDesktopHeight()
	End Method
	
	Method DesktopDepth:Int()
		Return bbSystemDesktopDepth()
	End Method
	
	Method DesktopHertz:Int()
		Return bbSystemDesktopHertz()
	End Method

	Method Name:String()
		Return "MacOSSystemDriver "
	End Method

End Type

