'
' Demonstrates how to use a blocking queue to synchronize threads.
'
SuperStrict

Framework Brl.StandardIO
Import Brl.Threads
Import Brl.Collections


Function Producer:Object(data:Object)
	Local queue:TBlockingQueue<Int> = TBlockingQueue<Int>(data)

    For Local i:Int = 1 To 10
        Print "Producing " + i
        queue.Enqueue(i)
        Delay 500 ' Simulate work
    Next
End Function

Function Consumer:Object(data:Object)
	Local queue:TBlockingQueue<Int> = TBlockingQueue<Int>(data)

    For Local i:Int = 1 To 10
        Local item:Int = queue.Dequeue()
        Print "Consuming " + item
        Delay 1000 ' Simulate work
    Next
End Function

Local queue:TBlockingQueue<Int> = New TBlockingQueue<Int>(5)
Local producerThread:TThread = CreateThread(Producer, queue)
Local consumerThread:TThread = CreateThread(Consumer, queue)

WaitThread(producerThread)
WaitThread(consumerThread)

Print "All tasks are done."
