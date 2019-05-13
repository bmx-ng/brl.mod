
Strict

Rem
bbdoc: Audio/OGG loader
about:
The OGG loader module provides the ability to load OGG format #{audio samples}.
End Rem
Module BRL.OGGLoader

ModuleInfo "Version: 1.04"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Moved SaveOgg to module axe.saveogg"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added Function SaveOgg"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed reading past end of stream with some short files"

Import Pub.OggVorbis
Import BRL.AudioSample

Private

Function readfunc( buf@Ptr,size,nmemb,src:Object )
	Local bytes:Long=TStream(src).Read(buf,size*nmemb)
	Return bytes/size
End Function

Function seekfunc( src_obj:Object,offset:Long,whence )
	Local src:TStream=TStream(src_obj)
	Return src.Seek(offset, whence)
End Function

Function closefunc( src:Object )
End Function

Function tellfunc:Long( src:Object )
	Return TStream(src).Pos()
End Function

Type TAudioSampleLoaderOGG Extends TAudioSampleLoader

	Method LoadAudioSample:TAudioSample( stream:TStream ) Override

		Local samples,channels,freq
		Local ogg:Byte Ptr=Decode_Ogg(stream,readfunc,seekfunc,closefunc,tellfunc,samples,channels,freq)
	
		If Not ogg Return

		Local format
?BigEndian
		If channels=1 format=SF_MONO16BE Else format=SF_STEREO16BE
?LittleEndian
		If channels=1 format=SF_MONO16LE Else format=SF_STEREO16LE
?
		Local size=samples*2*channels
		Local sample:TAudioSample=TAudioSample.Create( samples,freq,format )

		'negative amounts indicate an error, 0 = EOF, >0 = amount of bytes
		Local bytesRead:Int = Read_Ogg( ogg,sample.samples,size )
		Read_Ogg( ogg,Null,0 )
		If bytesRead <= 0 Return

		Return sample

	End Method

End Type

AddAudioSampleLoader New TAudioSampleLoaderOGG
