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

' create jconv instance
Local jconv:TJConv = New TJConvBuilder.Build()

' serialize the person data
Print jconv.ToJson(person)


Type TPerson

	Field firstName:String
	Field lastName:String

	Field address:TAddress

End Type

Type TAddress

	Field line1:String
	Field line2:String
	Field city:String
	Field state:String

End Type
