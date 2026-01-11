SuperStrict

Framework brl.standardio
Import BRL.Path

Local p:TPath = New TPath("/etc/init.d/reboot")

Print p.Parent().ToString() ' /etc/init.d
