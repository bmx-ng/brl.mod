' Copyright (c) 2006-2019 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict


Rem
bbdoc: MaxUnit - Unit Testing
End Rem
Module BRL.MaxUnit

ModuleInfo "Version: 1.06"
ModuleInfo "License: MIT"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "Credit: Based loosely on the JUnit testing framework by Erich Gamma and Kent Beck. see junit.org"
ModuleInfo "Copyright: (c) 2006-2019 Bruce A Henderson"

ModuleInfo "History: 1.06"
ModuleInfo "History: Added assertNull() and assertNotNull() pointer overloads."
ModuleInfo "History: 1.05"
ModuleInfo "History: Overloaded assertEquals() functions for NG."
ModuleInfo "History: 1.04"
ModuleInfo "History: Modified summary to count test runs, and tests."
ModuleInfo "History: TTestSuite.run() now returns number of failures. (Muttley)"
ModuleInfo "History: 1.03"
ModuleInfo "History: Improved multiple test-types support."
ModuleInfo "History: Changed tags to before/after and beforetype/aftertype"
ModuleInfo "History: 1.02"
ModuleInfo "History: Re-written to use reflection."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added delta parameter for assertEqualsF and assertEqualsD"
ModuleInfo "History: 1.00 Initial Release"


Import BRL.LinkedList
Import BRL.StandardIO
Import BRL.System
Import BRL.Reflection


Rem
bbdoc: A test defines a set of test methods to test.
about: Extend TTest to define your own tests.
<p>
Tag a method with `{before}` and initiliaze any variables/data in that method
</p>
<p>
Tag a method with `{after}` to release any permanent resources you allocated in the setup.
</p>
<p>
For each test method you want to run, tag it with `{test}`
</p>
<p>
Any methods not tagged are ignored by MaxUnit.
</p>
End Rem
Type TTest Extends TAssert

	Field tests:TList = New TList
	Field failures:TList = New TList
	Field errors:TList = New TList
	Field currentTest:TTestFunction
	Field isFail:Int = False
	Field isError:Int = False
	'Field column:Int = 0
	Field testCount:Int = 0
	Field startTime:Long = 0
	Field endTime:Long = 0

	Field _before:TMethod
	Field _after:TMethod

	Field _beforeType:TMethod
	Field _afterType:TMethod

End Type

