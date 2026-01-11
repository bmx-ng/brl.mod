Rem
Using provides a mechanism to ensure that resources implementing
the ICloseable interface are properly closed after use.
End Rem

SuperStrict

Framework BRL.StandardIO

Using
	Local closeable:TCloseableExample = New TCloseableExample
Do
	' Use the resource here
	closeable.DoSomething()
End Using

Type TCloseableExample Implements ICloseable

	Method DoSomething()
		Print "Doing something"
	End Method

	Method Close()
		Print "Resource closed"
	End Method

End Type
