SuperStrict

Framework BRL.StandardIO
Import BRL.PolledInput
?wheel_test_sdl3
Import SDL3.SDL3System
?Not wheel_test_sdl3
Import BRL.SystemDefault
?

' Synthetic events exercise the same input hook used by graphics drivers.
EnablePolledInput()
SetAutoPoll(False)

For Local amount:Int = -8 To 8 Step 16
	EmitEvent(CreateEvent(EVENT_MOUSEWHEEL, Null, amount))
	Check(MouseZSpeed(), amount, "Wheel movement")
	Check(MouseZSpeed(), 0, "Consumed movement")
	EmitEvent(CreateEvent(EVENT_APPSUSPEND))
	Check(MouseZSpeed(), 0, "Focus loss")
	EmitEvent(CreateEvent(EVENT_APPRESUME))
	Check(MouseZSpeed(), 0, "Focus return")

	EmitEvent(CreateEvent(EVENT_MOUSEWHEEL, Null, amount))
	Check(MouseZSpeed(), amount, "Movement after focus return")
	EmitEvent(CreateEvent(EVENT_APPSUSPEND))
	EmitEvent(CreateEvent(EVENT_APPRESUME))
	Check(MouseZSpeed(), 0, "Focus cycle between readings")

	EmitEvent(CreateEvent(EVENT_MOUSEWHEEL, Null, amount))
	Check(MouseZSpeed(), amount, "Movement before flush")
	FlushMouse()
	Check(MouseZ(), 0, "Flushed wheel position")
	Check(MouseZSpeed(), 0, "Flushed wheel delta")

	EmitEvent(CreateEvent(EVENT_MOUSEWHEEL, Null, amount))
	Check(MouseZSpeed(), amount, "Movement before disable")
	DisablePolledInput()
	EnablePolledInput()
	Check(MouseZSpeed(), 0, "Re-enabled input")
Next

DisablePolledInput()
Print "Mouse wheel focus checks passed."

Function Check(actual:Int, expected:Int, description:String)
	If actual <> expected Then Throw description + ": expected " + expected + ", got " + actual
End Function
