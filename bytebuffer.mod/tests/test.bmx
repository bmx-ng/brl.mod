SuperStrict

Framework brl.maxunit
Import brl.standardio
Import brl.bytebuffer

New TTestSuite.run()

Type TByteArrayBufferTest Extends TTest

	' -------------------------
	' Helpers
	' -------------------------
	Method MakeData:Byte[]()
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Return data
	End Method

	' -------------------------
	' State / base buffer rules
	' -------------------------
	Method State_ClearResetsState() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(5)

		buf.Put(Byte(1)).Put(Byte(2))
		buf.Clear()

		AssertEquals(0, buf.Position())
		AssertEquals(5, buf.Limit())
		AssertTrue(buf.HasRemaining())
	End Method

	Method State_FlipSetsLimitToPosition() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(10)

		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3))
		buf.Flip()

		AssertEquals(0, buf.Position())
		AssertEquals(3, buf.Limit())
	End Method

	Method State_MarkAndReset() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(5)

		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3))
		buf.Mark()
		buf.Put(Byte(4)).Put(Byte(5))

		buf.Reset()
		AssertEquals(3, buf.Position(), "Reset should restore position to mark")

		buf.Flip()
		AssertEquals(1, buf.Get())
		AssertEquals(2, buf.Get())
		AssertEquals(3, buf.Get())
	End Method

	' -------------------------
	' Get/Put basics + endian
	' -------------------------
	Method GetPut_ByteRoundTrip() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)

		buf.Put(Byte(10)).Put(Byte(20)).Put(Byte(30))
		AssertEquals(3, buf.Position(), "Position should advance on Put")

		buf.Flip()

		AssertEquals(10, buf.Get())
		AssertEquals(20, buf.Get())
		AssertEquals(30, buf.Get())
		AssertFalse(buf.HasRemaining(), "Buffer should be exhausted")
	End Method

	Method GetPut_IntBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.BigEndian)

		buf.PutInt($01020304)
		buf.Flip()

		AssertEquals($01020304, buf.GetInt())
	End Method

	Method GetPut_IntLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.LittleEndian)

		buf.PutInt($01020304)
		buf.Flip()

		AssertEquals($01020304, buf.GetInt())
	End Method

	' -------------------------
	' Slice semantics
	' -------------------------
	Method Slice_PutRespectsOffset() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(5)
		Local s:TByteBuffer = buf.Slice(3) ' window over data[5..7]

		AssertEquals(0, s.Position(), "Slice position should start at 0")
		AssertEquals(3, s.Limit(), "Slice limit should equal requested length")
		AssertEquals(5, s.Offset(), "Slice offset should be original offset + original position")

		s.Put(Byte(42))

		AssertEquals(5, buf.Position(), "Original buffer position should be unchanged by slice writes")
		AssertEquals(1, s.Position(), "Slice position should advance by 1 after Put()")

		AssertEquals(0, data[0], "Writing to slice must not affect data[0]")
		AssertEquals(42, data[5], "Writing to slice must write at the slice's offset (data[5])")
		AssertEquals(6, data[6], "Writing one byte should not clobber adjacent bytes")
	End Method

	Method Slice_SharesContentButNotState() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(3) ' window over [2,3,4]

		s.Put(Byte(99))
		AssertEquals(99, data[2], "Slice write should affect original array")

		AssertEquals(2, buf.Position(), "Slice should not affect original position")
		AssertEquals(1, s.Position(), "Slice position should advance independently")
	End Method

	Method Slice_HasIndependentPosition() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(5)

		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3)).Put(Byte(4)).Put(Byte(5))
		buf.Position(1)

		Local s:TByteBuffer = buf.Slice(2)

		AssertEquals(0, s.Position())
		AssertEquals(2, s.Limit())

		s.Get()
		AssertEquals(1, s.Position())
		AssertEquals(1, buf.Position(), "Original buffer position must remain unchanged")
	End Method

	Method Slice_NestedSliceRespectsWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)                     ' base at index 2
		Local s1:TByteBuffer = buf.Slice(5) ' covers [2..6]
		Local s2:TByteBuffer = s1.Slice(2, 2) ' covers [4..5]

		s2.Put(Byte(77))
		s2.Put(Byte(88))

		AssertEquals(77, data[4])
		AssertEquals(88, data[5])

		AssertEquals(2, s2.Position())
		AssertEquals(0, s1.Position(), "Parent slice position must remain unchanged")
		AssertEquals(2, buf.Position(), "Original buffer position must remain unchanged")
	End Method

	' -------------------------
	' Duplicate semantics
	' -------------------------
	Method Duplicate_CopiesStateButSharesData() { test }
		Local data:Byte[] = [1,2,3,4]
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local dup:TByteBuffer = buf.Duplicate()

		AssertEquals(2, dup.Position())
		AssertEquals(buf.Limit(), dup.Limit())

		dup.Put(Byte(99))
		AssertEquals(99, data[2], "Duplicate must share content")

		AssertEquals(2, buf.Position(), "Original position must be unchanged")
	End Method

	' -------------------------
	' Compact semantics
	' -------------------------
	Method Compact_MovesRemainingBytesToStart() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(6)

		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3))
		buf.Flip()
		buf.Get() ' consume 1

		buf.Compact()

		AssertEquals(2, buf.Position())
		AssertEquals(6, buf.Limit())

		buf.Flip()
		AssertEquals(2, buf.Get())
		AssertEquals(3, buf.Get())
	End Method

	' -------------------------
	' Get/Put primitives (Short/UInt/Long/ULong/Size_T/Float/Double)
	' -------------------------

	Method GetPut_ShortBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		buf.Order(EByteOrder.BigEndian)

		Local v:Short = Short($1234)
		buf.PutShort(v)
		buf.Flip()

		AssertEquals(v, buf.GetShort())
	End Method

	Method GetPut_ShortLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Short = Short($1234)
		buf.PutShort(v)
		buf.Flip()

		AssertEquals(v, buf.GetShort())
	End Method

	Method GetPut_UIntBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.BigEndian)

		Local v:UInt = $89ABCDEF:UInt
		buf.PutUInt(v)
		buf.Flip()

		AssertEquals(v, buf.GetUInt())
	End Method

	Method GetPut_UIntLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.LittleEndian)

		Local v:UInt = $89ABCDEF:UInt
		buf.PutUInt(v)
		buf.Flip()

		AssertEquals(v, buf.GetUInt())
	End Method

	Method GetPut_LongBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.BigEndian)

		Local v:Long = $0123456789ABCDEF:Long
		buf.PutLong(v)
		buf.Flip()

		AssertEquals(v, buf.GetLong())
	End Method

	Method GetPut_LongLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Long = $0123456789ABCDEF:Long
		buf.PutLong(v)
		buf.Flip()

		AssertEquals(v, buf.GetLong())
	End Method

	Method GetPut_ULongBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.BigEndian)

		Local v:ULong = $FEDCBA9876543210:ULong
		buf.PutULong(v)
		buf.Flip()

		AssertEquals(v, buf.GetULong())
	End Method

	Method GetPut_ULongLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.LittleEndian)

		Local v:ULong = $FEDCBA9876543210:ULong
		buf.PutULong(v)
		buf.Flip()

		AssertEquals(v, buf.GetULong())
	End Method

	Method GetPut_SizeTRoundTrip() { test }
