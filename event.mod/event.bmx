
SuperStrict

Rem
bbdoc: Events/Events
End Rem
Module BRL.Event

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly, Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07"
ModuleInfo "History: Removed event pool."
ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05"
ModuleInfo "History: Added EVENT_MULTIGESTURE."
ModuleInfo "History: 1.04"
ModuleInfo "History: Added event pool."
ModuleInfo "History: Added EVENT_TOUCHDOWN, EVENT_TOUCHUP and EVENT_TOUCHMOVE."
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added missing EVENT_HOTKEY ToString case"
ModuleInfo "History: Added process events"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added EVENT_GADGETLOSTFOCUS"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Added EVENT_KEYREPEAT"

Import BRL.Hook

Rem
bbdoc: Hook id for emitted events
about:
The #EmitEventHook global variable contains a hook id for use with #AddHook.

Each time #EmitEvent is called, the event is passed to all #EmitEventHook 
hook functions by means of the hook function @data parameter.
End Rem
Global EmitEventHook:Int=AllocHookId()

Rem
bbdoc: Event object type
EndRem
Type TEvent

	Rem
	bbdoc: Event identifier
	End Rem
	Field id:Int
	
	Rem
	bbdoc: Event source object
	End Rem
	Field source:Object
	
	Rem
	bbdoc: Event specific data
	End Rem
	Field data:Int
	
	Rem
	bbdoc: Event specific modifiers
	End Rem
	Field mods:Int
	
	Rem
	bbdoc: Event specific position data
	End Rem
	Field x:Int
	
	Rem
	bbdoc: Event specific position data
	End Rem
	Field y:Int
	
	Rem
	bbdoc: Event specific extra information
	End Rem
	Field extra:Object
	
	Rem
	bbdoc: Emit this event
	about:
	This method runs all #EmitEventHook hook function, passing @Self as
	the hook data.
	End Rem
	Method Emit()
		RunHooks EmitEventHook,Self
	End Method

	Rem
	bbdoc: Convert event to a string
	about:
	This method is mainly useful for debugging purposes.
	End Rem	
	Method ToString$() Override
		Local t$=DescriptionForId( id )
		If Not t
			If id & EVENT_USEREVENTMASK
				t="UserEvent"+(id-EVENT_USEREVENTMASK)
			Else
				t="Unknown Event, id="+id
			EndIf
		EndIf
		Return t+": data="+data+", mods="+mods+", x="+x+", y="+y+", extra=~q"+String(extra)+"~q"
	End Method
	
	Rem
	bbdoc: Create an event object
	returns: A new event object
	End Rem
	Function Create:TEvent( id:Int,source:Object=Null,data:Int=0,mods:Int=0,x:Int=0,y:Int=0,extra:Object=Null)
		Local t:TEvent = New TEvent
		t.id=id
		t.source=source
		t.data=data
		t.mods=mods
		t.x=x
		t.y=y
		t.extra=extra
		Return t
	End Function
	
	Rem
	bbdoc: Allocate a user event id
	returns: A new user event id
	End Rem
	Function AllocUserId:Int()
		Global _id:Int=EVENT_USEREVENTMASK
		_id:+1
		Return _id
	End Function
	
	Function RegisterId( id:Int,description$ )
		_regids:+String(id)+"{"+description+"}"
	End Function
	
	Function DescriptionForId$( id:Int )
		Local t$="}"+String(id)+"{"
		Local i:Int=_regids.Find( t )
		If i=-1 Return Null
		i:+t.length
		Local i2:Int=_regids.Find( "}",i )
		If i2=-1 Return Null
		Return _regids[i..i2]
	End Function

	Global _regids$="}"
	
End Type

Const EVENT_APPMASK:Int=$100
Const EVENT_APPSUSPEND:Int=$101
Const EVENT_APPRESUME:Int=$102
Const EVENT_APPTERMINATE:Int=$103
Const EVENT_APPOPENFILE:Int=$104
Const EVENT_APPIDLE:Int=$105		'Reserved by Mark!
Const EVENT_KEYMASK:Int=$200
Const EVENT_KEYDOWN:Int=$201
Const EVENT_KEYUP:Int=$202
Const EVENT_KEYCHAR:Int=$203
Const EVENT_KEYREPEAT:Int=$204
Const EVENT_MOUSEMASK:Int=$400
Const EVENT_MOUSEDOWN:Int=$401
Const EVENT_MOUSEUP:Int=$402
Const EVENT_MOUSEMOVE:Int=$403
Const EVENT_MOUSEWHEEL:Int=$404
Const EVENT_MOUSEENTER:Int=$405
Const EVENT_MOUSELEAVE:Int=$406
Const EVENT_TIMERMASK:Int=$800
Const EVENT_TIMERTICK:Int=$801
Const EVENT_HOTKEYMASK:Int=$1000
Const EVENT_HOTKEYHIT:Int=$1001
Const EVENT_GADGETMASK:Int=$2000
Const EVENT_GADGETACTION:Int=$2001
Const EVENT_GADGETPAINT:Int=$2002
Const EVENT_GADGETSELECT:Int=$2003
Const EVENT_GADGETMENU:Int=$2004
Const EVENT_GADGETOPEN:Int=$2005
Const EVENT_GADGETCLOSE:Int=$2006
Const EVENT_GADGETDONE:Int=$2007
Const EVENT_GADGETLOSTFOCUS:Int=$2008
Const EVENT_GADGETSHAPE:Int=$2009	'reserved by Mark!
Const EVENT_WINDOWMASK:Int=$4000
Const EVENT_WINDOWMOVE:Int=$4001
Const EVENT_WINDOWSIZE:Int=$4002
Const EVENT_WINDOWCLOSE:Int=$4003
Const EVENT_WINDOWACTIVATE:Int=$4004
Const EVENT_WINDOWACCEPT:Int=$4005
Const EVENT_WINDOWMINIMIZE:Int=$4006
Const EVENT_WINDOWMAXIMIZE:Int=$4007
Const EVENT_WINDOWRESTORE:Int=$4008
Const EVENT_MENUMASK:Int=$8000
Const EVENT_MENUACTION:Int=$8001
Const EVENT_STREAMMASK:Int=$10000
Const EVENT_STREAMEOF:Int=$10001
Const EVENT_STREAMAVAIL:Int=$10002
Const EVENT_PROCESSMASK:Int=$20000
Const EVENT_PROCESSEXIT:Int=$20001
Const EVENT_TOUCHMASK:Int=$40000
Const EVENT_TOUCHDOWN:Int=$40001
Const EVENT_TOUCHUP:Int=$40002
Const EVENT_TOUCHMOVE:Int=$40003
Const EVENT_MULTIGESTURE:Int=$80000
Const EVENT_USEREVENTMASK:Int=$80000000

