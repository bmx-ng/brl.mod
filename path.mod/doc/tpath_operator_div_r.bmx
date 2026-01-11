SuperStrict

Framework brl.standardio
Import BRL.Path

Local root:TPath = New TPath("/etc")
Local p:TPath = root / "init.d" / "reboot"

Print p.ToString() ' /etc/init.d/reboot
