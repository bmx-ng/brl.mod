
SuperStrict

Rem
bbdoc: Audio/DirectSound audio
about:
The DirectSound audio module provides DirectSound drivers for use with the #audio module.
End Rem
Module BRL.DirectSoundAudio

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added hardware caps checking"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: First batch of fixes!"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added volume,pan,rate states to channel"
ModuleInfo "History: 1.01 Initial Release"

?win32

Import BRL.Math
Import BRL.Audio
Import Pub.DirectX

Private

Const CLOG:Int=False

Global _driver:TDirectSoundAudioDriver

Type TBuf
	Field _succ:TBuf
	Field _buffer:Byte Ptr,_seq:Int,_paused:Int
	
	Method Playing:Int()
		If _paused Return False
		Local status:Int
		DSASS bmx_directsound_IDirectSoundBuffer_getstatus(_buffer, Varptr status)
		Return (status & DSBSTATUS_PLAYING)<>0
	End Method
	
	Method Active:Int()
		If _paused Return True
		Local status:Int
		DSASS bmx_directsound_IDirectSoundBuffer_getstatus(_buffer, Varptr status)
		Return (status & DSBSTATUS_PLAYING)<>0
	End Method

End Type

Function DSASS( n:Int,t:String="DirectSound" )
	If n>=0 Return
	Throw t+" failed ("+(n & 65535)+")"
End Function

Public

Type TDirectSoundSound Extends TSound

	Method Delete()
		If _seq=_driver._seq
			_driver.AddLonely _bufs
		EndIf
	End Method

	Method Play:TDirectSoundChannel( alloced_channel:TChannel=Null ) Override
		Local t:TDirectSoundChannel=Cue( alloced_channel )
		t.SetPaused False
		Return t
	End Method

	Method Cue:TDirectSoundChannel( alloced_channel:TChannel=Null ) Override
		Local t:TDirectSoundChannel=TDirectSoundChannel( alloced_channel )
		If t
			Assert t._static
		Else
			t=TDirectSoundChannel.Create( False )
		EndIf
		t.Cue Self
		Return t
	End Method
	
	Function Create:TDirectSoundSound( sample:TAudioSample,flags:Int )
		_driver.FlushLonely
		
		Select sample.format
		Case SF_MONO16BE
			sample=sample.Convert( SF_MONO16LE )
		Case SF_STEREO16BE
			sample=sample.Convert( SF_STEREO16LE )
		End Select

		GCSuspend

		Local length:Int=sample.length
		Local hertz:Int=sample.hertz
		Local format:Int=sample.format
		Local chans:Int=ChannelsPerSample[format]
		Local bps:Int=BytesPerSample[format]/chans
		Local size:Int=length*chans*bps

		Local buf:Byte Ptr
		DSASS bmx_directsound_IDirectSound_createsoundbuffer(_driver._dsound, Varptr buf, length, hertz, format, chans, bps, size, flags, _driver._mode), "CreateSoundBuffer"
		
		If CLOG WriteStdout "Created DirectSound buffer~n"
		
		Local ptr1:Byte Ptr,bytes1:Int,ptr2:Byte Ptr,bytes2:Int
		DSASS bmx_directsound_IDirectSoundBuffer_lock(buf, 0,size,Varptr ptr1,Varptr bytes1,Varptr ptr2,Varptr bytes2,0 ),"Lock SoundBuffer"
		MemCopy ptr1,sample.samples,Size_T(size)
		DSASS bmx_directsound_IDirectSoundBuffer_unlock(buf, ptr1,bytes1,ptr2,bytes2),"Unlock SoundBuffer"

		Local t:TDirectSoundSound=New TDirectSoundSound
		t._seq=_driver._seq
		t._buffer=buf
		t._hertz=hertz
		t._loop=flags & 1
		t._bufs=New TBuf
		t._bufs._buffer=buf
		
		GCResume

		Return t
	End Function
	
	Field _seq:Int,_buffer:Byte Ptr,_hertz:Int,_loop:Int,_bufs:TBuf
	
End Type

