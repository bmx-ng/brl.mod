SuperStrict

Framework brl.standardio
Import brl.crypto

Const OPS_LIMIT:Int = 10000

Local password:String = "Password123"

' generate a master key
Local masterKey:TCryptoPWHashMasterKey = TCryptoPasswordHash.KeyGen()

Print "Master key : " + masterKey.ToString()

Local storedKey:TCryptoPWHashStoredKey

' calculate stored key based on password, master key and parameters
TCryptoPasswordHash.Create(storedKey, password, masterKey, OPS_LIMIT, 0)

Print "Password Hash : " + storedKey.ToString()

' verify the password against the stored key
Verify(storedKey, password, masterKey)

Local wrongPass:String = "password123"

' try to verify the wrong password against the stored key
Verify(storedKey, wrongPass, masterKey)


Function Verify(storedKey:TCryptoPWHashStoredKey, password:String, masterKey:TCryptoPWHashMasterKey)
	If TCryptoPasswordHash.Verify(storedKey, password, masterKey, 50000, 0) Then
		Print "Verified"
	Else
		Print "Invalid"
	End If
End Function
