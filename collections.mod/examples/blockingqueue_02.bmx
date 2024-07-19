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
        Try
            Print "Producing " + i
            queue.Enqueue(i, 100, ETimeUnit.Milliseconds) ' 100 milliseconds timeout
            Delay 100 ' Simulate work
        Catch ex:TTimeoutException
            Print "Enqueue timed out: " + ex.ToString()
        End Try
    Next
End Function

Function Consumer:Object(data:Object)
	Local queue:TBlockingQueue<Int> = TBlockingQueue<Int>(data)

    For Local i:Int = 1 To 10
        Try
            Local item:Int = queue.Dequeue(1500, ETimeUnit.Milliseconds) ' 1.5 second timeout
            Print "Consuming " + item
            Delay 1000 ' Simulate work
        Catch ex:TTimeoutException
            Print "Dequeue timed out: " + ex.ToString()
        End Try
    Next
End Function

Local queue:TBlockingQueue<Int> = New TBlockingQueue<Int>(5)
Local producerThread:TThread = CreateThread(Producer, queue)
Local consumerThread:TThread = CreateThread(Consumer, queue)

WaitThread(producerThread)
WaitThread(consumerThread)

Print "All tasks are done."
