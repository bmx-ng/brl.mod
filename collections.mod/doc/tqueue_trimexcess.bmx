SuperStrict

Framework brl.collections
Import brl.standardio

Local queue:TQueue<String> = New TQueue<String>

Print "Count : " + queue.Count()
Print ""

queue.Enqueue("one")
queue.Enqueue("two")
queue.Enqueue("three")
queue.Enqueue("four")
queue.Enqueue("five")

queue.TrimExcess()

For Local num:String = EachIn queue
	Print num
Next

Print "~nCount : " + queue.Count()
