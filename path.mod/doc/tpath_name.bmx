SuperStrict

Framework brl.standardio
Import BRL.Path

Local p1:TPath = New TPath("/etc/init.d/reboot")
Local p2:TPath = New TPath("src/main.bmx")
Local p3:TPath = New TPath("/home/user/.bashrc")

Print p1.Name() ' reboot
Print p2.Name() ' main.bmx
Print p3.Name() ' .bashrc
