SuperStrict

Framework brl.collections
Import brl.standardio

Local stack:TStack<String> = New TStack<String>
stack.Push("one")
stack.Push("two")
stack.Push("three")
stack.Push("four")
stack.Push("five")

Local iterator:IIterator<String> = stack.GetIterator()
While iterator.MoveNext()
	Print iterator.Current()
Wend
