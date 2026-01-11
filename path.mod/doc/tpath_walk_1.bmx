SuperStrict

Framework brl.standardio
Import BRL.Path

Type TFindReadmeWalker Implements IPathWalker
	Method WalkPath:EFileWalkResult(attributes:SPathAttributes Var)
		Local p:TPath = attributes.GetPath()
		If p.Name().ToLower() = "readme.md" Then
			Print "Found: " + p.ToString()
			Return EFileWalkResult.Terminate
		End If
		Return EFileWalkResult.OK
	End Method
End Type

New TPath(".").Walk(New TFindReadmeWalker)
