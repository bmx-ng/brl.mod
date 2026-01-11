SuperStrict

Framework brl.standardio
Import BRL.Path

Local p1:TPath = New TPath("/etc/init.d/reboot.sh")
Local p2:TPath = New TPath("archive.tar.gz")
Local p3:TPath = New TPath(".gitignore")

Print p1.BaseName() ' reboot
Print p2.BaseName() ' archive.tar
Print p3.BaseName() ' .gitignore
