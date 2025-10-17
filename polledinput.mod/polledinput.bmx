
SuperStrict

Rem
bbdoc: User input/Polled input
End Rem
Module BRL.PolledInput

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06"
ModuleInfo "History: SuperStrict mode."
ModuleInfo "History: 1.05"
ModuleInfo "History: Fixed mouse functions not supporting 5 buttons."
ModuleInfo "History: 1.04"
ModuleInfo "History: Support for 5 mouse buttons."
ModuleInfo "History: 1.03"
ModuleInfo "History: Improved Win32 KeyDown handling."
ModuleInfo "History: 1.02"
ModuleInfo "History: Added SetAutoPoll() function."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Fixed charQueue bug"

Import BRL.System

Private

Global enabled:Int
Global autoPoll:Int=True
Global inputSource:Object
Global suspended:Int,terminate:Int

Global keyStates:Int[256],keyHits:Int[256]
Global charGet:Int,charPut:Int,charQueue:Int[256]

Global mouseStates:Int[5],mouseHits:Int[5]
Global mouseLocation:Int[3],lastMouseLocation:Int[3]

Function Hook:Object( id:Int,data:Object,context:Object )

	Local ev:TEvent=TEvent(data)
	If Not ev Return data
	
	If inputSource And inputSource<>ev.source Return data
	
	Select ev.id
	Case EVENT_KEYDOWN, EVENT_KEYREPEAT
		If Not keyStates[ev.data]
			keyStates[ev.data]=1
			If ev.id <> EVENT_KEYREPEAT
				keyHits[ev.data]:+1
			End If
		EndIf
	Case EVENT_KEYUP
		keyStates[ev.data]=0
	Case EVENT_KEYCHAR
		If charPut-charGet<256
			charQueue[charPut & 255]=ev.data
			charPut:+1
		EndIf
	Case EVENT_MOUSEDOWN
		If Not mouseStates[ev.data-1]
			mouseStates[ev.data-1]=1
			mouseHits[ev.data-1]:+1
		EndIf
	Case EVENT_MOUSEUP
		mouseStates[ev.data-1]=0
	Case EVENT_MOUSEMOVE
		mouseLocation[0]=ev.x
		mouseLocation[1]=ev.y
	Case EVENT_MOUSEWHEEL
		mouseLocation[2]:+ev.data
	Case EVENT_APPSUSPEND
		FlushKeys
		FlushMouse
		suspended=True
	Case EVENT_APPRESUME
		FlushKeys(False)
		FlushMouse
		suspended=False
	Case EVENT_APPTERMINATE
		terminate=True
	End Select

	Return data

End Function

Public

Rem
Currently only called by Graphics/bglCreateContext.
Private for now, as it really needs a source:object parameter.
End Rem
Function EnablePolledInput( source:Object=Null )
	If enabled Return
	inputSource=source
	FlushKeys
	FlushMouse
	AddHook EmitEventHook,Hook,Null,0
	enabled=True
End Function

Rem
Currently only called by EndGraphics/bglDeleteContext
End Rem
Function DisablePolledInput()
	If Not enabled Return
	RemoveHook EmitEventHook,Hook
	FlushKeys
	FlushMouse
	inputSource=Null
	enabled=False
End Function

Rem
bbdoc: Get app suspended state
returns: True if application is currently suspended.
End Rem
Function AppSuspended:Int()
	If autoPoll PollSystem
	Return suspended
End Function

Rem
bbdoc: Return app terminate state
returns: True if user has requested to terminate application
End Rem
Function AppTerminate:Int()
	If autoPoll PollSystem
	Local n:Int=terminate
	terminate=False
	Return n
End Function

Rem
bbdoc: Check for key hit
returns: Number of times @key has been hit.
about:
The returned value represents the number of the times @key has been hit since the last
call to #KeyHit with the same @key.

See the #{key codes} module for a list of valid key codes.
End Rem
Function KeyHit:Int( key:Int )
	If autoPoll PollSystem
	Local n:Int=keyHits[key]
	keyHits[key]=0
	Return n
End Function

Rem
bbdoc: Check for key state
returns: #True if @key is currently down
about:
See the #{key codes} module for a list of valid keycodes.
End Rem
Function KeyDown:Int( key:Int )
	If autoPoll PollSystem
	Return keyStates[key]
End Function

Rem
bbdoc: Get next character
returns: The character code of the next character.
about:
As the user hits keys on the keyboard, BlitzMax records the character codes of these 
keystrokes into an internal 'character queue'.

#GetChar removes the next character code from this queue and returns it the application.

If the character queue is empty, 0 is returned.
End Rem
Function GetChar:Int()
	If autoPoll PollSystem
	If charGet=charPut Return 0
	Local n:Int=charQueue[charGet & 255]
	charGet:+1
	Return n
End Function

