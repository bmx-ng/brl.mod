SuperStrict

Framework brl.standardio
Import brl.FileSystem
Import BRL.MaxUnit

New TTestSuite.run()

Type TWalkTreeTest Extends TTest

	Field root:String

	Method SetupTree()
		root = _MakeUniqueRoot()
		AssertTrue(_EnsureDir(root), "Failed to create root test directory: " + root)

		' Tree:
		' root/
		'   a.txt
		'   b.txt
		'   sub/
		'     c.txt
		'     deeper/
		'       d.txt
		AssertTrue(_WriteSmallFile(root + "/a.txt", "A"), "Failed to create a.txt")
		AssertTrue(_WriteSmallFile(root + "/b.txt", "B"), "Failed to create b.txt")
		AssertTrue(_EnsureDir(root + "/sub"), "Failed to create sub dir")
		AssertTrue(_WriteSmallFile(root + "/sub/c.txt", "C"), "Failed to create c.txt")
		AssertTrue(_EnsureDir(root + "/sub/deeper"), "Failed to create deeper dir")
		AssertTrue(_WriteSmallFile(root + "/sub/deeper/d.txt", "D"), "Failed to create d.txt")
	End Method

	Method CleanupTree()
		If root And FileType(root) = FILETYPE_DIR Then
			DeleteDir(root, True)
		End If
	End Method

	Method Before() { before }
		SetupTree()
	End Method

	Method After() { after }
		CleanupTree()
	End Method


	' Depth should be meaningful (root=0, children=1, grandchildren=2)
	Method DepthIsReported() { test }
		Local w:TCollectWalker = New TCollectWalker
		WalkFileTree(root, w, EFileWalkOption.None, 0)

		' We expect at least these nodes to have been seen.
		AssertTrue(w.HasName("a.txt"), "Expected to see a.txt")
		AssertTrue(w.HasName("sub"), "Expected to see sub directory")
		AssertTrue(w.HasName("c.txt"), "Expected to see c.txt")
		AssertTrue(w.HasName("d.txt"), "Expected to see d.txt")

		' Depth expectations:
		' - "sub" should be depth 1
		' - "c.txt" should be depth 2 (root/sub/c.txt)
		' - "d.txt" should be depth 3 (root/sub/deeper/d.txt)
		Local subRec:TWalkRec = w.GetByName("sub")
		Local cRec:TWalkRec = w.GetByName("c.txt")
		Local dRec:TWalkRec = w.GetByName("d.txt")

		AssertNotNull(subRec, "Missing record for sub")
		AssertNotNull(cRec, "Missing record for c.txt")
		AssertNotNull(dRec, "Missing record for d.txt")

		AssertEquals(1, subRec.depth, "sub depth should be 1")
		AssertEquals(2, cRec.depth, "c.txt depth should be 2")
		AssertEquals(3, dRec.depth, "d.txt depth should be 3")
	End Method


	' SkipSubtree must prevent descending into a directory.
	Method SkipSubtreeIsHonored() { test }
		Local w:TCollectWalker = New TCollectWalker
		w.skipSubtreeOnName = "sub"

		WalkFileTree(root, w, EFileWalkOption.None, 0)

		AssertTrue(w.HasName("sub"), "Expected to see sub directory itself")
		AssertFalse(w.HasName("c.txt"), "Did not expect to see c.txt when subtree is skipped")
		AssertFalse(w.HasName("d.txt"), "Did not expect to see d.txt when subtree is skipped")
	End Method


	Type TRootFirstSkipWalker Extends TCollectWalker
		Field triggered:Int = False
		Field triggerDepth:Int = 1

		Method WalkFile:EFileWalkResult(attributes:SFileAttributes Var)
			Local r:TWalkRec = New TWalkRec
			r.path = attributes.GetName()
			r.name = StripDir(r.path)
			r.depth = attributes.depth
			r.fileType = attributes.fileType
			r.size = attributes.size
			r.creationTime = attributes.creationTime
			r.modifiedTime = attributes.modifiedTime
			recs.AddLast(r)

			If Not triggered And r.depth = triggerDepth Then
				triggered = True
				Return EFileWalkResult.SkipSiblings
			End If

			Return EFileWalkResult.OK
		End Method
	End Type
	
	' SkipSiblings should stop walking other entries at the same directory level.
	Method SkipSiblingsIsHonored() { test }

		Local w:TRootFirstSkipWalker = New TRootFirstSkipWalker
		WalkFileTree(root, w, EFileWalkOption.None, 0)

		' We should have triggered on *some* direct child of root.
		AssertTrue(w.triggered, "Expected SkipSiblings to trigger on the first root-level entry")

		' Count how many direct children of root we ended up visiting.
		Local rootChildCount:Int = 0
		For Local r:TWalkRec = EachIn w.AllRecords()
			If r.depth = 1 Then rootChildCount :+ 1
		Next

		' After SkipSiblings triggers, we should not visit other siblings at depth 1.
		' So there should be exactly ONE depth-1 record.
		AssertEquals(1, rootChildCount, "Expected only one root-level entry to be visited after SkipSiblings")
	End Method


	' maxDepth should limit descent.
	' With maxDepth=1: only direct children of root should be visited.
	Method MaxDepthIsEnforced() { test }
		Local w:TCollectWalker = New TCollectWalker
		WalkFileTree(root, w, EFileWalkOption.None, 1)

		AssertTrue(w.HasName("a.txt"), "Expected to see a.txt at depth 1")
		AssertTrue(w.HasName("sub"), "Expected to see sub dir at depth 1")
		AssertFalse(w.HasName("c.txt"), "Did not expect to see c.txt at depth 2 with maxDepth=1")
		AssertFalse(w.HasName("d.txt"), "Did not expect to see d.txt deeper than maxDepth=1")
	End Method


	' attributes.GetName() should be a valid filesystem path.
	Method ReportedPathsExist() { test }
		Local w:TCollectWalker = New TCollectWalker
		WalkFileTree(root, w, EFileWalkOption.None, 0)

