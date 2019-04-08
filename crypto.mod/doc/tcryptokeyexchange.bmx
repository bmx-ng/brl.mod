'
' Example of N variant key exchange
'
' What the client needs to know about the server: the server's public key
' What the server needs to know about the client: nothing
'
SuperStrict

Framework brl.standardio
Import brl.crypto

Local server:TServer = New TServer
Local client:TClient = New TClient

Print "SHARE PUBLIC KEY"
' Server: generate a long-term key pair
Print "Server: Generate a long-term key pair~n"
server.keyPair = TCryptoKeyExchange.KeyGen()

' Server: send public key to client
server.SendPublicKeyToClient(client)

Print "KEY EXCHANGE"

' Client: generate session keys and a packet with an ephemeral public key to send to the server
client.BuildKeys()

' Client: send packet to server
client.SendPacketToServer(server)

' Server: process the initial request from the client, and compute the session keys
server.ComputeSessionKeys()

Print "BEGIN MESSAGING"
'
' Client and Server can now securely send data to each other using their session keys
'
client.EncryptAndSendMessage(server, "Hello Server!")

server.EncryptAndSendMessage(client, "Hello Client!")

Type TBase

	Field sessionKeyPair:TCryptoSessionKeyPair

	Method Name:String() Abstract

	Method EncryptAndSendMessage(base:TBase, message:String)
		
		Local msg:Byte Ptr = message.ToUTF8String()
		
		Print Name() + ": Message to send : " + message + "~n"
		
		Local c:Byte[message.length + CRYPTO_SECRETBOX_HEADERBYTES]
		TCryptoSecretBox.Encrypt(c, Size_T(c.length), msg, Size_T(message.length), 0, "example", sessionKeyPair.tx)
		
		MemFree(msg)
		
		Local encoded:String = TBase64.Encode(c)

		Print Name() + ": Sending encrypted message : " + encoded + "~n"
		
		base.ReceiveMessage(encoded)
	End Method

	Method ReceiveMessage(encoded:String)
		Print Name() + ": Received encoded message~n"
		Local m:Byte[] = TBase64.Decode(encoded)
		
		Local msg:Byte[m.length - CRYPTO_SECRETBOX_HEADERBYTES]
		
		If Not TCryptoSecretBox.Decrypt(msg, Size_T(msg.length), m, Size_T(m.length), 0, "example", sessionKeyPair.rx) Then
			Throw Name() + ": Unable to decrypt message"
		End If
		
		Local message:String = String.FromUTF8String(msg)
		
		Print Name() + ": Decrypted message : " + message + "~n"
	End Method

End Type

Type TServer Extends TBase

	Field keyPair:TCryptoExchangeKeyPair

	Field clientPacket:TCryptoNPacket

	Method Name:String()
		Return "Server"
	End Method
	
	Method SendPublicKeyToClient(client:TClient)
		Print "Server: Sending public key to client~n"
		client.ReceiveServerPublicKey(keyPair.PublicKeyToString())
	End Method
	
	Method ReceivePacketFromClient(packet:String)
		clientPacket = TCryptoNPacket.FromString(packet)
		Print "Server: Received packet from client~n"
	End Method
	
	Method ComputeSessionKeys()
		Print "Server: Computing session keys~n"
		If Not TCryptoKeyExchange.N2(sessionKeyPair, clientPacket, Null, keyPair) Then
			Throw "Couldn't calculate server session keys~n"
		End If
	End Method
	
End Type


Type TClient Extends TBase

	Field serverPublicKey:TCryptoExchangeKeyPair

	Field packet:TCryptoNPacket

	Method Name:String()
		Return "Client"
	End Method

	Method ReceiveServerPublicKey(key:String)
		Print "Client: Received server public key~n"
		serverPublicKey = TCryptoExchangeKeyPair.PublicKeyFromString(key)
	End Method
	
	Method BuildKeys()
		Print "Client: Creating packet~n"
		If Not TCryptoKeyExchange.N1(sessionKeyPair, packet, Null, serverPublicKey) Then
			Throw "Couldn't calculate client session keys~n"
		End If
	End Method
	
	Method SendPacketToServer(server:TServer)
		Print "Client: Sending packet to server~n"
		server.ReceivePacketFromClient(packet.ToString())
	End Method
	
End Type
