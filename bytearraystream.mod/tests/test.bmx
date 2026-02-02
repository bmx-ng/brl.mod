SuperStrict

Framework brl.standardio
Import BRL.ByteArrayStream
Import BRL.MaxUnit

New TTestSuite.run()


Type TByteArrayStreamTest Extends TTest

	Method NewFromString_HasCorrectSizeAndReadsBack() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abc", True)

		AssertEquals(0, s.Pos(), "New stream should start at pos 0")
		AssertEquals(3, s.Size(), "Size should equal UTF-8 byte length for ASCII")

		Local buf:Byte[3]
		Local n:Long = s.Read(buf, 3)
		AssertEquals(3, n, "Read should return 3 bytes")
		AssertEquals(3, s.Pos(), "Pos should advance by bytes read")

		AssertEquals(Asc("a"), buf[0], "Byte 0 should be 'a'")
		AssertEquals(Asc("b"), buf[1], "Byte 1 should be 'b'")
		AssertEquals(Asc("c"), buf[2], "Byte 2 should be 'c'")
	End Method


	Method ReadAtEOF_ReturnsZeroAndDoesNotMovePos() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abc", True)

		s.Seek(0, SEEK_END_)
		AssertEquals(3, s.Pos(), "Seek end should put pos at size")

		Local buf:Byte[4]
		Local n:Long = s.Read(buf, 4)
		AssertEquals(0, n, "Read at EOF should return 0")
		AssertEquals(3, s.Pos(), "Pos should not move when reading 0 bytes")
	End Method


	Method SeekSet_ClampsForReadOnly() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abc", True)

		s.Seek(-10, SEEK_SET_)
		AssertEquals(0, s.Pos(), "SEEK_SET negative should clamp to 0")

		s.Seek(999, SEEK_SET_)
		AssertEquals(3, s.Pos(), "Read-only SEEK_SET past end should clamp to size")
	End Method

	Method SeekCur_ClampsForReadOnly() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abcd", True)

		s.Seek(2, SEEK_SET_)
		AssertEquals(2, s.Pos(), "Should be able to seek to 2")

		s.Seek(-99, SEEK_CUR_)
		AssertEquals(0, s.Pos(), "SEEK_CUR should not go below 0")

		s.Seek(999, SEEK_CUR_)
		AssertEquals(4, s.Pos(), "Read-only SEEK_CUR past end should clamp to size")
	End Method

	Method SeekEnd_RelativeToEnd() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abcdef", True)

		s.Seek(0, SEEK_END_)
		AssertEquals(6, s.Pos(), "SEEK_END +0 should be size")

		s.Seek(-2, SEEK_END_)
		AssertEquals(4, s.Pos(), "SEEK_END -2 should be size-2")

		s.Seek(-999, SEEK_END_)
		AssertEquals(0, s.Pos(), "SEEK_END too negative should clamp to 0")
	End Method

	Method WriteOverwritesAndAdvancesPos() { test }
		Local s:TByteArrayStream = New TByteArrayStream("hello", False) ' readOnly=False

		s.Seek(1, SEEK_SET_) ' h[1] = e
		Local x:Byte = Asc("a")
		Local n:Long = s.Write(Varptr x, 1)

		AssertEquals(1, n, "Write should report 1 byte written")
		AssertEquals(2, s.Pos(), "Pos should advance after write")
		AssertEquals(5, s.Size(), "Overwrite should not change size")

		s.Seek(0, SEEK_SET_)
		Local buf:Byte[5]
		s.Read(buf, 5)

		AssertEquals(Asc("h"), buf[0], "Byte 0 should be 'h'")
		AssertEquals(Asc("a"), buf[1], "Byte 1 should be overwritten to 'a'")
		AssertEquals(Asc("l"), buf[2], "Byte 2 should be 'l'")
		AssertEquals(Asc("l"), buf[3], "Byte 3 should be 'l'")
		AssertEquals(Asc("o"), buf[4], "Byte 4 should be 'o'")
	End Method

	Method WritePastEnd_GrowsStream() { test }
		Local s:TByteArrayStream = New TByteArrayStream("ab", False) ' writable

		s.Seek(0, SEEK_END_) ' pos = 2
		Local bytes:Byte[3]
		bytes[0] = Asc("c")
		bytes[1] = Asc("d")
		bytes[2] = Asc("e")

		Local n:Long = s.Write(bytes, 3)
		AssertEquals(3, n, "Write should write all bytes")
		AssertEquals(5, s.Size(), "Size should grow to fit new bytes")
		AssertEquals(5, s.Pos(), "Pos should end at new end")

		s.Seek(0, SEEK_SET_)
		Local buf:Byte[5]
		s.Read(buf, 5)

		AssertEquals(Asc("a"), buf[0], "Expected 'a'")
		AssertEquals(Asc("b"), buf[1], "Expected 'b'")
		AssertEquals(Asc("c"), buf[2], "Expected 'c'")
		AssertEquals(Asc("d"), buf[3], "Expected 'd'")
		AssertEquals(Asc("e"), buf[4], "Expected 'e'")
	End Method

	Method SeekPastEnd_ReadOnlyClampsButWritableAllows() { test }
		Local ro:TByteArrayStream = New TByteArrayStream("abc", True)
		ro.Seek(10, SEEK_SET_)
		AssertEquals(3, ro.Pos(), "Read-only seek past end should clamp")

		Local rw:TByteArrayStream = New TByteArrayStream("abc", False)
		rw.Seek(10, SEEK_SET_)
		AssertEquals(10, rw.Pos(), "Writable seek past end should be allowed")
		AssertEquals(3, rw.Size(), "Seek alone should not grow the stream")
	End Method

	Method SeekPastEndThenWrite_ZeroFillsGap() { test }
		Local s:TByteArrayStream = New TByteArrayStream("ab", False) ' writable

		s.Seek(5, SEEK_SET_) ' past end (size=2)
		Local z:Byte = Asc("Z")
		s.Write(Varptr z, 1) ' write at pos 5 => size should become 6

		AssertEquals(6, s.Size(), "Size should grow to pos+1")
		AssertEquals(6, s.Pos(), "Pos should advance after write")

		s.Seek(0, SEEK_SET_)
		Local buf:Byte[6]
		s.Read(buf, 6)

		AssertEquals(Asc("a"), buf[0], "Byte 0 should be 'a'")
		AssertEquals(Asc("b"), buf[1], "Byte 1 should be 'b'")

		' gap bytes [2..4] should be zero
		AssertEquals(0, buf[2], "Gap byte should be 0")
		AssertEquals(0, buf[3], "Gap byte should be 0")
		AssertEquals(0, buf[4], "Gap byte should be 0")

		AssertEquals(Asc("Z"), buf[5], "Written byte should be at the seeked position")
	End Method

	Method WriteOnReadOnlyStream_ReturnsZeroAndDoesNotChange() { test }
		Local s:TByteArrayStream = New TByteArrayStream("abc", True) ' readOnly=True

		s.Seek(1, SEEK_SET_)
		Local x:Byte = Asc("X")
		Local n:Long = s.Write(Varptr x, 1)

		AssertEquals(0, n, "Write on read-only should return 0")
		AssertEquals(1, s.Pos(), "Pos should not advance on failed write")
		AssertEquals(3, s.Size(), "Size should not change on failed write")

		s.Seek(0, SEEK_SET_)
		Local buf:Byte[3]
		s.Read(buf, 3)
		AssertEquals(Asc("a"), buf[0], "Data should remain unchanged")
		AssertEquals(Asc("b"), buf[1], "Data should remain unchanged")
		AssertEquals(Asc("c"), buf[2], "Data should remain unchanged")
	End Method

