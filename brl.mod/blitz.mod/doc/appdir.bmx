' appdir.bmx
' requests the user to select a file from the application's directory

SuperStrict

Print "Application Directory="+AppDir

Local file:String = RequestFile("Select File to Open","",False,AppDir)

Print "file selected was :"+file