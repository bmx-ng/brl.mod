SuperStrict

Framework brl.standardio
Import brl.crypto

' generate a key pair
Local keyPair:TCryptoSignKeyPair = TCryptoSign.KeyGen()

Print "keypair : " + keyPair.ToString()

Local signature:TCryptoSignature

Local message:String = "Just a castaway, an island lost at sea. Another lonely day with no one here but me. More loneliness than any man could bear. Rescue me before I fall into despair."
Local mb:Byte Ptr = message.ToUTF8String()

' sign the message with the secret key
TCryptoSign.Sign(signature, mb, Size_T(message.length), "example", keyPair)

Print "signature : " + signature.ToString()

' verify the message with public key
If TCryptoSign.Verify(signature, mb, Size_T(message.length), "example", keyPair) Then
	Print "Verified !"
Else
	Print "Invalid"
End If

MemFree(mb)