End Type

Type TByteArrayStreamCtorAndReadClampTest Extends TTest

	Function BytesFromASCII:Byte[](s:String)
		Local b:Byte[] = New Byte[s.Length]
		For Local i:Int = 0 Until s.Length
			b[i] = s[i] ' ASCII
		Next
		Return b
	End Function

	Method NewFromByteArray_CopyTrue_DoesNotAlias() { test }
		Local src:Byte[] = BytesFromASCII("abc")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, True) ' copy=True, readOnly=True

		' Mutate original array after stream construction
		src[0] = Asc("Z")

		' Stream should still read original "abc"
		Local buf:Byte[3]
		s.Seek(0, SEEK_SET_)
		Local n:Long = s.Read(buf, 3)

		AssertEquals(3, n, "Expected to read 3 bytes")
		AssertEquals(Asc("a"), buf[0], "copy=True should not see later mutations")
		AssertEquals(Asc("b"), buf[1], "copy=True should not see later mutations")
		AssertEquals(Asc("c"), buf[2], "copy=True should not see later mutations")
	End Method

	Method NewFromByteArray_CopyFalse_Aliases() { test }
		Local src:Byte[] = BytesFromASCII("abc")
		Local s:TByteArrayStream = New TByteArrayStream(src, False, True) ' copy=False, readOnly=True

		' Mutate original array after stream construction
		src[0] = Asc("Z")

		' Stream should see the mutation ("Zbc")
		Local buf:Byte[3]
		s.Seek(0, SEEK_SET_)
		Local n:Long = s.Read(buf, 3)

		AssertEquals(3, n, "Expected to read 3 bytes")
		AssertEquals(Asc("Z"), buf[0], "copy=False should alias and reflect mutations")
		AssertEquals(Asc("b"), buf[1], "Expected 'b'")
		AssertEquals(Asc("c"), buf[2], "Expected 'c'")
	End Method

	Method NewFromBytePtr_CopiesData() { test }
		Local src:Byte[] = BytesFromASCII("abcd")
		Local p:Byte Ptr = src

		Local s:TByteArrayStream = New TByteArrayStream(p, Size_T(src.Length), True) ' readOnly=True

		' Mutate original array after stream construction
		src[1] = Asc("X")

		' Stream should still contain original "abcd"
		Local buf:Byte[4]
		s.Seek(0, SEEK_SET_)
		Local n:Long = s.Read(buf, 4)

		AssertEquals(4, n, "Expected to read 4 bytes")
		AssertEquals(Asc("a"), buf[0], "Byte 0 should be 'a'")
		AssertEquals(Asc("b"), buf[1], "Byte Ptr ctor should copy (no alias)")
		AssertEquals(Asc("c"), buf[2], "Byte 2 should be 'c'")
		AssertEquals(Asc("d"), buf[3], "Byte 3 should be 'd'")
	End Method

	Method NewFromBytePtr_RespectsLength() { test }
		Local src:Byte[] = BytesFromASCII("abcdef")
		Local p:Byte Ptr = src

		Local s:TByteArrayStream = New TByteArrayStream(p, 3, True) ' copy only "abc"

		AssertEquals(3, s.Size(), "Size should match provided length")

		Local buf:Byte[6]
		s.Seek(0, SEEK_SET_)
		Local n:Long = s.Read(buf, 6) ' ask for more than available

		AssertEquals(3, n, "Read should clamp to available data")
		AssertEquals(Asc("a"), buf[0], "Expected 'a'")
		AssertEquals(Asc("b"), buf[1], "Expected 'b'")
		AssertEquals(Asc("c"), buf[2], "Expected 'c'")
	End Method

	Method Read_ClampsCountWhenPastEnd() { test }
		Local src:Byte[] = BytesFromASCII("abcd")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, True)

		s.Seek(2, SEEK_SET_) ' position at 'c'
		Local buf:Byte[10]

		Local n:Long = s.Read(buf, 10) ' ask for too much (only 2 remain)
		AssertEquals(2, n, "Read should clamp to remaining bytes")
		AssertEquals(4, s.Pos(), "Pos should advance to end")

		AssertEquals(Asc("c"), buf[0], "Expected 'c'")
		AssertEquals(Asc("d"), buf[1], "Expected 'd'")
	End Method

	Method Read_AtEndThenMore_ReturnsZero() { test }
		Local src:Byte[] = BytesFromASCII("ab")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, True)

		Local buf:Byte[4]

		Local n1:Long = s.Read(buf, 2)
		AssertEquals(2, n1, "Should read to end")
		AssertEquals(2, s.Pos(), "Pos should be at end")

		Local n2:Long = s.Read(buf, 2)
		AssertEquals(0, n2, "Further read should return 0 at EOF")
		AssertEquals(2, s.Pos(), "Pos should remain at end after EOF read")
	End Method

