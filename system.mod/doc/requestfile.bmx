' requestfile.bmx

filter:String="Image Files:png,jpg,bmp;Text Files:txt;All Files:*"
filename:String=RequestFile( "Select graphic file to open",filter )

Print filename
