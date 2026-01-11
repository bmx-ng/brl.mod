SuperStrict

Framework brl.standardio
Import BRL.Path

Type TPrintWalker Implements IPathWalker
	Method WalkPath:EFileWalkResult(attributes:SPathAttributes Var)
		Print attributes.GetPath().ToString()
		Return EFileWalkResult.OK
	End Method
End Type

New TPath(".").Walk(New TPrintWalker)
