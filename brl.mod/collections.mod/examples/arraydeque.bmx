SuperStrict

Framework brl.standardio
Import brl.collections

Local stack:TArrayDeque<String> = New TArrayDeque<String>
stack.Push("Hello")
stack.Push("World")

Print stack.Pop()
Print stack.Pop()

Local intStack:TArrayDeque<Int> = New TArrayDeque<Int>
For Local i:Int = 0 Until 100
	intStack.Push(i)
Next

Print "Size = " + intStack.Size()

While Not intStack.IsEmpty()
	Print intStack.Pop()
Wend


'Local list:TLinkedList<String>