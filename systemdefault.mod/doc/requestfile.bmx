' requestfile.bmx

SuperStrict

Local filter:String = "Image Files:png,jpg,bmp;Text Files:txt;All Files:*"
Local filename:String = RequestFile( "Select graphic file to open",filter )

Print filename
