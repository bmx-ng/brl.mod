'
' Demostrates use of a scheduled thread pool with recurring tasks.
'
SuperStrict

Framework BRL.Standardio
Import BRL.ThreadPool

Local pool:TScheduledThreadPoolExecutor = TScheduledThreadPoolExecutor.newFixedThreadPool(11)

pool.schedule(New TTask("One-shot Task"), 5, ETimeUnit.Seconds) ' after 5 seconds
pool.schedule(New TTask("Recurring Task"), 3, 5, ETimeUnit.Seconds) ' after 3 seconds and then every 5 seconds

Delay(10 * 1000) ' wait for 10 seconds and then shutdown the pool

Print "Shutting down the pool..."

pool.shutdown()

Print "Done"

Type TTask Extends TRunnable

	Field message:String

	Method New(message:String)
		Self.message = message
	End Method

	Method run()
		Print message
	End Method
	
End Type

