SuperStrict

Framework brl.standardio
Import brl.crypto

Local keyPair:TCryptoSignKeyPair = TCryptoSign.KeyGen()

Local s:String = keyPair.ToString()

Print s
