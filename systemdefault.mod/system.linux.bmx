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

	Method Poll() Override
		bbSystemPoll()
	End Method
	
	Method Wait() Override
		bbSystemWait()
	End Method

	Method Emit( osevent:Byte Ptr,source:Object )
		Throw "simon come here"
	End Method

	Method SetMouseVisible( visible:Int ) Override
		bbSetMouseVisible(visible)
	End Method

	Method MoveMouse( x:Int,y:Int ) Override
		bbMoveMouse x,y
	End Method

	Method Notify( Text$,serious:Int ) Override
		WriteStdout Text+"~r~n"
	End Method
	
	Method Confirm:Int( Text$,serious:Int ) Override
		WriteStdout Text+" (Yes/No)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		Return 0
	End Method
	
	Method Proceed:Int( Text$,serious:Int ) Override
		WriteStdout Text+" (Yes/No/Cancel)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		If t[..1]="n" Return 0
		Return -1
	End Method

	Method RequestFile$( Text$,exts$,save:Int,file$ ) Override
		WriteStdout "Enter a filename:"
		Return ReadStdin()
	End Method
	
	Method RequestDir$( Text$,path$ ) Override
		WriteStdout "Enter a directory name:"
		Return ReadStdin()
	End Method

	Method OpenURL:Int( url$ ) Override
		'environment variable is most likely set for desktop environments
		'working with the freedesktop.org project / x.org
		'So this works at least for KDE, Gnome and XFCE
		If getenv_("XDG_CURRENT_DESKTOP")
			system_("xdg-open ~q"+url+"~q")
		'Fallback for KDE/GNOME
		ElseIf getenv_("KDE_FULL_DESKTOP")
			system_("kfmclient exec ~q"+url+"~q")
		ElseIf getenv_("GNOME_DESKTOP_SESSION_ID")
			system_("gnome-open ~q"+url+"~q")
		EndIf
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
		Return "LinuxSystemDriver"
	End Method
	
End Type

InitSystemDriver(New TLinuxSystemDriver)

?
