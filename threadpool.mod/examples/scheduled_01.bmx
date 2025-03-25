'
' Demostrates use of a scheduled thread pool with single-shot tasks.
'
SuperStrict

Framework BRL.Standardio
Import BRL.ThreadPool

Local pool:TScheduledThreadPoolExecutor = TScheduledThreadPoolExecutor.newFixedThreadPool(11)

For Local i:Int = 10 Until 0 Step -1
	pool.schedule(New TTask(i), 10 - i, ETimeUnit.Seconds)
Next

Print "Shutting down the pool..."

pool.shutdown()

Print "Done"

Type TTask Extends TRunnable

	Field value:Int

	Method New(value:Int)
		Self.value = value
	End Method

	Method run()
		Print "Number " + value
	End Method
	
End Type

