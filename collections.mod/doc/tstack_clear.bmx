SuperStrict

Framework brl.collections
Import brl.standardio

Local stack:TStack<String> = New TStack<String>
stack.Push("one")
stack.Push("two")
stack.Push("three")
stack.Push("four")
stack.Push("five")

Print "stack.Count() : " + stack.Count()

For Local num:String = EachIn stack
	Print num
Next

Print "~nstack.Clear()"
stack.Clear()

Print "stack.Count() : " + stack.Count()