Rem
bbdoc: A test suite defines the fixture to run multiple tests.
End Rem
Type TTestSuite Extends TAssert

	Field tests:TList = New TList
	Field failures:TList = New TList
	Field errors:TList = New TList
	Field currentTest:TTestFunction
	Field isFail:Int = False
	Field isError:Int = False
	Field column:Int = 0
	Field testCount:Int = 0
	Field startTime:Long = 0

	Method _addTest(instance:Object)
		tests.addLast(instance)
	End Method

	Method _add:TTestFunction(instance:Object, f:TMethod )
		Local t:TTestFunction = New TTestFunction
		t.name = TTypeId.ForObject(instance).Name() + "." + f.Name()
		t.instance = instance
		t.test = f
		
		TTest(instance).tests.addLast(t)
		
		Return t
	End Method
	
	
	Rem
	bbdoc: Runs the suite of tests.
	End Rem
	Method run:Int()
		startTime = MilliSecs()
	
		_addTests()

		_PrintLine("")
		_Print("[0] ")
		
		Local subTestCount:Int = 0
		
		For Local testType:TTest = EachIn tests
		
			testType.startTime = MilliSecs()
			
			Local size:Int = testType.tests.count()
			Local count:Int = 0, doBefore:Int, doAfter:Int
		
			For Local t:TTestFunction = EachIn testType.tests

				If Not count Then
					doBefore = True
				End If
				
				If count = size - 1 Then
					doAfter = True
				End If
				
				subTestCount:+ 1
				
				performTest(t, doBefore, doAfter)
			
			Next
			
			testType.endTime = MilliSecs()
		Next
		
		Local endTime:Long = MilliSecs()
		
		_PrintLine("")
		
		Local f:Int = failures.count()
		Local e:Int = errors.count()
		
		
		If f > 0 Or e > 0 Then
		
			_PrintLine("")
		
			If f > 0 Then
				_Print("There ")
				If f <> 1 Then
					_Print("were " + f + " failures")
				Else
					_Print("was 1 failure")
				End If
				_PrintLine(":")
				Local c:Int = 1
				For Local t:TTestFunction = EachIn failures
					_PrintLine( c + ") " + t.name)
					_PrintLine("    " + t.reason)
					_PrintLine("")
					c:+ 1
				Next
			End If
			If e > 0 Then
				' add a spacer
				If f > 0 Then
					_PrintLine("")
					_PrintLine("")					
				End If
				
				_Print("There ")
				If e <> 1 Then
					_Print("were " + e + " errors")
				Else
					_Print("was 1 error")
				End If
				_PrintLine(":")
				Local c:Int = 1
				For Local t:TTestFunction = EachIn errors
					_PrintLine( c + ") " + t.name)
					_PrintLine("    " + t.reason)
					_PrintLine("")
					c:+ 1
				Next
			End If			
			
			_PrintLine("")
			
			_PrintLine("FAILURES!!!")
			_PrintLine("Test Runs: " + tests.count() + ", Tests: " + subTestCount + ..
				",  Failures: " + f + ",  Errors: " + e )
		Else
			_Print("OK (" + subTestCount + " test")
			If tests.count() <> 1 Then
				_Print("s")
			End If
			_PrintLine(")")
		End If
		
		_PrintLine("Time: " + ((endTime - startTime)/1000) + "." + (((endTime - startTime) Mod 1000)))
	
		Return f
	End Method
	
	Method performTest(t:TTestFunction, First:Int = False, last:Int = False)
		isFail = False
		isError = False

		' This is the current test
		currentTest = t

		If First Then
			Try
				' run any user-specific pre-test setup
				If TTest(t.instance)._beforeType Then
					TTest(t.instance)._beforeType.Invoke(t.instance, Null)
				End If
			Catch ex:Object
				isError = True
				t.reason = "Exception in beforeType() - " + ex.toString()
			End Try
		End If
			
		Try
			' run any user-specific setup
			If TTest(t.instance)._before Then
				TTest(t.instance)._before.Invoke(t.instance, Null)
			End If
		Catch ex:Object
			isError = True
			t.reason = "Exception in before() - " + ex.toString()
		End Try


		' +++++++++++++++++++++++++++
		If Not isError Then
			Try
				' run the test function
				t.test.Invoke(t.instance, Null)
				
			Catch ex:AssertionFailedException
				isFail = True
				t.reason = ex.toString()
			Catch ex:Object
				isError = True
				t.reason = "Exception - " + ex.toString()
			End Try
		End If
		' +++++++++++++++++++++++++++
		
		Try
			' run any user-specific teardown
			If TTest(t.instance)._after Then
				TTest(t.instance)._after.Invoke(t.instance, Null)
			End If
		Catch ex:Object
			isError = True
			t.reason = "Exception in after() - " + ex.toString()
		End Try
		
		If last Then
			Try
				' run any user-specific post-test setup
				If TTest(t.instance)._afterType Then
					TTest(t.instance)._afterType.Invoke(t.instance, Null)
				End If
			Catch ex:Object
				isError = True
				t.reason = "Exception in afterType() - " + ex.toString()
			End Try
		End If
		
		If Not isFail Then
			If Not isError Then
				_Print(".")
			Else
				errors.addLast(currentTest)
				_Print("E")
			End If
		Else
			failures.addLast(currentTest)
			_Print("F")
		End If
		
		column:+ 1
		If column > 40 Then
			_PrintLine("")
			_Print("[" + testCount + "] ")
			column = 0
		End If
		testCount:+1
	End Method
	
	Function _Print( str:String="" )
		StandardIOStream.WriteString str
		StandardIOStream.Flush
	End Function

	Function _PrintLine( str:String="" )
		StandardIOStream.WriteLine str
		StandardIOStream.Flush
	End Function

	Method _addTests()

		' This is the base type, TTest. We'll run tests on all Types that extend it.	
		Local idTest:TTypeId = TTypeId.ForName("TTest")

		_addTests(idTest)
		
	End Method
	
	Method _addTests(baseIdType:TTypeId)

		' process each derived type...
		For Local id:TTypeId = EachIn baseIdType.DerivedTypes()

			Local obj:Object = Null
			
			For Local meth:TMethod = EachIn id.EnumMethods()
			
				If Not obj Then
					obj = id.NewObject()
					_addTest(obj)
				End If
			
				If meth.MetaData("test") Then      ' a test method
					_add(obj, meth)
				End If

				If meth.MetaData("before") Then     ' a setup method
					Local f:TField = id.FindField("_before")
					f.Set(obj, meth)
				End If

				If meth.MetaData("after") Then  ' a teardown method
					Local f:TField = id.FindField("_after")
					f.Set(obj, meth)
				End If

				If meth.MetaData("beforetype") Then     ' a setup method
					Local f:TField = id.FindField("_beforetype")
					f.Set(obj, meth)
				End If

				If meth.MetaData("aftertype") Then  ' a teardown method
					Local f:TField = id.FindField("_aftertype")
					f.Set(obj, meth)
				End If

			Next	

			_addTests(id)

		Next
	End Method
	
