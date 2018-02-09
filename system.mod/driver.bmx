
SuperStrict

Type TSystemDriver

	Method Poll() Abstract
	Method Wait() Abstract
	
	Method MoveMouse( x:Int,y:Int ) Abstract
	Method SetMouseVisible( visible:Int ) Abstract
	
	Method Notify( text$,serious:Int ) Abstract
	Method Confirm:Int( text$,serious:Int ) Abstract
	Method Proceed:Int( text$,serious:Int ) Abstract
	Method RequestFile$( text$,exts$,save:Int,file$ ) Abstract
	Method RequestDir$( text$,path$ ) Abstract

	Method OpenURL:Int( url$ ) Abstract	

	Method DesktopWidth:Int() Abstract
	Method DesktopHeight:Int() Abstract
	Method DesktopDepth:Int() Abstract
	Method DesktopHertz:Int() Abstract
	
End Type

Global Driver:TSystemDriver
