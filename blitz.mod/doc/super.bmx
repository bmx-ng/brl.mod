Rem
Super evaluates to Self cast to the method's immediate base class.
End Rem

SuperStrict

Framework BRL.StandardIO


Type TypeA
	Method Report()
		Print "TypeA reporting"
	End Method
End Type

Type TypeB Extends TypeA
	Method Report()
		Print "TypeB Reporting"
		Super.Report()
	End Method
End Type

Local b:TypeB=New TypeB
b.Report()
