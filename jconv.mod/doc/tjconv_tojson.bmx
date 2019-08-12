SuperStrict

Framework brl.standardio
Import brl.jconv


' create a person with some data
Local person:TPerson = New TPerson
person.firstName = "John"
person.lastName = "Smith"

person.address = New TAddress
person.address.line1 = "10 Somewhere Street"
person.address.city = "SomeTown"
person.address.state = "SomeState"

person.notes = New String[2]
person.notes[0] = "Note 1"
person.notes[1] = "Note 2"

' create jconv instance
Local jconv:TJConv = New TJConvBuilder.Build()

' serialize the person data
Local s:String = jconv.ToJson(person)
Print s
Local p:TPerson = TPerson(jconv.FromJson(s, "TPerson"))
Print jconv.ToJson(p)

Type TPerson

	Field firstName:String
	Field lastName:String

	Field address:TAddress

	Field notes:String[]
End Type

Type TAddress

	Field line1:String
	Field line2:String
	Field city:String
	Field state:String

End Type
