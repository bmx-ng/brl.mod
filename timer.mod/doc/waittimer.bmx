SuperStrict

Framework BRL.StandardIO
Import BRL.TimerDefault

Local timer:TTimer = CreateTimer( 10 )

Repeat
	Print "Ticks="+WaitTimer( timer )
Forever

	
