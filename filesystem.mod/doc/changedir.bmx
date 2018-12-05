' changedir.bmx

SuperStrict

Print "CurrentDir()="+CurrentDir()

' change current folder to the parent folder

ChangeDir ".."

' print new CurrentDir()

Print "CurrentDir()="+CurrentDir()
