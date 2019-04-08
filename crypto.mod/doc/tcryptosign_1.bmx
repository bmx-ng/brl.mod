SuperStrict

Framework brl.standardio
Import brl.crypto

' generate a key pair
Local keyPair:TCryptoSignKeyPair = TCryptoSign.KeyGen()

Print "keypair : " + keyPair.ToString()

Local signature:TCryptoSignature

Local message:String[] = ["Just a castaway, an island lost at sea. " , ..
	"Another lonely day with no one here but me. " , ..
	"More loneliness than any man could bear. " , ..
	"Rescue me before I fall into despair."]

' create a signer with context
Local signer:TCryptoSign = New TCryptoSign.Create("example")

' update all the parts
Update(signer, message)

' create the signature
signer.FinishCreate(signature, keyPair)

Print "signature : " + signature.ToString()

' create a verifier with context
Local verifier:TCryptoSign = New TCryptoSign.Create("example")

' update all the parts
Update(verifier, message)

' verify the public key against the signature
If verifier.FinishVerify(signature, keyPair) Then
	Print "Verified !"
Else
	Print "Invalid"
End If


Function Update(signer:TCryptoSign, message:String[])
	For Local i:Int = 0 Until message.length
		Local mb:Byte Ptr = message[i].ToUTF8String()
		signer.Update(mb, Size_T(message[i].length))
		MemFree(mb)
	Next
End Function