Rem
bbdoc: Flush key states and character queue.
about:
#FlushKeys resets the state of all keys to 'off', and resets the character queue
used by #GetChar.
End Rem
Function FlushKeys(resetStates:Int = True)
	PollSystem
	charGet=0
	charPut=0
	If resetStates Then
		For Local i:Int=0 Until keyStates.Length
			keyStates[i]=0
			keyHits[i]=0
		Next
	Else
		For Local i:Int=0 Until keyHits.Length
			keyHits[i]=0
		Next
	End If
End Function

Rem
bbdoc: Get mouse x location
returns: Mouse x axis location
about:
The returned value is relative to the left of the screen.
end rem
Function MouseX:Int()
	If autoPoll PollSystem
	Return mouseLocation[0]
End Function

Rem
bbdoc: Get mouse y location
returns: Mouse y axis location
about:
The returned value is relative to the top of the screen.
end rem
Function MouseY:Int()
	If autoPoll PollSystem
	Return mouseLocation[1]
End Function

Rem
bbdoc: Get mouse wheel
returns: Mouse wheel value
about:
The mouse wheel value increments when the mouse wheel is rolled 'away' from the user, and
decrements when the mouse wheel is rolled 'towards' the user.
end rem
Function MouseZ:Int()
	If autoPoll PollSystem
	Return mouseLocation[2]
End Function

Rem
bbdoc: Get mouse x speed
returns: Mouse x speed
End Rem
Function MouseXSpeed:Int()
	If autoPoll PollSystem
	Local d:Int=mouseLocation[0]-lastMouseLocation[0]
	lastMouseLocation[0]=mouseLocation[0]
	Return d
EndFunction

Rem
bbdoc: Get mouse y speed
returns: Mouse y speed
End Rem
Function MouseYSpeed:Int()
	If autoPoll PollSystem
	Local d:Int=mouseLocation[1]-lastMouseLocation[1]
	lastMouseLocation[1]=mouseLocation[1]
	Return d
EndFunction

Rem
bbdoc: Get mouse z speed
returns: Mouse z speed
End Rem
Function MouseZSpeed:Int()
	If autoPoll PollSystem
	Local d:Int=mouseLocation[2]-lastMouseLocation[2]
	lastMouseLocation[2]=mouseLocation[2]
	Return d
EndFunction

Rem
bbdoc: Flush mouse button states
about:
#FlushMouse resets the state of all mouse buttons to 'off'.
End Rem
Function FlushMouse()
	PollSystem
	For Local i:Int=0 Until mouseStates.Length
		mouseStates[i]=0
		mouseHits[i]=0
	Next
	mouseLocation[2]=0
End Function

Rem
bbdoc: Check for mouse button click
returns: Number of times @button has been clicked.
about:
The returned value represents the number of the times @button has been clicked since the
last call to #MouseHit with the same @button.

@button should be 1 for the left mouse button, 2 for the right mouse button or 3 for the
middle mouse button. Two further buttons, 4 and 5, are also available for mice that support them.
End Rem
Function MouseHit:Int( button:Int )
	If autoPoll PollSystem
	Local n:Int=mouseHits[button-1]
	mouseHits[button-1]=0
	Return n
End Function

Rem
bbdoc: Check for mouse button down state
returns: #True if @button is currently down
about:
@button should be 1 for the left mouse button, 2 for the right mouse button or 3 for the
middle mouse button. Two further buttons, 4 and 5, are also available for mice that support them.
End Rem
Function MouseDown:Int( button:Int )
	If autoPoll PollSystem
	Return mouseStates[button-1]
End Function

Rem
bbdoc: Wait for a key press
returns: The keycode of the pressed key
about:
#WaitKey suspends program execution until a key has been hit. The keycode of this
key is then returned to the application.

See the #{key codes} module for a list of valid keycodes.
End Rem
Function WaitKey:Int()
	FlushKeys
	Repeat
		WaitSystem
		For Local n:Int = 1 To keyStates.Length - 1
			If KeyHit(n) Return n
		Next
	Forever
End Function

Rem
bbdoc: Wait for a key press
returns: The character code of the pressed key
about:
#WaitChar suspends program execution until a character is available from #GetChar. This
character is then returned to the application.
End Rem
Function WaitChar:Int()
	FlushKeys
	Repeat
		WaitSystem
		Local n:Int=GetChar()
		If n Return n
	Forever
End Function

Rem
bbdoc: Wait for mouse button click
returns: The clicked button
about:
#WaitMouse suspends program execution until a mouse button is clicked.

#WaitMouse returns 1 if the left mouse button was clicked, 2 if the right mouse button was
clicked or 3 if the middle mouse button was clicked. Further buttons (>3) are also checked for mice that support them. 
End Rem
Function WaitMouse:Int()
	FlushMouse
	Repeat
		WaitSystem
		For Local n:Int=1 To mouseHits.Length
			If MouseHit(n) Return n
		Next
	Forever
End Function

Rem
bbdoc: Enables or disables autopolling.
End Rem
Function SetAutoPoll(value:Int)
	autoPoll = value
End Function