End Type

Type TTestFunction

	Field name:String
	Field test:TMethod
	Field reason:String
	Field instance:Object

End Type


Rem
bbdoc: Failed assertion.
End Rem
Type AssertionFailedException
	Field message:String
	
	Function Create:AssertionFailedException(message:String)
		Local this:AssertionFailedException = New AssertionFailedException
		this.message = message
		Return this
	End Function
	
	Method toString:String() Override
		Return message
	End Method
End Type


Rem
bbdoc: A set of assert methods.
about: Messages are only displayed when an assert fails.
End Rem
Type TAssert

	Rem
	bbdoc: Asserts that a condition is #True.
	about: If it isn't #True, it throws an #AssertionFailedException with the given message.
	End Rem
	Function assertTrue(bool:Int, message:String = Null)
		If Not bool Then
			fail("assertTrue() : " + message)
		End If
	End Function
	
	Rem
	bbdoc: Asserts that a condition is #False.
	about: If it isn't #False, it throws an #AssertionFailedException with the given message.
	End Rem
	Function assertFalse(bool:Int, message:String = Null)
		If bool Then
			fail("assertFalse() : " + message)
		End If
	End Function


	Rem
	bbdoc: Fails a test with the given message.
	End Rem
	Function fail(message:String)
		Throw AssertionFailedException.Create(message)
	End Function


	Rem
	bbdoc: Asserts that two objects are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertEquals(expected:Object, actual:Object, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And expected.compare(actual) = 0 Then
			Return
		End If
		failNotEquals(expected, actual, "assertEquals() : " + message)
	End Function

	Rem
	bbdoc: Asserts that two ints are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsI(expected:Int, actual:Int, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromInt(expected), String.fromInt(actual), "assertEqualsI() : " +message)
  	End Function

	Rem
	bbdoc: Asserts that two longs are equal.
	about: If they are not equal an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsL(expected:Long, actual:Long, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromLong(expected), String.fromLong(actual), "assertEqualsL() : " +message)
  	End Function


	Rem
	bbdoc: Asserts that two floats are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsF(expected:Float, actual:Float, delta:Float = 0, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		If Not(Abs(expected - actual) <= delta) Then
			failNotEquals(String.fromFloat(expected), String.fromFloat(actual), "assertEqualsF() : " +message)
		End If
  	End Function

	Rem
	bbdoc: Asserts that two doubles are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsD(expected:Double, actual:Double, delta:Double = 0, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		If Not(Abs(expected - actual) <= delta) Then
			failNotEquals(String.fromDouble(expected), String.fromDouble(actual), "assertEqualsD() : " +message)
		End If
  	End Function

	Rem
	bbdoc: Asserts that two shorts are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsS(expected:Short, actual:Short, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromInt(expected), String.fromInt(actual), "assertEqualsS() : " +message)
  	End Function

	Rem
	bbdoc: Asserts that two bytes are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEqualsB(expected:Byte, actual:Byte, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromInt(expected), String.fromInt(actual), "assertEqualsB() : " + message)
  	End Function

	Rem
	bbdoc: Asserts that an object isn't #Null.
	about: If it is #Null, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertNotNull(obj:Object, message:String = Null)
		If obj = Null Or IsEmptyArray(obj) Or IsEmptyString(obj) Then
			fail("assertNotNull() : " + message)
		End If
	End Function

	Rem
	bbdoc: Asserts that a pointer isn't #Null.
	about: If it is #Null, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertNotNull(value:Byte Ptr, message:String = Null)
		If value = Null Then
			fail("assertNotNull() : " + message)
		End If
	End Function
	
	Rem
	bbdoc: Asserts that an #Object is #Null.
	about:
	If it is not #Null, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertNull(obj:Object, message:String = Null)
		If obj <> Null And Not IsEmptyArray(obj) And Not IsEmptyString(obj) Then
			fail("assertNull() : " + message)
		End If
	End Function

	Rem
	bbdoc: Asserts that two objects refer to the same #Object.
	about: If they are not the same, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertSame(expected:Object, actual:Object, message:String = Null)
		If expected = actual Then
			Return
		End If
		failNotSame(expected, actual, "assertSame() : " + message)
	End Function

	Rem
	bbdoc: Asserts that an pointer is #Null.
	about:
	If it is not #Null, an #AssertionFailedException is thrown with the given message.
	End Rem
	Function assertNull(value:Byte Ptr, message:String = Null)
		If value <> Null Then
			fail("assertNull() : " + message)
		End If
	End Function

 	Rem
 	bbdoc: Asserts that two objects refer to different objects.
	about: If they are the same, an #AssertionFailedException is thrown with the given message.
 	End Rem
	Function assertNotSame(expected:Object, actual:Object, message:String = Null)
		If expected = actual Then
			failSame("assertNotSame() : " + message)
		End If
	End Function


	Function failSame(message:String)
		Local formatted:String = ""
 		If message <> Null Then
 			formatted = message + " "
		End If
 		fail(formatted + "expected not same")
	End Function

	Function failNotSame(expected:Object, actual:Object, message:String = Null)
		Local formatted:String = ""
		If message <> Null Then
			formatted= message + " "
		End If
		fail(formatted + "expected same:<" + expected.toString() + "> was not:<" + actual.toString() + ">")
	End Function


	Function failNotEquals(expected:Object, actual:Object, message:String = Null)
		fail(format(expected, actual, message))
	End Function

	Function format:String(expected:Object, actual:Object, message:String = Null)
		Local formatted:String = ""
		If message <> Null Then
			formatted = message + " "
		End If
		Return formatted + "expected:<" + expected.toString() + "> but was:<" + actual.toString() + ">"
	End Function

  	Function assertEquals(expected:Int, actual:Int, message:String = Null)
		assertEqualsI(expected, actual, message)
	End Function

  	Function assertEquals(expected:Long, actual:Long, message:String = Null)
		assertEqualsL(expected, actual, message)
	End Function

 	Function assertEquals(expected:Float, actual:Float, delta:Float = 0, message:String = Null)
		assertEqualsF(expected, actual, delta, message)
	End Function

  	Function assertEquals(expected:Double, actual:Double, delta:Double = 0, message:String = Null)
		assertEqualsD(expected, actual, delta, message)
	End Function

  	Function assertEquals(expected:Short, actual:Short, message:String = Null)
		assertEqualsS(expected, actual, message)
	End Function

  	Function assertEquals(expected:Byte, actual:Byte, message:String = Null)
		assertEqualsB(expected, actual, message)
	End Function

	Rem
	bbdoc: Asserts that two UInts are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEquals(expected:UInt, actual:UInt, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromUInt(expected), String.fromUInt(actual), "assertEquals() : " +message)
  	End Function

	Rem
	bbdoc: Asserts that two ULongs are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEquals(expected:ULong, actual:ULong, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromULong(expected), String.fromULong(actual), "assertEquals() : " +message)
  	End Function

	Rem
	bbdoc: Asserts that two Size_Ts are equal.
	about: If they are not equal, an #AssertionFailedException is thrown with the given message.
	End Rem
  	Function assertEquals(expected:Size_T, actual:Size_T, message:String = Null)
		If expected = Null And actual = Null Then
			Return
		End If
		If expected <> Null And actual <> Null Then
			If expected = actual Then
				Return
			End If
		End If
		failNotEquals(String.fromSizeT(expected), String.fromSizeT(actual), "assertEquals() : " +message)
  	End Function

End Type