?not win32
		For Local r:TWalkRec = EachIn w.AllRecords()
			' Skip anything empty/odd (defensive)
			If Not r.path Then Continue
			AssertTrue(FileExists(r.path), "Walker reported a path that does not exist: " + r.path)
		Next
?
	End Method


	' Windows file times should line up with FileTime() (epoch seconds).
	Method ModifiedTimeMatchesFileTime() { test }
?win32
		Local target:String = root + "/a.txt"
		Local expected:Long = FileTime(target, FILETIME_MODIFIED)

		Local w:TCollectWalker = New TCollectWalker
		WalkFileTree(root, w, EFileWalkOption.None, 0)

		Local rec:TWalkRec = w.GetByName("a.txt")
		AssertNotNull(rec, "Missing a.txt record")

		' Allow a small tolerance just in case of filesystem granularity.
		Local delta:Long = expected - Long(rec.modifiedTime)
		If delta < 0 Then delta = -delta

		AssertTrue(delta <= 5, "Modified time mismatch. FileTime=" + expected + " WalkTree=" + rec.modifiedTime)
?
	End Method

End Type

Type TVirtualWalkTreeTest Extends TTest
	Field physRoot:String

	Method SetupMaxIO() { before }
		' 1) Physical sandbox (native)
		physRoot = _MakeUniqueRoot()
		AssertTrue(CreateDir(physRoot, True), "Failed to create physical sandbox: " + physRoot)

		' 2) Enable MaxIO
		AssertTrue(MaxIO.Init(), "MaxIO.Init() failed")

		' 3) Make sandbox writable and visible at virtual "/"
		AssertTrue(MaxIO.SetWriteDir(physRoot), "MaxIO.SetWriteDir() failed for: " + physRoot)
		AssertTrue(MaxIO.Mount(physRoot, "/", True), "MaxIO.Mount() failed for: " + physRoot)

		' 4) Create tree USING VIRTUAL PATHS
		AssertTrue(_WriteSmallFile("/a.txt", "A"), "Failed to create /a.txt in MaxIO mode")
		AssertTrue(_WriteSmallFile("/b.txt", "B"), "Failed to create /b.txt in MaxIO mode")
		AssertTrue(CreateDir("/sub", True), "Failed to create /sub in MaxIO mode")
		AssertTrue(_WriteSmallFile("/sub/c.txt", "C"), "Failed to create /sub/c.txt in MaxIO mode")
		AssertTrue(CreateDir("/sub/deeper", True), "Failed to create /sub/deeper in MaxIO mode")
		AssertTrue(_WriteSmallFile("/sub/deeper/d.txt", "D"), "Failed to create /sub/deeper/d.txt in MaxIO mode")
	End Method

	Method TeardownMaxIO() { after }
		' Clean up inside virtual FS first (best effort)
		DeleteDir("/sub", True)
		DeleteFile("/a.txt")
		DeleteFile("/b.txt")

		' Unmount/deinit
		If physRoot Then
			MaxIO.Unmount(physRoot)
		End If
		MaxIO.DeInit()

		' Physical cleanup guard (native)
		If physRoot And FileType(physRoot) = FILETYPE_DIR Then
			DeleteDir(physRoot, True)
		End If
	End Method

	Method DepthIsReported_Virtual() { test }
		Local w:TCollectWalker = New TCollectWalker

		' In MaxIO mode, root is "/" (per filesystem.bmx _RootPath behavior)
		WalkFileTree("/", w, EFileWalkOption.None, 0)

		AssertTrue(w.HasName("a.txt"), "Expected to see a.txt")
		AssertTrue(w.HasName("sub"), "Expected to see sub directory")
		AssertTrue(w.HasName("c.txt"), "Expected to see c.txt")
		AssertTrue(w.HasName("d.txt"), "Expected to see d.txt")

		Local subRec:TWalkRec = w.GetByName("sub")
		Local cRec:TWalkRec = w.GetByName("c.txt")
		Local dRec:TWalkRec = w.GetByName("d.txt")

		AssertNotNull(subRec, "Missing record for sub")
		AssertNotNull(cRec, "Missing record for c.txt")
		AssertNotNull(dRec, "Missing record for d.txt")

		AssertEquals(1, subRec.depth, "sub depth should be 1")
		AssertEquals(2, cRec.depth, "c.txt depth should be 2")
		AssertEquals(3, dRec.depth, "d.txt depth should be 3")
	End Method

	Method SkipSubtreeIsHonored_Virtual() { test }
		Local w:TCollectWalker = New TCollectWalker
		w.skipSubtreeOnName = "sub"

		WalkFileTree("/", w, EFileWalkOption.None, 0)

		AssertTrue(w.HasName("sub"), "Expected to see sub directory itself")
		AssertFalse(w.HasName("c.txt"), "Did not expect to see c.txt when subtree is skipped")
		AssertFalse(w.HasName("d.txt"), "Did not expect to see d.txt when subtree is skipped")
	End Method

	Method MaxDepthIsEnforced_Virtual() { test }
		Local w:TCollectWalker = New TCollectWalker
		WalkFileTree("/", w, EFileWalkOption.None, 1)

		AssertTrue(w.HasName("a.txt"), "Expected to see a.txt at depth 1")
		AssertTrue(w.HasName("sub"), "Expected to see sub dir at depth 1")
		AssertFalse(w.HasName("c.txt"), "Did not expect to see c.txt at depth 2 with maxDepth=1")
		AssertFalse(w.HasName("d.txt"), "Did not expect to see d.txt deeper than maxDepth=1")
	End Method

	Method SkipSiblingsIsHonored_Virtual() { test }

		Local w:TRootFirstSkipWalker = New TRootFirstSkipWalker
		WalkFileTree("/", w, EFileWalkOption.None, 0)

		AssertTrue(w.triggered, "Expected SkipSiblings to trigger on the first root-level entry")

		Local rootChildCount:Int = 0
		For Local r:TWalkRec = EachIn w.AllRecords()
			If r.depth = 1 Then rootChildCount :+ 1
		Next
		AssertEquals(1, rootChildCount, "Expected only one root-level entry to be visited after SkipSiblings")
	End Method
