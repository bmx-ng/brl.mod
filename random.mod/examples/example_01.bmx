SuperStrict

Framework BRL.Standardio
Import Brl.Random

Local random:TRandom = CreateRandom("Default")

For Local i:Int = 0 Until 5
	random.RndDouble()
Next

Print "Saving state..."

Local savedState:String = random.SaveState()
Print "State saved : " + savedState

Print "Random values :"

For Local i:Int = 0 Until 5
	Print random.RndDouble()
Next

Print "Restoring state..."

Local restoredRandom:TRandom
If RandomLoadState(savedState, restoredRandom) = ERandomLoadState.OK Then
	Print "State restored successfully."
Else
	Print "Failed to restore state."
	End
End If

Print "Random values after restoring state :"
For Local i:Int = 0 Until 5
	Print restoredRandom.RndDouble()
Next
