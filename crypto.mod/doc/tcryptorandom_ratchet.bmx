SuperStrict

Framework brl.standardio
Import brl.crypto

For Local i:Int = 0 Until 10
	Print TCryptoRandom.Random()
Next

TCryptoRandom.Ratchet()

