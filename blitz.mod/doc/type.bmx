Rem
Type marks the beginning of a BlitzMax custom type.

Standard BlitzMax types use a preceeding "T" naming
convention to differentiate themselves from standard
BlitzMax variable names.
End Rem

SuperStrict

Framework BRL.StandardIO


Type TVector
	Field x:Int,y:Int,z:Int
End Type

Local a:TVector=New TVector

a.x=10
a.y=20
a.z=30
