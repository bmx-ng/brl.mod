
SuperStrict

Type TSystemDriver

	Method Name:String() Abstract
	
	Method Poll() Abstract
	Method Wait() Abstract
	
	Method MoveMouse( x:Int,y:Int ) Abstract
	Method SetMouseVisible( visible:Int ) Abstract
	
	Method Notify( text:String,serious:Int ) Abstract
	Method Confirm:Int( text:String,serious:Int ) Abstract
	Method Proceed:Int( text:String,serious:Int ) Abstract
	Method RequestFile:String( text:String,exts:String,save:Int,file:String ) Abstract
	Method RequestDir:String( text:String,path:String ) Abstract

	Method OpenURL:Int( url:String ) Abstract	

	Method DesktopWidth:Int(display:Int) Abstract
	Method DesktopHeight:Int(display:Int) Abstract
	Method DesktopDepth:Int(display:Int) Abstract
	Method DesktopHertz:Int(display:Int) Abstract

	Method ToString:String() Override
		Return Name()
	End Method

End Type

Interface IWrappedSystemDriver
	Method SetDriver(driver:TSystemDriver)
	Method GetDriver:TSystemDriver()
End Interface

Private
Global _Driver:TSystemDriver
Public

Rem
bbdoc: Initialises the BlitzMax system driver.
about: There can only be one system driver initialised. A second call to this function will result in an exception.
End Rem
Function InitSystemDriver(driver:TSystemDriver)
	If _Driver Then
		If IWrappedSystemDriver(driver) Then
			IWrappedSystemDriver(driver).SetDriver(_Driver)
		Else
			Throw "Cannot initialise " + driver.ToString() + ". System driver already configured as " + _Driver.ToString()
		End If
	End If
	_Driver = driver
End Function

Rem
bbdoc: Returns the BlitzMax system driver, or throws an exception if #InitSystemDriver() hasn't been called with one.
End Rem
Function SystemDriver:TSystemDriver()
	If Not _Driver Then
		Throw "No System Driver installed. Maybe Import BRL.SystemDefault ?"
	End If
	Return _Driver
End Function


