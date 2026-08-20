SuperStrict

Framework brl.standardio
Import BRL.Threads
Import BRL.Time
Import BRL.System
Import BRL.MaxUnit

New TTestSuite.run()

Type TSemaphoreTest Extends TTest

	Method TimedWait_HandlesTimeoutAcrossSecondBoundary() { test }
		Const timeoutMs:Int = 250
		Const minimumElapsedMs:ULong = 200

		Local phase:ULong = CurrentUnixTime() Mod 1000

		While phase < 800 Or phase >= 900
			Delay 1
			phase = CurrentUnixTime() Mod 1000
		Wend

		Local semaphore:TSemaphore = TSemaphore.Create(0)
		AssertTrue(semaphore <> Null, "Semaphore creation should succeed")

		Local started:ULong = CurrentUnixTime()
		Local result:Int = semaphore.TimedWait(timeoutMs)
		Local elapsed:ULong = CurrentUnixTime() - started

		AssertTrue(elapsed >= minimumElapsedMs, "TimedWait should not return before the timeout expires")
		AssertEquals(1, result, "TimedWait should report a timeout")
	End Method

End Type
