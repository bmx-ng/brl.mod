SuperStrict

Framework brl.collections
Import brl.standardio

Local stack:TStack<String> = New TStack<String>
stack.Push("one")
stack.Push("two")
stack.Push("three")
stack.Push("four")
stack.Push("five")

For Local num:String = EachIn stack
	Print num
Next

Print "~nstack.Contains(~qthree~q) : " + stack.Contains("three")
Print "stack.Contains(~qsix~q) : " + stack.Contains("six")
