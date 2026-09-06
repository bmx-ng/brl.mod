SuperStrict

Framework BRL.StandardIO
Import BRL.MaxUnit
Import BRL.Socket

New TTestSuite.Run()

Type TSocketTest Extends TTest

	Method TestTCPLoopback() { test }
		Local listener:TSocket = CreateTCPSocket()
		AssertNotNull(listener)
		AssertTrue(BindSocket(listener, 0, AF_INET_))
		AssertTrue(SocketListen(listener, 1))
		AssertTrue(SocketLocalPort(listener) > 0)

		Local hints:TAddrInfo = New TAddrInfo(AF_INET_, SOCK_STREAM_)
		Local addresses:TAddrInfo[] = AddrInfo("127.0.0.1", String(SocketLocalPort(listener)), hints)
		AssertTrue(addresses.Length > 0)

		Local client:TSocket = TSocket.Create(addresses[0])
		AssertNotNull(client)
		AssertTrue(ConnectSocket(client, addresses[0]))

		Local server:TSocket = SocketAccept(listener, 1000)
		AssertNotNull(server)

		Local sent:Byte[] = [Byte(11), Byte(22), Byte(33), Byte(44)]
		Local received:Byte[4]
		AssertEquals(sent.Length, Int(client.Send(sent, Size_T(sent.Length))))
		AssertEquals(received.Length, Int(server.Recv(received, Size_T(received.Length))))

		For Local i:Int = 0 Until sent.Length
			AssertEquals(Int(sent[i]), Int(received[i]))
		Next

		CloseSocket(server)
		CloseSocket(client)
		CloseSocket(listener)
	End Method

End Type
