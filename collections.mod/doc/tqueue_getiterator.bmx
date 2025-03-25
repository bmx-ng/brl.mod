SuperStrict

Framework brl.collections
Import brl.standardio

Local queue:TQueue<String> = New TQueue<String>

Print ""

queue.Enqueue("one")
queue.Enqueue("two")
queue.Enqueue("three")
queue.Enqueue("four")
queue.Enqueue("five")

Local iterator:IIterator<String> = queue.GetIterator()
While iterator.MoveNext()
	Print iterator.Current()
Wend
