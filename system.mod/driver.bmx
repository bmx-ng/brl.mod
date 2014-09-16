
Strict

Type TSystemDriver

	Method Poll() Abstract
	Method Wait() Abstract
	
	Method MoveMouse( x,y ) Abstract
	Method SetMouseVisible( visible ) Abstract
	
	Method Notify( text$,serious ) Abstract
	Method Confirm( text$,serious ) Abstract
	Method Proceed( text$,serious ) Abstract
	Method RequestFile$( text$,exts$,save,file$ ) Abstract
	Method RequestDir$( text$,path$ ) Abstract

	Method OpenURL( url$ ) Abstract	

	Method DesktopWidth:Int() Abstract
	Method DesktopHeight:Int() Abstract
	Method DesktopDepth:Int() Abstract
	Method DesktopHertz:Int() Abstract
	
End Type

Global Driver:TSystemDriver
