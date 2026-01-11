SuperStrict

Framework brl.standardio
Import BRL.Path

Type TDepthWalker Implements IPathWalker
	Method WalkPath:EFileWalkResult(attributes:SPathAttributes Var)
		Print attributes.GetDepth() + ": " + attributes.GetPath().ToString()
		Return EFileWalkResult.OK
	End Method
End Type

' Walk only the current directory and its immediate children.
New TPath(".").Walk(New TDepthWalker, EFileWalkOption.None, 1)