End Type

Type TByteArrayStreamSetSizeTest Extends TTest

	Function BytesFromASCII:Byte[](s:String)
		Local b:Byte[] = New Byte[s.Length]
		For Local i:Int = 0 Until s.Length
			b[i] = s[i] ' ASCII
		Next
		Return b
	End Function

	Method SetSize_ReadOnly_FailsAndDoesNotChange() { test }
		Local src:Byte[] = BytesFromASCII("abc")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, True) ' readOnly=True

		s.Seek(2, SEEK_SET_)

		Local ok:Int = s.SetSize(10)
		AssertFalse(ok, "SetSize should fail on read-only stream")
		AssertEquals(3, s.Size(), "Size should not change on failure")
		AssertEquals(2, s.Pos(), "Pos should not change on failure")

		ok = s.SetSize(-1)
		AssertFalse(ok, "SetSize should fail on negative size")
		AssertEquals(3, s.Size(), "Size should remain unchanged")
	End Method

	Method SetSize_Grow_IncreasesSize_AndPreservesPrefix() { test }
		Local src:Byte[] = BytesFromASCII("abc")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, False) ' writable

		Local ok:Int = s.SetSize(8)
		AssertTrue(ok, "SetSize should succeed when growing")
		AssertEquals(8, s.Size(), "Size should become 8")

		' Existing bytes should be preserved
		s.Seek(0, SEEK_SET_)
		Local buf:Byte[8]
		Local n:Long = s.Read(buf, 8)
		AssertEquals(8, n, "Should read full new size")

		AssertEquals(Asc("a"), buf[0], "Prefix should be preserved")
		AssertEquals(Asc("b"), buf[1], "Prefix should be preserved")
		AssertEquals(Asc("c"), buf[2], "Prefix should be preserved")

		' New region should be zeros (expected for file-like semantics)
		AssertEquals(0, buf[3], "New bytes should be zero-filled")
		AssertEquals(0, buf[4], "New bytes should be zero-filled")
		AssertEquals(0, buf[5], "New bytes should be zero-filled")
		AssertEquals(0, buf[6], "New bytes should be zero-filled")
		AssertEquals(0, buf[7], "New bytes should be zero-filled")
	End Method

	Method SetSize_Shrink_DecreasesSize_AndClampsPos() { test }
		Local src:Byte[] = BytesFromASCII("abcdef")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, False) ' writable

		s.Seek(5, SEEK_SET_)
		AssertEquals(5, s.Pos(), "Sanity: pos should be 5")

		Local ok:Int = s.SetSize(3)
		AssertTrue(ok, "SetSize should succeed when shrinking")
		AssertEquals(3, s.Size(), "Size should shrink to 3")
		AssertEquals(3, s.Pos(), "Pos should be clamped to new size")

		' Only first 3 bytes remain
		s.Seek(0, SEEK_SET_)
		Local buf:Byte[3]
		Local n:Long = s.Read(buf, 10) ' read clamp also exercised
		AssertEquals(3, n, "Read should clamp to 3")
		AssertEquals(Asc("a"), buf[0], "Expected 'a'")
		AssertEquals(Asc("b"), buf[1], "Expected 'b'")
		AssertEquals(Asc("c"), buf[2], "Expected 'c'")
	End Method

	Method SetSize_ShrinkThenGrow_DataPersistsInPrefixOnly() { test }
		Local src:Byte[] = BytesFromASCII("abcdef")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, False) ' writable

		' Shrink to 3 ("abc"), then grow back to 6: bytes beyond 3 should not magically return
		AssertTrue(s.SetSize(3), "Shrink should succeed")
		AssertEquals(3, s.Size(), "Should be size 3 after shrink")

		AssertTrue(s.SetSize(6), "Grow should succeed")
		AssertEquals(6, s.Size(), "Should be size 6 after regrow")

		s.Seek(0, SEEK_SET_)
		Local buf:Byte[6]
		Local n:Long = s.Read(buf, 6)
		AssertEquals(6, n, "Should read full regrown size")

		AssertEquals(Asc("a"), buf[0], "Prefix should remain")
		AssertEquals(Asc("b"), buf[1], "Prefix should remain")
		AssertEquals(Asc("c"), buf[2], "Prefix should remain")

		' These should now be zeros (or at least not the old 'def')
		AssertEquals(0, buf[3], "Regrown bytes should be zero-filled (old data discarded)")
		AssertEquals(0, buf[4], "Regrown bytes should be zero-filled (old data discarded)")
		AssertEquals(0, buf[5], "Regrown bytes should be zero-filled (old data discarded)")
	End Method

	Method SetSize_ClampPosWhenReducingBelowCurrentPos() { test }
		Local src:Byte[] = BytesFromASCII("abcd")
		Local s:TByteArrayStream = New TByteArrayStream(src, True, False) ' writable

		s.Seek(10, SEEK_SET_) ' allowed in writable mode
		AssertEquals(10, s.Pos(), "Sanity: pos should be beyond end")

		AssertTrue(s.SetSize(2), "SetSize should succeed")
		AssertEquals(2, s.Size(), "Size should now be 2")
		AssertEquals(2, s.Pos(), "Pos should clamp to new size")
	End Method

End Type
