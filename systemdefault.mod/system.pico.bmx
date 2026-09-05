SuperStrict

Import BRL.System

Extern "C"
	Function _PicoSystemWait() = "bmx_pico_system_wait"
End Extern

Type TPicoSystemDriver Extends TSystemDriver
	Method Name:String()
		Return "Pico"
	End Method

	Method Poll()
	End Method

	Method Wait()
		_PicoSystemWait()
	End Method

	Method MoveMouse(x:Int, y:Int)
	End Method

	Method SetMouseVisible(visible:Int)
	End Method

	Method Notify(text:String, serious:Int)
	End Method

	Method Confirm:Int(text:String, serious:Int)
		Return False
	End Method

	Method Proceed:Int(text:String, serious:Int)
		Return -1
	End Method

	Method RequestFile:String(text:String, extensions:String, save:Int, file:String)
		Return ""
	End Method

	Method RequestDir:String(text:String, path:String)
		Return ""
	End Method

	Method OpenURL:Int(url:String)
		Return False
	End Method

	Method DesktopWidth:Int(display:Int)
		Return 0
	End Method

	Method DesktopHeight:Int(display:Int)
		Return 0
	End Method

	Method DesktopDepth:Int(display:Int)
		Return 0
	End Method

	Method DesktopHertz:Int(display:Int)
		Return 0
	End Method
End Type

