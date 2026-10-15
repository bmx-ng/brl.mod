SuperStrict

Framework BRL.StandardIO
Import BRL.ByteBufferStream
Import BRL.MaxUnit

New TTestSuite.Run()

Type TByteBufferStreamTest Extends TTest

	Method CapturesRemainingWindowWithoutMovingSource() { test }
		Local bytes:Byte[] = [10, 20, 30, 40, 50, 60]
		Local source:TByteBuffer = TByteBuffer.Wrap(bytes)
		source.Position(2)
		source.Limit(5)

		Local stream:TByteBufferStream = CreateByteBufferStream(source)
		AssertEquals(0, stream.Pos())
		AssertEquals(3, stream.Size())

		Local result:Byte[3]
		AssertEquals(3, stream.Read(result, result.Length))
		AssertEquals(30, result[0] & $ff)
		AssertEquals(40, result[1] & $ff)
		AssertEquals(50, result[2] & $ff)
		AssertEquals(2, source.Position(), "Reading the stream must not move the source buffer")
		AssertEquals(5, source.Limit(), "The source limit must remain unchanged")
	End Method

	Method NestedSliceUsesItsOwnOffsets() { test }
		Local bytes:Byte[] = [0, 1, 2, 3, 4, 5, 6, 7]
		Local source:TByteBuffer = TByteBuffer.Wrap(bytes)
		source.Position(1)
		Local first:TByteBuffer = source.Slice(6)
		first.Position(2)
		first.Limit(5)

		Local stream:TByteBufferStream = CreateByteBufferStream(first)
		Local result:Byte[3]
		AssertEquals(3, stream.Read(result, result.Length))
		AssertEquals(3, result[0] & $ff)
		AssertEquals(4, result[1] & $ff)
		AssertEquals(5, result[2] & $ff)
		AssertEquals(2, first.Position(), "Reading must not move the sliced source")
	End Method

	Method SeekSupportsAllOriginsAndClampsToWindow() { test }
		Local stream:TByteBufferStream = CreateByteBufferStream(TByteBuffer.Allocate(5))
		AssertEquals(2, stream.Seek(2, SEEK_SET_))
		AssertEquals(4, stream.Seek(2, SEEK_CUR_))
		AssertEquals(3, stream.Seek(-2, SEEK_END_))
		AssertEquals(0, stream.Seek(-99, SEEK_SET_))
		AssertEquals(5, stream.Seek(99, SEEK_SET_))
		AssertEquals(-1, stream.Seek(0, 99))
		AssertEquals(5, stream.Pos(), "An invalid seek must not move the stream")
	End Method

	Method ReadStopsAtWindowEnd() { test }
		Local bytes:Byte[] = [1, 2, 3]
		Local stream:TByteBufferStream = CreateByteBufferStream(TByteBuffer.Wrap(bytes))
		stream.Seek(2)

		Local result:Byte[4]
		AssertEquals(1, stream.Read(result, result.Length))
		AssertEquals(3, result[0] & $ff)
		AssertEquals(0, stream.Read(result, result.Length))
		AssertEquals(3, stream.Pos())
	End Method

	Method WritableStreamSharesStorageAndStopsAtWindowEnd() { test }
		Local bytes:Byte[] = [10, 20, 30, 40, 50]
		Local source:TByteBuffer = TByteBuffer.Wrap(bytes)
		source.Position(1)
		source.Limit(4)
		Local stream:TByteBufferStream = CreateByteBufferStream(source, False)

		stream.Seek(1)
		Local replacement:Byte[] = [7, 8, 9]
		AssertEquals(2, stream.Write(replacement, replacement.Length))
		AssertEquals(10, bytes[0] & $ff)
		AssertEquals(20, bytes[1] & $ff)
		AssertEquals(7, bytes[2] & $ff)
		AssertEquals(8, bytes[3] & $ff)
		AssertEquals(50, bytes[4] & $ff)
		AssertEquals(0, stream.Write(replacement, replacement.Length))
		AssertEquals(1, source.Position(), "Writing must not move the source buffer")
	End Method

	Method ReadOnlyStreamRejectsWritesWithoutMoving() { test }
		Local bytes:Byte[] = [1, 2, 3]
		Local stream:TByteBufferStream = CreateByteBufferStream(TByteBuffer.Wrap(bytes))
		stream.Seek(1)
		Local replacement:Byte = 9

		AssertEquals(0, stream.Write(Varptr replacement, 1))
		AssertEquals(1, stream.Pos())
		AssertEquals(2, bytes[1] & $ff)
	End Method

	Method FixedSizeCannotBeResized() { test }
		Local stream:TByteBufferStream = CreateByteBufferStream(TByteBuffer.Allocate(4), False)
		AssertEquals(False, stream.SetSize(8))
		AssertEquals(4, stream.Size())
	End Method

	Method StreamFactoryOpensByteBuffersForReadingAndWriting() { test }
		Local bytes:Byte[] = [1, 2, 3]
		Local source:TByteBuffer = TByteBuffer.Wrap(bytes)
		Local input:TStream = ReadStream(source)
		AssertNotNull(input)
		AssertEquals(1, input.ReadByte() & $ff)

		Local output:TStream = WriteStream(source)
		AssertNotNull(output)
		output.WriteByte(9)
		AssertEquals(9, bytes[0] & $ff)
		AssertEquals(0, source.Position(), "Factory streams must have an independent position")
	End Method

End Type
