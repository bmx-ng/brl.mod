SuperStrict

Local mystring:String = "*sniffage*, I need more media!"

' check for the position
Print Instr(mystring,"more")

If Instr(mystring,"new PC") Print "large!"
If Not Instr(mystring,"new PC") Print "*sniff*"

If Instr(mystring,"media") Print "large!"