TEvent.RegisterId EVENT_APPSUSPEND,"AppSuspend"
TEvent.RegisterId EVENT_APPRESUME,"AppResume"
TEvent.RegisterId EVENT_APPTERMINATE,"AppTerminate"
TEvent.RegisterId EVENT_APPOPENFILE,"AppOpenFile"
TEvent.RegisterId EVENT_APPIDLE,"AppIdle"
TEvent.RegisterId EVENT_KEYDOWN,"KeyDown"
TEvent.RegisterId EVENT_KEYUP,"KeyUp"
TEvent.RegisterId EVENT_KEYCHAR,"KeyChar"
TEvent.RegisterId EVENT_KEYREPEAT,"KeyRepeat"
TEvent.RegisterId EVENT_MOUSEDOWN,"MouseDown"
TEvent.RegisterId EVENT_MOUSEUP,"MouseUp"
TEvent.RegisterId EVENT_MOUSEMOVE,"MouseMove"
TEvent.RegisterId EVENT_MOUSEWHEEL,"MouseWheel"
TEvent.RegisterId EVENT_MOUSEENTER,"MouseEnter"
TEvent.RegisterId EVENT_MOUSELEAVE,"MouseLeave"
TEvent.RegisterId EVENT_TIMERTICK,"TimerTick"
TEvent.RegisterId EVENT_HOTKEYHIT,"HotkeyHit"
TEvent.RegisterId EVENT_GADGETACTION,"GadgetAction"
TEvent.RegisterId EVENT_GADGETPAINT,"GadgetPaint"
TEvent.RegisterId EVENT_GADGETSELECT,"GadgetSelect"
TEvent.RegisterId EVENT_GADGETMENU,"GadgetMenu"
TEvent.RegisterId EVENT_GADGETOPEN,"GadgetOpen"
TEvent.RegisterId EVENT_GADGETCLOSE,"GadgetClose"
TEvent.RegisterId EVENT_GADGETDONE,"GadgetDone"
TEvent.RegisterId EVENT_GADGETLOSTFOCUS,"GadgetLostFocus"
TEvent.RegisterId EVENT_GADGETSHAPE,"GadgetShape"
TEvent.RegisterId EVENT_WINDOWMOVE,"WindowMove"
TEvent.RegisterId EVENT_WINDOWSIZE,"WindowSize"
TEvent.RegisterId EVENT_WINDOWCLOSE,"WindowClose"
TEvent.RegisterId EVENT_WINDOWACTIVATE,"WindowActivate"
TEvent.RegisterId EVENT_WINDOWACCEPT,"WindowAccept"
TEvent.RegisterId EVENT_WINDOWMINIMIZE,"WindowMinimize"
TEvent.RegisterId EVENT_WINDOWMAXIMIZE,"WindowMaximize"
TEvent.RegisterId EVENT_WINDOWRESTORE,"WindowRestore"
TEvent.RegisterId EVENT_MENUACTION,"MenuAction"
TEvent.RegisterId EVENT_STREAMEOF,"StreamEof"
TEvent.RegisterId EVENT_STREAMAVAIL,"StreamAvail"
TEvent.RegisterId EVENT_PROCESSEXIT,"ProcessExit"
TEvent.RegisterId EVENT_TOUCHDOWN,"TouchDown"
TEvent.RegisterId EVENT_TOUCHUP,"TouchUp"
TEvent.RegisterId EVENT_TOUCHMOVE,"TouchMove"
TEvent.RegisterId EVENT_MULTIGESTURE,"MultiGesture"

Rem
bbdoc: Emit an event
about:
Runs all #EmitEventHook hooks, passing @event as the hook data.
End Rem
Function EmitEvent( event:TEvent )
	event.Emit
End Function

Rem
bbdoc: Create an event object
returns: A new event object
End Rem
Function CreateEvent:TEvent( id:Int,source:Object=Null,data:Int=0,mods:Int=0,x:Int=0,y:Int=0,extra:Object=Null)
	Return TEvent.Create( id,source,data,mods,x,y,extra)
End Function

Rem
bbdoc: Allocate a user event id
returns: A new user event id
End Rem
Function AllocUserEventId:Int( description$="" )
	Local id:Int=TEvent.AllocUserId()
	If description TEvent.RegisterId id,description
	Return id
End Function
