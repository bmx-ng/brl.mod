SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("archive.tar.gz")

Print p.ToString()                 ' archive.tar.gz
Print p.WithExtension("zip").ToString()       ' archive.tar.zip
Print p.WithExtension(".txt").ToString()      ' archive.tar.txt
Print p.WithExtension("").ToString()          ' archive.tar