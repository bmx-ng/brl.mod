Rem
Self is used in BlitzMax Methods to reference the invoking variable.
End Rem

SuperStrict

Type MyClass
	Global count:Int
	Field id:Int
	
	Method New()
		id=count
		count:+1
		ClassList.AddLast(Self)	'adds this new instance to a global list		
	End Method
End Type

Global ClassList:TList

classlist=New TList

Local c:MyClass

c=New MyClass
c=New MyClass
c=New MyClass

For c=EachIn ClassList
	Print c.id
Next
