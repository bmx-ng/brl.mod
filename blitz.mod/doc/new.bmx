Rem
New creates a BlitzMax variable of the Type specified.
End Rem

SuperStrict

Framework BRL.StandardIO


Type MyType
	Field a:Int,b:Int,c:Int
End Type

Local t:MyType
t=New MyType
t.a=20

Print t.a

' if a new method is defined for the type it will also be called

Type MyClass
	Field a:Int,b:Int,c:Int
	Method New()
		Print "Constructor invoked!"
		a=10
	End Method
	
	' the new method can be overridden to provide even more construction options
	Method New(b:Int, c:Int)
		New() ' the default new can also be called from inside this one
		Self.b = b
		Self.c = c
	End Method
End Type

Local c:MyClass
c=New MyClass
Print c.a

c = New MyClass(5, 15)
Print c.a
Print c.b
Print c.c