End Type

' Use the order-independent version (directory enumeration order is unspecified)
Type TRootFirstSkipWalker Extends TCollectWalker
	Field triggered:Int = False
	Method WalkFile:EFileWalkResult(attributes:SFileAttributes Var)
		Local r:TWalkRec = New TWalkRec
		r.path = attributes.GetName()
		r.name = StripDir(r.path)
		r.depth = attributes.depth
		r.fileType = attributes.fileType
		recs.AddLast(r)

		If Not triggered And r.depth = 1 Then
			triggered = True
			Return EFileWalkResult.SkipSiblings
		End If
		Return EFileWalkResult.OK
	End Method
End Type


' ------------------------------------------------------------
' Helpers
' ------------------------------------------------------------

Type TWalkRec
	Field path:String
	Field name:String
	Field depth:Int
	Field fileType:Int
	Field size:ULong
	Field creationTime:Int
	Field modifiedTime:Int
End Type

Type TCollectWalker Implements IFileWalker
	Field recs:TList = New TList

	' Optional behavior controls
	Field skipSubtreeOnName:String = ""
	Field skipSiblingsOnName:String = ""
	Field terminateOnName:String = ""

	Method WalkFile:EFileWalkResult(attributes:SFileAttributes Var)
		Local r:TWalkRec = New TWalkRec
		r.path = attributes.GetName()
		r.name = StripDir(r.path)
		r.depth = attributes.depth
		r.fileType = attributes.fileType
		r.size = attributes.size
		r.creationTime = attributes.creationTime
		r.modifiedTime = attributes.modifiedTime
		recs.AddLast(r)

		If terminateOnName And r.name = terminateOnName Then
			Return EFileWalkResult.Terminate
		End If

		If skipSiblingsOnName And r.name = skipSiblingsOnName Then
			Return EFileWalkResult.SkipSiblings
		End If

		If skipSubtreeOnName And r.name = skipSubtreeOnName Then
			Return EFileWalkResult.SkipSubtree
		End If

		Return EFileWalkResult.OK
	End Method

	Method Count:Int()
		Return recs.Count()
	End Method

	Method HasName:Int(name:String)
		For Local r:TWalkRec = EachIn recs
			If r.name = name Then Return True
		Next
		Return False
	End Method

	Method GetByName:TWalkRec(name:String)
		For Local r:TWalkRec = EachIn recs
			If r.name = name Then Return r
		Next
		Return Null
	End Method

	Method AllRecords:TList()
		Return recs
	End Method
End Type

Function _MakeUniqueRoot:String()
	Local root:String = CurrentDir() + "/walktree_test_" + MilliSecs()
	FixPath root, True
	Return root
End Function

Function _WriteSmallFile:Int(path:String, text:String)
	Local s:TStream = WriteFile(path)
	If Not s Return False
	s.WriteString(text)
	s.Close()
	Return True
End Function

Function _EnsureDir:Int(path:String)
	Return CreateDir(path, True)
End Function