Type TDirectSoundChannel Extends TChannel

	Method Delete()
		If Not _buf Or _seq<>_buf._seq Return
		If _buf._paused Stop
	End Method

	Method Stop() Override
		If Not _buf Or _seq<>_buf._seq Return
		bmx_directsound_IDirectSoundBuffer_stop(_buf._buffer)
		'_buf._buffer.Stop
		_buf._paused=False
		_buf._seq:+1
		_buf=Null
	End Method
	
	Method SetPaused( paused:Int ) Override
		If Not _buf Or _seq<>_buf._seq Return
		If Not _buf.Active()
			_buf._seq:+1
			_buf=Null
			Return
		EndIf
		If paused
			bmx_directsound_IDirectSoundBuffer_stop(_buf._buffer)
		Else
			bmx_directsound_IDirectSoundBuffer_play(_buf._buffer, 0, 0, _playFlags)
		EndIf
		_buf._paused=paused
	End Method
	
	Method SetVolume( volume:Float ) Override
		volume=Min(Max(volume,0),1)^.1
		_volume=volume
		If Not _buf Or _seq<>_buf._seq Return
		bmx_directsound_IDirectSoundBuffer_setvolume(_buf._buffer, Int((1-volume)*-10000))
	End Method
	
	Method SetPan( pan:Float ) Override
		pan=Min(Max(pan,-1),1)
		pan=Sgn(pan) * (1-(1-Abs(pan))^.1)		
		_pan=pan
		If Not _buf Or _seq<>_buf._seq Return
		bmx_directsound_IDirectSoundBuffer_setpan(_buf._buffer, Int(pan*10000))
	End Method
	
	Method SetDepth( depth:Float ) Override
		If Not _buf Or _seq<>_buf._seq Return
	End Method
	
	Method SetRate( rate:Float ) Override
		_rate=rate
		If Not _buf Or _seq<>_buf._seq Return
		bmx_directsound_IDirectSoundBuffer_setfrequency(_buf._buffer, Int(_hertz * rate))
	End Method
	
	Method Playing:Int() Override
		If Not _buf Or _seq<>_buf._seq Return False
		Return _buf.Playing()
	End Method

	Method Cue:Int( sound:TDirectSoundSound )
		Stop
		Local t:TBuf=sound._bufs
		While t
			If Not t.Active()
				t._seq:+1
				Exit
			EndIf
			t=t._succ
		Wend
		If Not t
			_driver.FlushLonely
			Local buf:Byte Ptr
			If bmx_directsound_IDirectSound_duplicatesoundbuffer(_driver._dsound, sound._buffer,Varptr buf)<0 Return False
			If CLOG WriteStdout "Duplicated DirectSound buffer~n"
			t=New TBuf
			t._buffer=buf
			t._succ=sound._bufs
			sound._bufs=t
		EndIf
		_sound=sound
		_buf=t
		_seq=_buf._seq
		_hertz=sound._hertz
		If sound._loop _playFlags=DSBPLAY_LOOPING Else _playFlags=0
		_buf._paused=True
		bmx_directsound_IDirectSoundBuffer_setcurrentposition(_buf._buffer, 0)
		bmx_directsound_IDirectSoundBuffer_setvolume(_buf._buffer, Int((1-_volume)*-10000))
		bmx_directsound_IDirectSoundBuffer_setpan(_buf._buffer, Int(_pan * 10000))
		bmx_directsound_IDirectSoundBuffer_setfrequency(_buf._buffer, Int(_hertz * _rate))
		Return True
	End Method
	
	Function Create:TDirectSoundChannel( static:Int )
		Local t:TDirectSoundChannel=New TDirectSoundChannel
		t._static=static
		Return t
	End Function

	Field _volume:Float=1,_pan:Float=0,_rate:Float=1,_static:Int
	Field _sound:TSound,_buf:TBuf,_seq:Int,_hertz:Int,_playFlags:Int
	
End Type

Type TDirectSoundAudioDriver Extends TAudioDriver

	Method Name:String() Override
		Return _name
	End Method
	
	Method Startup:Int() Override
		If bmx_directsound_IDirectSound_create(Varptr _dsound)>=0
			If bmx_directsound_IDirectSound_setcooperativeLevel(_dsound, GetDesktopWindow(),DSSCL_PRIORITY )>=0
				Rem
				'Never seen this succeed!
				'Apparently a NOP on Win2K/XP/Vista, and
				'probably best not to mess with it on Win98 anyway.
				Global primBuf:IDirectSoundBuffer
				Local desc:DSBUFFERDESC=New DSBUFFERDESC
				desc.dwSize=SizeOf(DSBUFFERDESC)
				desc.dwFlags=DSBCAPS_PRIMARYBUFFER
				If _dsound.CreateSoundBuffer( desc,primBuf,Null )>=0
				 	Local fmt:WAVEFORMATEX=New WAVEFORMATEX
					fmt.wFormatTag=1
					fmt.nChannels=2
					fmt.wBitsPerSample=16
					fmt.nSamplesPerSec=44100
					fmt.nBlockAlign=fmt.wBitsPerSample/8*fmt.nChannels
					fmt.nAvgBytesPerSec=fmt.nSamplesPerSec*fmt.nBlockAlign
					primBuf.SetFormat fmt
					primBuf.Release_
 				EndIf
				End Rem
				_driver=Self
				Return True
			EndIf
			bmx_directsound_IDirectSound_release(_dsound)
		EndIf
	End Method
	
	Method Shutdown() Override
		_seq:+1
		_driver=Null
		_lonely=Null
		bmx_directsound_IDirectSound_release(_dsound)
	End Method

	Method CreateSound:TDirectSoundSound( sample:TAudioSample,flags:Int ) Override
		Return TDirectSoundSound.Create( sample,flags )
	End Method
	
	Method AllocChannel:TDirectSoundChannel() Override
		Return TDirectSoundChannel.Create( True )
	End Method
	
	Function Create:TDirectSoundAudioDriver( name:String,Mode:Int )
		Local t:TDirectSoundAudioDriver=New TDirectSoundAudioDriver
		t._name=name
		t._mode=Mode
		Return t
	End Function

	Method AddLonely( bufs:TBuf )
		Local t:TBuf=bufs
		While t._succ
			t=t._succ
		Wend
		t._succ=_lonely
		_lonely=bufs
	End Method
	
	Method FlushLonely()
		Local t:TBuf=_lonely,p:TBuf
		While t
			If t.Active()
				p=t
			Else
				bmx_directsound_IDirectSoundBuffer_release(t._buffer)
				If CLOG WriteStdout "Released DirectSound buffer~n"
				If p p._succ=t._succ Else _lonely=t._succ
			EndIf
			t=t._succ
		Wend
	End Method

	Field _name:String,_mode:Int,_dsound:Byte Ptr,_lonely:TBuf

	Global _seq:Int
		
End Type

If DirectSoundCreate TDirectSoundAudioDriver.Create "DirectSound",0

?