?ptr64
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
?Not ptr64
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
?
		' Use a value that is representable on both, but still non-trivial.
		Local v:Size_T = Size_T(123456789)

		buf.PutSizeT(v)
		buf.Flip()

		AssertEquals(v, buf.GetSizeT())
	End Method

	Method GetPut_FloatRoundTrip() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)

		Local v:Float = 1234.5
		buf.PutFloat(v)
		buf.Flip()

		AssertEquals(v, buf.GetFloat())
	End Method

	Method GetPut_DoubleRoundTrip() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)

		Local v:Double = 12345678.125
		buf.PutDouble(v)
		buf.Flip()

		AssertEquals(v, buf.GetDouble())
	End Method


	' -------------------------
	' Get/Put floats/doubles under both byte orders
	' -------------------------

	Method GetPut_FloatBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.BigEndian)

		Local v:Float = 1234.5
		buf.PutFloat(v)
		buf.Flip()

		AssertEquals(v, buf.GetFloat())
	End Method

	Method GetPut_FloatLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Float = 1234.5
		buf.PutFloat(v)
		buf.Flip()

		AssertEquals(v, buf.GetFloat())
	End Method

	Method GetPut_DoubleBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.BigEndian)

		Local v:Double = 12345678.125
		buf.PutDouble(v)
		buf.Flip()

		AssertEquals(v, buf.GetDouble())
	End Method

	Method GetPut_DoubleLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Double = 12345678.125
		buf.PutDouble(v)
		buf.Flip()

		AssertEquals(v, buf.GetDouble())
	End Method


	' -------------------------
	' Negative values for signed primitives
	' -------------------------

	Method GetPut_ShortNegativeBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		buf.Order(EByteOrder.BigEndian)

		Local v:Short = Short(-12345)
		buf.PutShort(v)
		buf.Flip()

		AssertEquals(v, buf.GetShort())
	End Method

	Method GetPut_ShortNegativeLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Short = Short(-12345)
		buf.PutShort(v)
		buf.Flip()

		AssertEquals(v, buf.GetShort())
	End Method

	Method GetPut_IntNegativeBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.BigEndian)

		Local v:Int = -123456789
		buf.PutInt(v)
		buf.Flip()

		AssertEquals(v, buf.GetInt())
	End Method

	Method GetPut_IntNegativeLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(4)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Int = -123456789
		buf.PutInt(v)
		buf.Flip()

		AssertEquals(v, buf.GetInt())
	End Method

	Method GetPut_LongNegativeBigEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.BigEndian)

		Local v:Long = -123456789012345:Long
		buf.PutLong(v)
		buf.Flip()

		AssertEquals(v, buf.GetLong())
	End Method

	Method GetPut_LongNegativeLittleEndian() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(8)
		buf.Order(EByteOrder.LittleEndian)

		Local v:Long = -123456789012345:Long
		buf.PutLong(v)
		buf.Flip()

		AssertEquals(v, buf.GetLong())
	End Method


	' -------------------------
	' Bulk PutBytes / GetBytes
	' -------------------------

	Method Bytes_PutBytesThenGetBytesRoundTrip() { test }
		Local src:Byte[] = [10,20,30,40,50,60]
		Local buf:TByteBuffer = TByteBuffer.Allocate(src.length)

		buf.PutBytes(src, UInt(src.length))
		AssertEquals(src.length, buf.Position(), "Position should advance by length")

		buf.Flip()

		Local dst:Byte[] = New Byte[src.length]
		buf.GetBytes(dst, UInt(dst.length))

		For Local i:Int = 0 Until src.length
			AssertEquals(src[i], dst[i], "Byte mismatch at index " + i)
		Next
	End Method

	Method Bytes_GetBytesRespectsOffsetInSlice() { test }
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(3) ' slice window begins at data[3]
		Local s:TByteBuffer = buf.Slice(4) ' covers [3,4,5,6]

		Local dst:Byte[] = New Byte[4]
		s.GetBytes(dst, UInt(dst.length))

		AssertEquals(3, dst[0])
		AssertEquals(4, dst[1])
		AssertEquals(5, dst[2])
		AssertEquals(6, dst[3])

		AssertEquals(4, s.Position(), "Slice position should advance by GetBytes length")
		AssertEquals(3, buf.Position(), "Original position should remain unchanged")
	End Method

	Method Bytes_PutBytesRespectsOffsetInSlice() { test }
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(4) ' slice begins at data[4]
		Local s:TByteBuffer = buf.Slice(3) ' covers [4,5,6]

		Local src:Byte[] = [99,98,97]
		s.PutBytes(src, UInt(src.length))

		AssertEquals(99, data[4])
		AssertEquals(98, data[5])
		AssertEquals(97, data[6])

		AssertEquals(3, s.Position(), "Slice position should advance by PutBytes length")
		AssertEquals(4, buf.Position(), "Original buffer position should remain unchanged")
	End Method

	' -------------------------
	' Slice API coverage
	' -------------------------

	Method Slice_NoArgCoversRemainingWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(3) ' remaining window should be data[3..9] (7 bytes)
		Local s:TByteBuffer = buf.Slice()

		AssertEquals(0, s.Position())
		AssertEquals(7, s.Limit())
		AssertEquals(7, s.Remaining())
		AssertEquals(3, s.Offset(), "Slice offset should match original position")

		' Confirm window maps correctly
		AssertEquals(3, s.Get())
		AssertEquals(4, s.Get())
		AssertEquals(2, s.Position())
		AssertEquals(3, buf.Position(), "Original state must be independent")
	End Method

	Method Slice_LengthCreatesExactWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(4) ' data[2..5]

		AssertEquals(4, s.Limit())
		AssertEquals(2, s.Offset())
		AssertEquals(2, s.Get())
		AssertEquals(3, s.Get())
		AssertEquals(4, s.Get())
		AssertEquals(5, s.Get())
		AssertFalse(s.HasRemaining(), "Slice(length) should end exactly at limit")
	End Method

	Method Slice_StartLengthSelectsSubWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(1) ' remaining is [1..9]
		Local s:TByteBuffer = buf.Slice(3, 4) ' start 3 into remaining => data[4..7]

		AssertEquals(0, s.Position())
		AssertEquals(4, s.Limit())
		AssertEquals(1 + 3, s.Offset(), "Offset should be base offset + position + start")

		AssertEquals(4, s.Get())
		AssertEquals(5, s.Get())
		AssertEquals(6, s.Get())
		AssertEquals(7, s.Get())
	End Method

	Method SliceFrom_StartSelectsTailWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(1) ' remaining is [1..9] length 9
		Local s:TByteBuffer = buf.SliceFrom(6) ' skip 6 of remaining => data[7..9] (3 bytes)

		AssertEquals(0, s.Position())
		AssertEquals(3, s.Limit())
		AssertEquals(1 + 6, s.Offset())

		AssertEquals(7, s.Get())
		AssertEquals(8, s.Get())
		AssertEquals(9, s.Get())
	End Method

	Method Slice_WindowIsWriteableAndShared() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(6)
		Local s:TByteBuffer = buf.Slice(2) ' data[6..7]

		s.Put(Byte(55))
		s.Put(Byte(56))

		AssertEquals(55, data[6])
		AssertEquals(56, data[7])
		AssertEquals(2, s.Position())
		AssertEquals(6, buf.Position(), "Original position must remain unchanged")
	End Method

	Method Slice_MarkResetIndependence() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(5) ' data[2..6]

		s.Get() ' consumes data[2]
		s.Mark()
		s.Get() ' consumes data[3]
		s.Get() ' consumes data[4]
		s.Reset()

		AssertEquals(1, s.Position(), "Reset should restore to mark within slice")
		AssertEquals(2, buf.Position(), "Original buffer state must remain independent")
	End Method

	Method Slice_OfSlice_UsingNoArg() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local s1:TByteBuffer = buf.Slice(6) ' data[2..7]
		s1.Position(2) ' now pointing at data[4]
		Local s2:TByteBuffer = s1.Slice() ' remaining in s1 => data[4..7]

		AssertEquals(4, s2.Offset(), "Nested slice should include both offsets/positions")
		AssertEquals(0, s2.Position())
		AssertEquals(4, s2.Limit())

		AssertEquals(4, s2.Get())
		AssertEquals(5, s2.Get())
		AssertEquals(6, s2.Get())
		AssertEquals(7, s2.Get())
	End Method

	Method Slice_OfSlice_UsingLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(1)
		Local s1:TByteBuffer = buf.Slice(7) ' data[1..7]
		s1.Position(3) ' points at data[4]
		Local s2:TByteBuffer = s1.Slice(2) ' data[4..5]

		AssertEquals(4, s2.Offset())
		AssertEquals(2, s2.Limit())

		s2.Put(Byte(90))
		s2.Put(Byte(91))

		AssertEquals(90, data[4])
		AssertEquals(91, data[5])
	End Method

	Method Slice_OfSlice_UsingStartLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(0)
		Local s1:TByteBuffer = buf.Slice(8) ' data[0..7]
		Local s2:TByteBuffer = s1.Slice(3, 3) ' data[3..5]

		AssertEquals(3, s2.Offset())
		AssertEquals(3, s2.Limit())

		AssertEquals(3, s2.Get())
		AssertEquals(4, s2.Get())
		AssertEquals(5, s2.Get())
	End Method

	Method Slice_OfSlice_UsingSliceFrom() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(2)
		Local s1:TByteBuffer = buf.Slice(7) ' data[2..8]
		Local s2:TByteBuffer = s1.SliceFrom(4) ' data[6..8]

		AssertEquals(6, s2.Offset())
		AssertEquals(3, s2.Limit())

		AssertEquals(6, s2.Get())
		AssertEquals(7, s2.Get())
		AssertEquals(8, s2.Get())
	End Method

	' -------------------------
	' Byte order propagation (expected to be inherited by views/copies)
	' -------------------------

	Method Order_DuplicatePreservesOrder() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Order(EByteOrder.LittleEndian)
		Local dup:TByteBuffer = buf.Duplicate()

		AssertEquals(EByteOrder.LittleEndian.Ordinal(), dup.Order().Ordinal(), "Duplicate should preserve byte order")
	End Method

	Method Order_SlicesPreserveOrder_AllVariants() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)
		buf.Order(EByteOrder.LittleEndian)

		buf.Position(2)

		Local s0:TByteBuffer = buf.Slice()
		Local s1:TByteBuffer = buf.Slice(3)
		Local s2:TByteBuffer = buf.Slice(1, 2)
		Local s3:TByteBuffer = buf.SliceFrom(1)

		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s0.Order().Ordinal(), "Slice() should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s1.Order().Ordinal(), "Slice(length) should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s2.Order().Ordinal(), "Slice(start,length) should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s3.Order().Ordinal(), "SliceFrom(start) should preserve byte order")

		' Nested slice also preserves
		Local nested:TByteBuffer = s1.Slice(1)
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), nested.Order().Ordinal(), "Slice-of-slice should preserve byte order")
	End Method

	' -------------------------
	' Exceptions: Underflow
	' -------------------------

	Method Exception_Underflow_GetByte() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(1)
		buf.Put(Byte(123)).Flip()

		AssertEquals(123, buf.Get())
		Try
			buf.Get()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetInt() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(3)
		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3)).Flip()

		Try
			buf.GetInt()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetBytes() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		buf.Put(Byte(1)).Put(Byte(2)).Flip()

		Local dst:Byte[] = New Byte[3]
		Try
			buf.GetBytes(dst, UInt(dst.length))
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetShort() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(1)
		buf.Put(Byte(1)).Flip()

		Try
			buf.GetShort()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetUInt() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(3)
		buf.Put(Byte(1)).Put(Byte(2)).Put(Byte(3)).Flip()

		Try
			buf.GetUInt()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetLong() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(7)
		For Local i:Int = 0 Until 7
			buf.Put(Byte(i + 1))
		Next
		buf.Flip()

		Try
			buf.GetLong()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Underflow_GetULong() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(7)
		For Local i:Int = 0 Until 7
			buf.Put(Byte(i + 1))
		Next
		buf.Flip()

		Try
			buf.GetULong()
			AssertTrue(False, "Expected TBufferUnderflowException")
		Catch e:TBufferUnderflowException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Overflow (writes)
	' -------------------------

	Method Exception_Overflow_PutByte() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(1)

		buf.Put(Byte(1))
		Try
			buf.Put(Byte(2))
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutBytes() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		Local src:Byte[] = [1,2,3]

		Try
			buf.PutBytes(src, UInt(src.length))
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method


	' -------------------------
	' Exceptions: Slice argument validation
	' -------------------------

	Method Exception_Overflow_SliceLengthTooBig() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(8) ' remaining=2
		Try
			buf.Slice(3)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceStartLengthOutOfRange() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(5) ' remaining=5
		Try
			buf.Slice(4, 2) ' start+length = 6 > remaining (5)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceFromStartOutOfRange() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		buf.Position(5) ' remaining=5
		Try
			buf.SliceFrom(6) ' start > remaining
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method


	' -------------------------
	' Exceptions: Read-only
	' -------------------------

	Method ReadOnly_AsReadOnlyPreventsWrites() { test }
		Local data:Byte[] = [1,2,3,4]
		Local buf:TByteBuffer = New TByteArrayBuffer(data)

		Local ro:TByteBuffer = buf.AsReadOnly()

		AssertEquals(buf.Position(), ro.Position())
		AssertEquals(buf.Limit(), ro.Limit())
		AssertEquals(buf.Order().Ordinal(), ro.Order().Ordinal())

		Try
			ro.Put(Byte(9))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method ReadOnly_SliceIsStillReadOnly() { test }
		Local data:Byte[] = [1,2,3,4]
		Local ro:TByteBuffer = New TByteArrayBuffer(data).AsReadOnly()

		Local s:TByteBuffer = ro.Slice(2)

		Try
			s.Put(Byte(9))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Read-only (Put* / PutBytes)
	' -------------------------

	Method Exception_ReadOnly_PutByte() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.Put(Byte(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutShort() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutShort(Short(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutInt() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutInt(1)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutUInt() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutUInt(1:UInt)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutLong() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutLong(1:Long)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutULong() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutULong(1:ULong)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutSizeT() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutSizeT(Size_T(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutFloat() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutFloat(1.25:Float)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutDouble() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Try
			ro.PutDouble(1.25:Double)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutBytes() { test }
		Local ro:TByteBuffer = New TByteArrayBuffer(MakeData(), True)
		Local src:Byte[] = [1,2,3]

		Try
			ro.PutBytes(src, UInt(src.length))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Overflow (Put* / PutBytes)
	' -------------------------

	Method Exception_Overflow_PutShort() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(1)
		Try
			buf.PutShort(Short(1))
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutInt() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(3)
		Try
			buf.PutInt(1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutUInt() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(3)
		Try
			buf.PutUInt(1:UInt)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutLong() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(7)
		Try
			buf.PutLong(1:Long)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutULong() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(7)
		Try
			buf.PutULong(1:ULong)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutFloat() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(3)
		Try
			buf.PutFloat(1.0:Float)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutDouble() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(7)
		Try
			buf.PutDouble(1.0:Double)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_PutBytesExact() { test }
		Local buf:TByteBuffer = TByteBuffer.Allocate(2)
		Local src:Byte[] = [1,2,3]
		Try
			buf.PutBytes(src, UInt(src.length))
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Overflow (Slice* negative args)
	' -------------------------

	Method Exception_Overflow_SliceNegativeLength() { test }
		Local buf:TByteBuffer = New TByteArrayBuffer(MakeData())
		Try
			buf.Slice(-1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceNegativeStart() { test }
		Local buf:TByteBuffer = New TByteArrayBuffer(MakeData())
		Try
			buf.Slice(-1, 1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceNegativeStartOrLength() { test }
		Local buf:TByteBuffer = New TByteArrayBuffer(MakeData())
		Try
			buf.Slice(1, -1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceFromNegativeStart() { test }
		Local buf:TByteBuffer = New TByteArrayBuffer(MakeData())
		Try
			buf.SliceFrom(-1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method
End Type

Type TBytePtrBufferTest Extends TTest

	' -------------------------
	' Helpers
	' -------------------------
	Method MakeData:Byte[]()
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Return data
	End Method

	' -------------------------
	' Slice semantics
	' -------------------------
	Method Slice_PutRespectsOffset() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(5)
		Local s:TByteBuffer = buf.Slice(3) ' window over data[5..7]

		AssertEquals(0, s.Position(), "Slice position should start at 0")
		AssertEquals(3, s.Limit(), "Slice limit should equal requested length")
		AssertEquals(5, s.Offset(), "Slice offset should be original offset + original position")

		s.Put(Byte(42))

		AssertEquals(5, buf.Position(), "Original buffer position should be unchanged by slice writes")
		AssertEquals(1, s.Position(), "Slice position should advance by 1 after Put()")

		AssertEquals(0, data[0], "Writing to slice must not affect data[0]")
		AssertEquals(42, data[5], "Writing to slice must write at the slice's offset (data[5])")
		AssertEquals(6, data[6], "Writing one byte should not clobber adjacent bytes")
	End Method

	Method Slice_SharesContentButNotState() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(3) ' window over [2,3,4]

		s.Put(Byte(99))
		AssertEquals(99, data[2], "Slice write should affect original array")

		AssertEquals(2, buf.Position(), "Slice should not affect original position")
		AssertEquals(1, s.Position(), "Slice position should advance independently")
	End Method
	
	Method Slice_NestedSliceRespectsWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)                     ' base at index 2
		Local s1:TByteBuffer = buf.Slice(5) ' covers [2..6]
		Local s2:TByteBuffer = s1.Slice(2, 2) ' covers [4..5]

		s2.Put(Byte(77))
		s2.Put(Byte(88))

		AssertEquals(77, data[4])
		AssertEquals(88, data[5])

		AssertEquals(2, s2.Position())
		AssertEquals(0, s1.Position(), "Parent slice position must remain unchanged")
		AssertEquals(2, buf.Position(), "Original buffer position must remain unchanged")
	End Method

	' -------------------------
	' Duplicate semantics
	' -------------------------
	Method Duplicate_CopiesStateButSharesData() { test }
		Local data:Byte[] = [1,2,3,4]
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local dup:TByteBuffer = buf.Duplicate()

		AssertEquals(2, dup.Position())
		AssertEquals(buf.Limit(), dup.Limit())

		dup.Put(Byte(99))
		AssertEquals(99, data[2], "Duplicate must share content")

		AssertEquals(2, buf.Position(), "Original position must be unchanged")
	End Method

	' -------------------------
	' Bulk PutBytes / GetBytes
	' -------------------------

	Method Bytes_GetBytesRespectsOffsetInSlice() { test }
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(3) ' slice window begins at data[3]
		Local s:TByteBuffer = buf.Slice(4) ' covers [3,4,5,6]

		Local dst:Byte[] = New Byte[4]
		s.GetBytes(dst, UInt(dst.length))

		AssertEquals(3, dst[0])
		AssertEquals(4, dst[1])
		AssertEquals(5, dst[2])
		AssertEquals(6, dst[3])

		AssertEquals(4, s.Position(), "Slice position should advance by GetBytes length")
		AssertEquals(3, buf.Position(), "Original position should remain unchanged")
	End Method

	Method Bytes_PutBytesRespectsOffsetInSlice() { test }
		Local data:Byte[] = [0,1,2,3,4,5,6,7,8,9]
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(4) ' slice begins at data[4]
		Local s:TByteBuffer = buf.Slice(3) ' covers [4,5,6]

		Local src:Byte[] = [99,98,97]
		s.PutBytes(src, UInt(src.length))

		AssertEquals(99, data[4])
		AssertEquals(98, data[5])
		AssertEquals(97, data[6])

		AssertEquals(3, s.Position(), "Slice position should advance by PutBytes length")
		AssertEquals(4, buf.Position(), "Original buffer position should remain unchanged")
	End Method

	' -------------------------
	' Slice API coverage
	' -------------------------

	Method Slice_NoArgCoversRemainingWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(3) ' remaining window should be data[3..9] (7 bytes)
		Local s:TByteBuffer = buf.Slice()

		AssertEquals(0, s.Position())
		AssertEquals(7, s.Limit())
		AssertEquals(7, s.Remaining())
		AssertEquals(3, s.Offset(), "Slice offset should match original position")

		' Confirm window maps correctly
		AssertEquals(3, s.Get())
		AssertEquals(4, s.Get())
		AssertEquals(2, s.Position())
		AssertEquals(3, buf.Position(), "Original state must be independent")
	End Method

	Method Slice_LengthCreatesExactWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(4) ' data[2..5]

		AssertEquals(4, s.Limit())
		AssertEquals(2, s.Offset())
		AssertEquals(2, s.Get())
		AssertEquals(3, s.Get())
		AssertEquals(4, s.Get())
		AssertEquals(5, s.Get())
		AssertFalse(s.HasRemaining(), "Slice(length) should end exactly at limit")
	End Method

	Method Slice_StartLengthSelectsSubWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(1) ' remaining is [1..9]
		Local s:TByteBuffer = buf.Slice(3, 4) ' start 3 into remaining => data[4..7]

		AssertEquals(0, s.Position())
		AssertEquals(4, s.Limit())
		AssertEquals(1 + 3, s.Offset(), "Offset should be base offset + position + start")

		AssertEquals(4, s.Get())
		AssertEquals(5, s.Get())
		AssertEquals(6, s.Get())
		AssertEquals(7, s.Get())
	End Method

	Method SliceFrom_StartSelectsTailWindow() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(1) ' remaining is [1..9] length 9
		Local s:TByteBuffer = buf.SliceFrom(6) ' skip 6 of remaining => data[7..9] (3 bytes)

		AssertEquals(0, s.Position())
		AssertEquals(3, s.Limit())
		AssertEquals(1 + 6, s.Offset())

		AssertEquals(7, s.Get())
		AssertEquals(8, s.Get())
		AssertEquals(9, s.Get())
	End Method

	Method Slice_WindowIsWriteableAndShared() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(6)
		Local s:TByteBuffer = buf.Slice(2) ' data[6..7]

		s.Put(Byte(55))
		s.Put(Byte(56))

		AssertEquals(55, data[6])
		AssertEquals(56, data[7])
		AssertEquals(2, s.Position())
		AssertEquals(6, buf.Position(), "Original position must remain unchanged")
	End Method

	Method Slice_MarkResetIndependence() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local s:TByteBuffer = buf.Slice(5) ' data[2..6]

		s.Get() ' consumes data[2]
		s.Mark()
		s.Get() ' consumes data[3]
		s.Get() ' consumes data[4]
		s.Reset()

		AssertEquals(1, s.Position(), "Reset should restore to mark within slice")
		AssertEquals(2, buf.Position(), "Original buffer state must remain independent")
	End Method

	Method Slice_OfSlice_UsingNoArg() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local s1:TByteBuffer = buf.Slice(6) ' data[2..7]
		s1.Position(2) ' now pointing at data[4]
		Local s2:TByteBuffer = s1.Slice() ' remaining in s1 => data[4..7]

		AssertEquals(4, s2.Offset(), "Nested slice should include both offsets/positions")
		AssertEquals(0, s2.Position())
		AssertEquals(4, s2.Limit())

		AssertEquals(4, s2.Get())
		AssertEquals(5, s2.Get())
		AssertEquals(6, s2.Get())
		AssertEquals(7, s2.Get())
	End Method

	Method Slice_OfSlice_UsingLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(1)
		Local s1:TByteBuffer = buf.Slice(7) ' data[1..7]
		s1.Position(3) ' points at data[4]
		Local s2:TByteBuffer = s1.Slice(2) ' data[4..5]

		AssertEquals(4, s2.Offset())
		AssertEquals(2, s2.Limit())

		s2.Put(Byte(90))
		s2.Put(Byte(91))

		AssertEquals(90, data[4])
		AssertEquals(91, data[5])
	End Method

	Method Slice_OfSlice_UsingStartLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(0)
		Local s1:TByteBuffer = buf.Slice(8) ' data[0..7]
		Local s2:TByteBuffer = s1.Slice(3, 3) ' data[3..5]

		AssertEquals(3, s2.Offset())
		AssertEquals(3, s2.Limit())

		AssertEquals(3, s2.Get())
		AssertEquals(4, s2.Get())
		AssertEquals(5, s2.Get())
	End Method

	Method Slice_OfSlice_UsingSliceFrom() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(2)
		Local s1:TByteBuffer = buf.Slice(7) ' data[2..8]
		Local s2:TByteBuffer = s1.SliceFrom(4) ' data[6..8]

		AssertEquals(6, s2.Offset())
		AssertEquals(3, s2.Limit())

		AssertEquals(6, s2.Get())
		AssertEquals(7, s2.Get())
		AssertEquals(8, s2.Get())
	End Method

	' -------------------------
	' Byte order propagation (expected to be inherited by views/copies)
	' -------------------------

	Method Order_DuplicatePreservesOrder() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Order(EByteOrder.LittleEndian)
		Local dup:TByteBuffer = buf.Duplicate()

		AssertEquals(EByteOrder.LittleEndian.Ordinal(), dup.Order().Ordinal(), "Duplicate should preserve byte order")
	End Method

	Method Order_SlicesPreserveOrder_AllVariants() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)
		buf.Order(EByteOrder.LittleEndian)

		buf.Position(2)

		Local s0:TByteBuffer = buf.Slice()
		Local s1:TByteBuffer = buf.Slice(3)
		Local s2:TByteBuffer = buf.Slice(1, 2)
		Local s3:TByteBuffer = buf.SliceFrom(1)

		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s0.Order().Ordinal(), "Slice() should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s1.Order().Ordinal(), "Slice(length) should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s2.Order().Ordinal(), "Slice(start,length) should preserve byte order")
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), s3.Order().Ordinal(), "SliceFrom(start) should preserve byte order")

		' Nested slice also preserves
		Local nested:TByteBuffer = s1.Slice(1)
		AssertEquals(EByteOrder.LittleEndian.Ordinal(), nested.Order().Ordinal(), "Slice-of-slice should preserve byte order")
	End Method

	' -------------------------
	' Exceptions: Slice argument validation
	' -------------------------

	Method Exception_Overflow_SliceLengthTooBig() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(8) ' remaining=2
		Try
			buf.Slice(3)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceStartLengthOutOfRange() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(5) ' remaining=5
		Try
			buf.Slice(4, 2) ' start+length = 6 > remaining (5)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceFromStartOutOfRange() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		buf.Position(5) ' remaining=5
		Try
			buf.SliceFrom(6) ' start > remaining
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method


	' -------------------------
	' Exceptions: Read-only
	' -------------------------

	Method ReadOnly_AsReadOnlyPreventsWrites() { test }
		Local data:Byte[] = [1,2,3,4]
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)

		Local ro:TByteBuffer = buf.AsReadOnly()

		AssertEquals(buf.Position(), ro.Position())
		AssertEquals(buf.Limit(), ro.Limit())
		AssertEquals(buf.Order().Ordinal(), ro.Order().Ordinal())

		Try
			ro.Put(Byte(9))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method ReadOnly_SliceIsStillReadOnly() { test }
		Local data:Byte[] = [1,2,3,4]
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length).AsReadOnly()

		Local s:TByteBuffer = ro.Slice(2)

		Try
			s.Put(Byte(9))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Read-only (Put* / PutBytes)
	' -------------------------

	Method Exception_ReadOnly_PutByte() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.Put(Byte(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutShort() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutShort(Short(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutInt() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutInt(1)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutUInt() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutUInt(1:UInt)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutLong() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutLong(1:Long)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutULong() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutULong(1:ULong)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutSizeT() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutSizeT(Size_T(1))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutFloat() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutFloat(1.25:Float)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutDouble() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Try
			ro.PutDouble(1.25:Double)
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_ReadOnly_PutBytes() { test }
		Local data:Byte[] = MakeData()
		Local ro:TByteBuffer = New TBytePtrBuffer(data, data.Length, 0, True)
		Local src:Byte[] = [1,2,3]

		Try
			ro.PutBytes(src, UInt(src.length))
			AssertTrue(False, "Expected TReadOnlyBufferException")
		Catch e:TReadOnlyBufferException
			AssertTrue(True)
		End Try
	End Method

	' -------------------------
	' Exceptions: Overflow (Slice* negative args)
	' -------------------------

	Method Exception_Overflow_SliceNegativeLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)
		Try
			buf.Slice(-1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceNegativeStart() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)
		Try
			buf.Slice(-1, 1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceNegativeStartOrLength() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)
		Try
			buf.Slice(1, -1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method

	Method Exception_Overflow_SliceFromNegativeStart() { test }
		Local data:Byte[] = MakeData()
		Local buf:TByteBuffer = New TBytePtrBuffer(data, data.Length)
		Try
			buf.SliceFrom(-1)
			AssertTrue(False, "Expected TBufferOverflowException")
		Catch e:TBufferOverflowException
			AssertTrue(True)
		End Try
	End Method
End Type
