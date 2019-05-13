'
' Example of KK variant key exchange
'
' What the client needs to know about the server: the server's public key
' What the server needs to know about the client: the client's public key
'
' This variant is designed to exchange messages between two parties that already know each other's public key.
'
SuperStrict

Framework brl.standardio
Import brl.crypto

Local server:TServer = New TServer
Local client:TClient = New TClient

Print "SHARE PUBLIC KEYS"

' Client: generate a long-term key pair
Print "Client: Generate a long-term key pair~n"
client.keyPair = TCryptoKeyExchange.KeyGen()

' Server: generate a long-term key pair
Print "Server: Generate a long-term key pair~n"
server.keyPair = TCryptoKeyExchange.KeyGen()

' Client: send public key to server
client.SendPublicKey(server)

' Server: send public key to client
server.SendPublicKey(client)

' KEY EXCHANGE
Print "KEY EXCHANGE"

' Client: initiate a key exchange
client.InitSession()

' Client: send packet to server
client.SendPacketToServer(server)

' Server: process the initial request from the client, and compute the session keys
server.ComputeSessionKeys()

' Server: send packet to client
server.SendPacketToClient(client)

' Client: process the server packet and compute the session keys
client.ComputeSessionKeys()

Print "BEGIN MESSAGING"

'
' Client and Server can now securely send data to each other using their session keys
'
client.EncryptAndSendMessage(server, "Hello Server!")

server.EncryptAndSendMessage(client, "Hello Client!")

Type TBase

	Field keyPair:TCryptoExchangeKeyPair
	Field otherPublicKey:TCryptoExchangeKeyPair

	Field sessionKeyPair:TCryptoSessionKeyPair

	Method Name:String() Abstract

	Method SendPublicKey(rec:TBase)
		Print Name() + ": Sending my public key~n"
		rec.ReceivePublicKey(keyPair.PublicKeyToString())
	End Method
	
	Method ReceivePublicKey(key:String)
		Print Name() + ": Received other public key~n"
		otherPublicKey = TCryptoExchangeKeyPair.PublicKeyFromString(key)
	End Method

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

	Field clientPacket:TCryptoKK1Packet
	Field packet2:TCryptoKK2Packet

	Method Name:String()
		Return "Server"
	End Method
	
	Method ReceivePacketFromClient(packet:String)
		clientPacket = TCryptoKK1Packet.FromString(packet)
		Print "Server: Received packet1 from client~n"
	End Method
	
	Method ComputeSessionKeys()
		Print "Server: Computing session keys~n"
		If Not TCryptoKeyExchange.KK2(sessionKeyPair, packet2, clientPacket, otherPublicKey, keyPair) Then
			Throw "Couldn't calculate server session keys~n"
		End If
	End Method

	Method SendPacketToClient(client:TClient)
		Print "Server: Sending packet to client~n"
		client.ReceivePacketFromServer(packet2.ToString())
	End Method
	
End Type


Type TClient Extends TBase

	Field state:TCryptoExchangeState
	Field packet1:TCryptoKK1Packet
	Field serverPacket:TCryptoKK2Packet
	
	Method Name:String()
		Return "Client"
	End Method

	Method InitSession()
		Print "Client: Initial packet creation~n"
		If Not TCryptoKeyExchange.KK1(state, packet1, otherPublicKey, keyPair ) Then
			Throw "Couldn't create initial client packet/state~n"
		End If
	End Method
	
	Method SendPacketToServer(server:TServer)
		Print "Client: Sending packet to server~n"
		server.ReceivePacketFromClient(packet1.ToString())
	End Method
	
	Method ReceivePacketFromServer(packet:String)
		serverPacket = TCryptoKK2Packet.FromString(packet)
		Print "Client: Received packet2 from server~n"
	End Method

	Method ComputeSessionKeys()
		Print "Client: Computing session keys~n"
		If Not TCryptoKeyExchange.KK3(state, sessionKeyPair, serverPacket, keyPair) Then
			Throw "Couldn't calculate client session keys~n"
		End If
	End Method

End Type
