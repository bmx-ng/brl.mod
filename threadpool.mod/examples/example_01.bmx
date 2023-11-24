SuperStrict

Framework BRL.Standardio
Import BRL.ThreadPool
Import BRL.RandomDefault


Print "Thread pool with 4 threads"
Local pool:TThreadPoolExecutor = TThreadPoolExecutor.newFixedThreadPool(4)


Print "Adding 5000 tasks"

For Local n:Int = 0 Until 100
	For Local i:Int = 0 Until 50
		pool.execute(New TTask(i + n * 50))
	Next
Next

Print "Waiting for tasks to finish..."

pool.shutdown()

Print ""
Print "Complete."

End


Type TTask Extends TRunnable

	' used to keep our output in order.
	Global mutex:TMutex = TMutex.Create()

	Field value:Int

	Method New(value:Int)
		Self.value = value
	End Method

	Method run()
		Local d:Int = 1 + (3000 * (Rand(1,1000) > 998))
		Delay d
		mutex.Lock()
		If d > 100 Then
			StandardIOStream.WriteString "[" + value + "] "
			StandardIOStream.Flush()
		Else
			StandardIOStream.WriteString value + " "
		End If
		mutex.Unlock()
	End Method
	
End Type

