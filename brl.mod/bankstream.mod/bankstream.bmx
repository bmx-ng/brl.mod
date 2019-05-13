
SuperStrict

Rem
bbdoc: Streams/Bank streams
End Rem
Module BRL.BankStream

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.02"
ModuleInfo "History: Made SuperStrict."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added TBankStreamFactory"

Import BRL.Bank
Import BRL.Stream

Rem
bbdoc: BankStream Object
End Rem
Type TBankStream Extends TStream

	Field _pos:Long,_bank:TBank

	Method Pos:Long()
		Return _pos
	End Method

	Method Size:Long()
		Return _bank.Size()
	End Method

	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ )
		If whence = SEEK_SET_ Then
			If pos<0 pos=0 Else If pos>_bank.Size() pos=_bank.Size()
		ElseIf whence = SEEK_END_ Then
			If pos>=0 Then
				pos = _bank.Size()
			Else
				pos = _bank.Size() + pos
				If pos < 0 Then
					pos = 0
				End If
			End If
		End If
		_pos=pos
		Return _pos
	End Method
	
	Method Read:Long( buf:Byte Ptr,count:Long )
		If count<=0 Or _pos>=_bank.Size() Return 0
		If _pos+count>_bank.Size() count=_bank.Size()-_pos
		MemCopy buf,_bank.Buf()+_pos,Size_T(count)
		_pos:+count
		Return count
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long )
		If count<=0 Or _pos>_bank.Size() Return 0
		If _pos+count>_bank.Size() _bank.Resize Size_T(_pos+count)
		MemCopy _bank.Buf()+_pos,buf,Size_T(count)
		_pos:+count
		Return count
	End Method

	Rem
	bbdoc: Create a bank stream
	returns: A bank stream object
	about:
	A bank stream allows you to read data into or out of a bank. A bank stream extends a stream so
	can be used in place of a stream.
	end rem
	Function Create:TBankStream( bank:TBank )
		Local stream:TBankStream=New TBankStream
		stream._bank=bank
		Return stream
	End Function
	
End Type

Rem
bbdoc: Create a bank stream
returns: A bank stream object
about:
A bank stream allows you to read data into or out of a bank. A bank stream extends a stream so
can be used in place of a stream.
end rem
Function CreateBankStream:TBankStream( bank:TBank )
	If Not bank bank=TBank.Create(0)
	Return TBankStream.Create( bank )
End Function

Type TBankStreamFactory Extends TStreamFactory

	Method CreateStream:TBankStream( url:Object,proto$,path$,readable:Int,writeable:Int )
		Local bank:TBank=TBank(url)
		If bank Return CreateBankStream( bank )
	End Method
	
End Type

New TBankStreamFactory
