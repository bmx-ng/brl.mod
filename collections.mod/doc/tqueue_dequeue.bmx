SuperStrict

Framework brl.collections
Import brl.standardio

Local queue:TQueue<String> = New TQueue<String>

queue.Enqueue("one")
queue.Enqueue("two")
queue.Enqueue("three")
queue.Enqueue("four")
queue.Enqueue("five")

For Local num:String = EachIn queue
	Print num
Next

Print "~nCount : " + queue.Count()


Print "~nDequeuing : " + queue.Dequeue()
Print "Dequeuing  : "  + queue.Dequeue()

Print "~nCount : " + queue.Count()
