SuperStrict

Framework brl.collections
Import brl.standardio

Local queue:TQueue<String> = New TQueue<String>

Print "queue.Count() : " + queue.Count()
Print ""

queue.Enqueue("one")
queue.Enqueue("two")
queue.Enqueue("three")
queue.Enqueue("four")
queue.Enqueue("five")

For Local num:String = EachIn queue
	Print num
Next

Print "~nqueue.Contains(~qtwo~q) : " + queue.Contains("two")
Print "queue.Contains(~qsix~q) : " + queue.Contains("six")
