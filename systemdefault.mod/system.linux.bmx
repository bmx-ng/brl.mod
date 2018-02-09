SuperStrict

?Not android

Import "-lX11"

Import BRL.System
Import "system.linux.c"

Import "-lXxf86vm"

Import pub.stdc

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()

Function bbSetMouseVisible(visible:Int)
Function bbMoveMouse(x:Int,y:Int)
Function bbSystemDisplay()
Function bbSystemEventHandler( callback(xevent:Byte Ptr) )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object,asyncRet:Int )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo:Int ),asyncInfo:Int,syncOp( syncInfo:Object,asyncRet:Int ),syncInfo:Object )

Function bbSystemAsyncFD:Int()
Function bbSystemFlushAsyncOps()

Function bbSystemDesktopWidth:Int()
Function bbSystemDesktopHeight:Int()
Function bbSystemDesktopDepth:Int()
Function bbSystemDesktopHertz:Int()

End Extern

Const XKeyPress:Int=2
Const XKeyRelease:Int=3

Function XKeyHandler(keyevent:Int,key:Int,mask:Int)
	WriteStdout "XKeyHandler "+keyevent+","+key+","+mask+"~n"
End Function

Type TLinuxSystemDriver Extends TSystemDriver

	Method New()
		bbSystemStartup
	End Method

	Method Poll()
		bbSystemPoll()
	End Method
	
	Method Wait()
		bbSystemWait()
	End Method

	Method Emit( osevent:Byte Ptr,source:Object )
		Throw "simon come here"
	End Method

	Method SetMouseVisible( visible:Int )
		bbSetMouseVisible(visible)
	End Method

	Method MoveMouse( x:Int,y:Int )
		bbMoveMouse x,y
	End Method

	Method Notify( text$,serious:Int )
		WriteStdout text+"~r~n"
	End Method
	
	Method Confirm:Int( text$,serious:Int )
		WriteStdout text+" (Yes/No)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		Return 0
	End Method
	
	Method Proceed:Int( text$,serious:Int )
		WriteStdout text+" (Yes/No/Cancel)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		If t[..1]="n" Return 0
		Return -1
	End Method

	Method RequestFile$( text$,exts$,save:Int,file$ )
		WriteStdout "Enter a filename:"
		Return ReadStdin()
	End Method
	
	Method RequestDir$( text$,path$ )
		WriteStdout "Enter a directory name:"
		Return ReadStdin()
	End Method

	Method OpenURL:Int( url$ )
		If getenv_("KDE_FULL_DESKTOP")
			system_ "kfmclient exec ~q"+url+"~q"
		ElseIf getenv_("GNOME_DESKTOP_SESSION_ID")
			system_ "gnome-open ~q"+url+"~q"
		EndIf
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

End Type

Driver=New TLinuxSystemDriver

?
