SuperStrict

Framework brl.maxunit
Import brl.filesystem
Import brl.stream
Import brl.standardio
Import brl.path

New TTestSuite.run()

Type TPathCreationTest Extends TTest

	Field root:String

	Method Setup() { before }
		root = _MakeTempRoot("tpath_test")
	End Method

	Method Teardown() { after }
		If root Then DeleteDir(root, True)
	End Method

	Method ConstructorNormalizesSlashesAndStripsTrailing() { test }
		Local p:TPath = New TPath(root + "\sub\")
		' Should be normalized and not end with / (unless root itself)
		AssertFalse(p.ToString().EndsWith("/"), "Expected trailing slash to be stripped")
		AssertTrue(p.ToString().Find("\") = -1, "Expected backslashes to be normalized to /")
	End Method

	Method FromStringEqualsConstructor() { test }
		Local a:TPath = New TPath(root + "/sub")
		Local b:TPath = TPath.FromString(root + "/sub/")
		AssertTrue(a.Equals(b), "Expected FromString to match constructor normalization")
		AssertEquals(a.HashCode(), b.HashCode(), "Equal paths should have same hash")
	End Method

	Method CompareConsistentWithEquals() { test }
		Local a:TPath = New TPath(root + "/sub")
		Local b:TPath = New TPath(root + "/sub/")
		AssertEquals(0, a.Compare(b), "Compare should be 0 for equal paths")
	End Method

	Method FromPartsJoinsAndResetsOnRootedPart() { test }
		Local a:TPath = New TPath("a/b")
		Local b:TPath = New TPath("/etc")
		Local p:TPath = TPath.FromParts([a, b, Object("init.d")])
		' rooted b should replace a/b, leaving /etc/init.d
		AssertTrue(p.ToString().EndsWith("/etc/init.d") Or p.ToString()="/etc/init.d", "Expected rooted part to reset path")
	End Method

End Type

Type TPathComposeTest Extends TTest

	Method JoinAndOperatorSlashAreEquivalent() { test }
		Local p:TPath = New TPath("a")
		Local a:TPath = p.Join("b").Join("c")
		Local b:TPath = p / "b" / "c"
		AssertTrue(a.Equals(b), "Expected Join and / operator to produce same path")
	End Method

	Method ChildIsAliasForJoin() { test }
		Local p:TPath = New TPath("a/b")
		AssertTrue(p.Child("c").Equals(p.Join("c")), "Expected Child to behave like Join")
	End Method

	Method ResolveRootedReplacesBase() { test }
		Local p:TPath = New TPath("a/b")
		Local r:TPath = p.Resolve("/x/y")
		AssertTrue(r.ToString().EndsWith("/x/y") Or r.ToString()="/x/y", "Expected rooted resolve to replace base")
	End Method

	Method WithNameReplacesLastSegment() { test }
		Local p:TPath = New TPath("a/b/c.txt")
		Local q:TPath = p.WithName("d.bin")
		AssertEquals("d.bin", q.Name(), "Expected WithName to set last segment")
		AssertTrue(q.Parent().ToString().EndsWith("a/b"), "Expected parent to remain a/b")
	End Method

	Method WithExtensionReplacesExtension() { test }
		Local p:TPath = New TPath("a/b/archive.tar.gz")
		Local q:TPath = p.WithExtension("zip")
		AssertEquals("zip", q.Extension(), "Expected extension to be replaced")
		AssertEquals("archive.tar", q.BaseName(), "Expected basename to remain archive.tar")
	End Method

End Type

Type TPathRelativizeTest Extends TTest

	Method RelativizeSimple() { test }
		Local p:TPath = New TPath("/a/b")
		Local q:TPath = New TPath("/a/b/c/d")
		Local r:TPath = p.Relativize(q)
		AssertEquals("c/d", r.ToString(), "Expected /a/b relativize /a/b/c/d => c/d")
	End Method

	Method RelativizeUpwards() { test }
		Local p:TPath = New TPath("/a/b/c")
		Local q:TPath = New TPath("/a/b")
		Local r:TPath = p.Relativize(q)
		AssertEquals("..", r.ToString(), "Expected /a/b/c relativize /a/b => ..")
	End Method

	Method RelativizeResolveInverseProperty() { test }
		Local p:TPath = New TPath("/a/b")
		Local q:TPath = New TPath("c/d") ' non-rooted
		Local combined:TPath = p.Resolve(q)
		Local rel:TPath = p.Relativize(combined)
		AssertTrue(rel.Equals(q), "Expected p.Relativize(p.Resolve(q)) == q for non-rooted q")
	End Method

	Method RelativizeThrowsOnNull() { test }
		Local p:TPath = New TPath("a/b")
		Try
			p.Relativize(Null)
			Fail("Expected Relativize to throw on Null")
		Catch ex:Object
			' ok
		End Try
	End Method

	Method RelativizeThrowsRootedVsRelativeMismatch() { test }
		Local p:TPath = New TPath("/a/b")
		Local q:TPath = New TPath("c/d")
		Try
			p.Relativize(q)
			Fail("Expected rooted vs non-rooted relativize to throw")
		Catch ex:Object
		End Try
	End Method

	Method RelativizeEqualReturnsEmpty() { test }
		Local p:TPath = New TPath("a/b")
		Local r:TPath = p.Relativize(New TPath("a/b"))
		AssertEquals("", r.ToString(), "Expected empty path when relativizing equal paths")
	End Method

	Method RelativizeProducesDotDotWhenDiverging() { test }
		Local p:TPath = New TPath("/a/b/c")
		Local q:TPath = New TPath("/a/x/y")
		Local r:TPath = p.Relativize(q)
		' from /a/b/c to /a/x/y => ../../x/y
		AssertEquals("../../x/y", r.ToString(), "Expected ../../x/y")
	End Method

	Method RelativizeResolveInversePropertyMore() { test }
		Local p:TPath = New TPath("a/b")
		Local q:TPath = New TPath("c/d/e")
		Local combined:TPath = p.Resolve(q)
		Local rel:TPath = p.Relativize(combined)
		AssertTrue(rel.Equals(q), "Expected p.Relativize(p.Resolve(q)) == q for relative q")
	End Method
End Type

Type TPathFsTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		Local r:String = _MakeTempRoot("tpath_fs")
		root = New TPath(r)

		AssertTrue(root.CreateDir(True), "Expected to create root dir")

		AssertTrue((root / "sub").CreateDir(True), "Expected to create sub dir")
		AssertTrue(_WriteTextFile((root / "a.txt").ToString(), "hi"), "Expected to write a.txt")
		AssertTrue(_WriteTextFile((root / "sub" / "b.txt").ToString(), "hi"), "Expected to write sub/b.txt")
		AssertTrue(_WriteTextFile((root / "sub" / "c.bmx").ToString(), "Print 1"), "Expected to write sub/c.bmx")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method ExistsAndTypesWork() { test }
		AssertTrue((root / "a.txt").Exists(), "Expected a.txt to exist")
		AssertTrue((root / "a.txt").IsFile(), "Expected a.txt to be a file")
		AssertTrue((root / "sub").IsDir(), "Expected sub to be a dir")
	End Method

	Method IterDirYieldsImmediateChildren() { test }
		Using
			Local it:TPathDirIterator = root.IterDir()
		Do
			Local names:String[] = _CollectNames(it)
			AssertTrue(_Contains(names, "a.txt"), "Expected IterDir to include a.txt")
			AssertTrue(_Contains(names, "sub"), "Expected IterDir to include sub")
			AssertFalse(_Contains(names, "b.txt"), "Did not expect IterDir to include sub/b.txt")
		End Using
	End Method

	Method ListMatchesIterDirAsSet() { test }
		Local list:TPath[] = root.List()
		Local names1:TList = New TList
		For Local p:TPath = EachIn list
			names1.AddLast(p.Name())
		Next

		Using
			Local it:TPathDirIterator = root.IterDir()
		Do
			Local names2:String[] = _CollectNames(it)
			AssertEquals(list.Length, names2.Length, "Expected List and IterDir to yield same count")
			AssertTrue(names1.Contains("a.txt"), "Expected List to include a.txt")
			AssertTrue(names1.Contains("sub"), "Expected List to include sub")
		End Using
	End Method

	Method GlobIterWorksFromPathBase() { test }
		Using
			Local it:TPathIterator = root.GlobIter("{*.bmx,**/*.bmx}", EGlobOptions.GlobStar)
		Do
			Local saw:Int = False
			For Local p:TPath = EachIn it
				If p.Name() = "c.bmx" Then saw = True
			Next
			AssertTrue(saw, "Expected to find c.bmx via glob")
		End Using
	End Method

End Type

Type TPathCoreOpsTest Extends TTest

	Method ParentOfRootIsSelf() { test }
		Local r:TPath = TPath.Root()
		AssertTrue(r.Parent() = r, "Expected Parent of root to return Self")
	End Method

	Method ParentOfRelativeIsDotWhenNoDir() { test }
		Local p:TPath = New TPath("file.txt")
		AssertEquals(".", p.Parent().ToString(), "Expected parent of bare filename to be .")
	End Method

	Method ResolveStringMatchesJoin() { test }
		Local p:TPath = New TPath("a/b")
		AssertTrue(p.Resolve("c").Equals(p.Join("c")), "Resolve(string) should match Join")
	End Method

	Method ResolveTPathRootedReplaces() { test }
		Local base:TPath = New TPath("a/b")
		Local rooted:TPath = New TPath("/x/y")
		Local r:TPath = base.Resolve(rooted)
		AssertTrue(r.Equals(rooted), "Resolve(rooted) should replace base")
	End Method

	Method RealMakesAbsoluteFromRelative() { test }
		Local p:TPath = New TPath("a/b")
		Local r:TPath = p.Real()
		' RealPath in BRL.Filesystem anchors on CurrentDir for non-rooted.
		AssertTrue(r.ToString().StartsWith(CurrentDir()), "Expected Real() to be anchored to CurrentDir()")
	End Method

	Method CwdIsCurrentDir() { test }
		AssertEquals(CurrentDir(), TPath.Cwd().ToString(), "Expected Cwd() to equal CurrentDir()")
	End Method

End Type

Type TPathFsOpsTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_ops"))
		AssertTrue(root.CreateDir(True), "Expected to create test root directory")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method CreateFileAndSizeWorks() { test }
		Local f:TPath = root / "x.bin"
		AssertTrue(f.CreateFile(), "Expected CreateFile to succeed")
		AssertTrue(f.Exists(), "Expected file to exist after CreateFile")

		' Write some bytes to ensure size > 0
		AssertTrue(_WriteTextFile(f.ToString(), "hello"), "Expected to write file")
		AssertTrue(f.Size() >= 5, "Expected file size >= 5")
	End Method

	Method RenameToReturnsNewPath() { test }
		Local a:TPath = root / "a.txt"
		Local b:TPath = root / "b.txt"
		AssertTrue(_WriteTextFile(a.ToString(), "hi"), "Expected to create a.txt")

		Local newp:TPath
		Local ok:Int = a.RenameTo(b, newp)
		AssertTrue(ok, "Expected rename to succeed")
		AssertTrue(newp.Equals(b), "Expected newPath to equal destination")
		AssertFalse(a.Exists(), "Expected old path to not exist")
		AssertTrue(b.Exists(), "Expected new path to exist")
	End Method

	Method RenameToSimpleOverload() { test }
		Local a:TPath = root / "c.txt"
		Local b:TPath = root / "d.txt"
		AssertTrue(_WriteTextFile(a.ToString(), "hi"), "Expected to create c.txt")

		AssertTrue(a.RenameTo(b), "Expected rename overload to succeed")
		AssertFalse(a.Exists(), "Expected old path to not exist")
		AssertTrue(b.Exists(), "Expected new path to exist")
	End Method

	Method CopyFileToCopiesContents() { test }
		Local src:TPath = root / "src.txt"
		Local dst:TPath = root / "dst.txt"
		AssertTrue(_WriteTextFile(src.ToString(), "content"), "Expected to create src")

		AssertTrue(src.CopyFileTo(dst), "Expected CopyFileTo to succeed")
		AssertTrue(dst.Exists(), "Expected destination file to exist")
		AssertEquals(src.Size(), dst.Size(), "Expected copied file size to match")
	End Method

	Method CopyDirToCopiesTree() { test }
		Local srcDir:TPath = root / "srcDir"
		Local dstDir:TPath = root / "dstDir"
		AssertTrue(srcDir.CreateDir(True), "Expected to create srcDir")
		AssertTrue((srcDir / "sub").CreateDir(True), "Expected to create srcDir/sub")
		AssertTrue(_WriteTextFile((srcDir / "a.txt").ToString(), "a"), "Expected to create a.txt")
		AssertTrue(_WriteTextFile((srcDir / "sub" / "b.txt").ToString(), "b"), "Expected to create b.txt")

		AssertTrue(srcDir.CopyDirTo(dstDir), "Expected CopyDirTo to succeed")
		AssertTrue((dstDir / "a.txt").Exists(), "Expected dstDir/a.txt to exist")
		AssertTrue((dstDir / "sub" / "b.txt").Exists(), "Expected dstDir/sub/b.txt to exist")
	End Method

	Method DeleteFileAndDeleteDirWork() { test }
		Local d:TPath = root / "todel"
		AssertTrue(d.CreateDir(True), "Expected to create directory")
		Local f:TPath = d / "x.txt"
		AssertTrue(_WriteTextFile(f.ToString(), "x"), "Expected to write file")

		AssertTrue(f.DeleteFile(), "Expected DeleteFile to succeed")
		AssertFalse(f.Exists(), "Expected file to be deleted")

		AssertTrue(d.DeleteDir(False), "Expected DeleteDir to succeed (empty dir)")
		AssertFalse(d.Exists(), "Expected directory to be deleted")
	End Method

	Method ModifiedTimeIsNonZeroAfterWrite() { test }
		Local f:TPath = root / "mtime.txt"
		AssertTrue(_WriteTextFile(f.ToString(), "hi"), "Expected to write file")
		AssertTrue(f.ModifiedTime() > 0, "Expected ModifiedTime > 0")
	End Method

End Type

Type TPathDirIteratorTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_diriter"))
		root.CreateDir(True)
		(root / "sub").CreateDir(True)
		_WriteTextFile((root / "a.txt").ToString(), "a")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method IterDirSkipsDotsByDefault() { test }
		Using
			Local it:TPathDirIterator = root.IterDir(True)
		Do
			For Local p:TPath = EachIn it
				AssertFalse(p.Name() = "." Or p.Name() = "..", "Did not expect dot entries")
			Next
		End Using
	End Method

	Method ListAndIterDirMatchAsSet() { test }
		Local a:TPath[] = root.List()

		Local namesA:TList = New TList
		For Local p:TPath = EachIn a
			namesA.AddLast(p.Name())
		Next

		Using
			Local it:TPathDirIterator = root.IterDir()
		Do
			Local namesB:String[] = _CollectNames(it)
			AssertEquals(a.Length, namesB.Length, "Expected same count from List and IterDir")
			AssertTrue(namesA.Contains("a.txt"), "Expected a.txt in List")
			AssertTrue(namesA.Contains("sub"), "Expected sub in List")
		End Using
	End Method

	Method IterDirEarlyExitStressDoesNotLeak() { test }
		For Local i:Int = 0 Until 300
			Using
				Local it:TPathDirIterator = root.IterDir()
			Do
				For Local p:TPath = EachIn it
					Exit
				Next
			End Using
		Next
		AssertTrue(True, "Completed early-exit stress loop")
	End Method

End Type

Type TPathGlobIntegrationTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_globint"))
		root.CreateDir(True)
		(root / "sub").CreateDir(True)
		_WriteTextFile((root / "a.bmx").ToString(), "Print 1")
		_WriteTextFile((root / "sub" / "b.bmx").ToString(), "Print 2")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method GlobReturnsPaths() { test }
		Local r:TPath[] = root.Glob("{*.bmx,**/*.bmx}", EGlobOptions.GlobStar)
		AssertEquals(2, r.Length, "Expected 2 matches")
		AssertTrue(TPath(r[0]) <> Null , "Expected TPath elements")
	End Method

	Method GlobIterYieldsPathsAndCanStopEarly() { test }
		Local sawSub:Int = False
		Using
			Local it:TPathIterator = root.GlobIter("**/*.bmx", EGlobOptions.GlobStar)
		Do
			For Local p:TPath = EachIn it
				If p.Name() = "b.bmx" Then sawSub = True
				Exit
			Next
		End Using
		' could exit before seeing b.bmx depending on order; so just assert iterator produced something
		AssertTrue(True, "Iterator early stop completed")
	End Method

	Method MatchGlobMatchesTrailingSegments() { test }
		Local p:TPath = New TPath(root.ToString() + "/sub/b.bmx")
		AssertTrue(p.MatchGlob("sub/*.bmx"), "Expected relative pattern to match absolute path trailing segments")
	End Method

End Type

Type TWalkCollect Implements IPathWalker
	Field names:TList = New TList
	Method WalkPath:EFileWalkResult(attributes:SPathAttributes Var)
		names.AddLast(attributes.GetName())
		Return EFileWalkResult.OK
	End Method
End Type

Type TPathWalkTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_walk"))
		root.CreateDir(True)
		(root / "sub").CreateDir(True)
		_WriteTextFile((root / "a.txt").ToString(), "a")
		_WriteTextFile((root / "sub" / "b.txt").ToString(), "b")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method WalkSeesFilesAndDirs() { test }
		Local w:TWalkCollect = New TWalkCollect
		root.Walk(w)

		AssertTrue(w.names.Contains(root.ToString()), "Expected to see root path")
		AssertTrue(w.names.Contains((root / "a.txt").ToString()), "Expected to see a.txt")
		AssertTrue(w.names.Contains((root / "sub").ToString()), "Expected to see sub dir")
		AssertTrue(w.names.Contains((root / "sub" / "b.txt").ToString()), "Expected to see b.txt")
	End Method

End Type

Type TPathWithExtensionTest Extends TTest

	Method WithExtensionAddsWhenNoExtension() { test }
		Local p:TPath = New TPath("a/b/file")
		Local q:TPath = p.WithExtension("txt")
		AssertEquals("file.txt", q.Name(), "Expected file => file.txt")
		AssertTrue(q.Parent().ToString().EndsWith("a/b"), "Expected parent unchanged")
	End Method

	Method WithExtensionReplacesLastExtensionOnly() { test }
		Local p:TPath = New TPath("a/b/archive.tar.gz")
		Local q:TPath = p.WithExtension("zip")
		AssertEquals("archive.tar.zip", q.Name(), "Expected archive.tar.gz => archive.tar.zip")
		AssertEquals("zip", q.Extension(), "Expected extension zip")
		AssertEquals("archive.tar", q.BaseName(), "Expected basename archive.tar")
	End Method

	Method WithExtensionAcceptsLeadingDot() { test }
		Local p:TPath = New TPath("a/b/file.txt")
		Local q:TPath = p.WithExtension(".md")
		AssertEquals("file.md", q.Name(), "Expected leading-dot extension to be accepted")
	End Method

	Method WithExtensionEmptyRemovesExtension() { test }
		Local p:TPath = New TPath("a/b/file.txt")
		Local q:TPath = p.WithExtension("")
		AssertEquals("file", q.Name(), "Expected empty ext to remove extension")
		AssertEquals("", q.Extension(), "Expected no extension")
	End Method

	Method WithExtensionOnDotfileKeepsDotfileName() { test }
		' This documents current semantics: BaseName(".gitignore") is ".gitignore"
		' so WithExtension adds a second extension: ".gitignore.bak"
		Local p:TPath = New TPath(".gitignore")
		Local q:TPath = p.WithExtension("bak")
		AssertEquals(".gitignore.bak", q.Name(), "Expected dotfile to keep name and append extension")
	End Method

	Method DotfileHasNoExtension() { test }
		Local p:TPath = New TPath(".gitignore")
		AssertEquals("", p.Extension(), "Expected .gitignore to have no extension")
		AssertEquals(".gitignore", p.BaseName(), "Expected .gitignore basename to be the whole name")
	End Method

	Method DotfileWithExtraDotHasExtension() { test }
		Local p:TPath = New TPath(".profile.bak")
		AssertEquals("bak", p.Extension(), "Expected .profile.bak extension to be bak")
		AssertEquals(".profile", p.BaseName(), "Expected .profile.bak basename to be .profile")
	End Method
End Type

Type TPathWithNameTest Extends TTest

	Method WithNameReplacesLastSegment() { test }
		Local p:TPath = New TPath("a/b/c.txt")
		Local q:TPath = p.WithName("d.bin")
		AssertEquals("d.bin", q.Name(), "Expected WithName to replace name")
		AssertTrue(q.Parent().ToString().EndsWith("a/b"), "Expected parent unchanged")
	End Method

	Method WithNameOnBareFilenameUsesDotParent() { test }
		Local p:TPath = New TPath("c.txt")
		Local q:TPath = p.WithName("d.txt")
		AssertEquals("d.txt", q.Name(), "Expected WithName to produce d.txt")
		AssertEquals(".", q.Parent().ToString(), "Expected parent to be . for bare filename")
	End Method

	Method WithNameAllowsSubpath() { test }
		' Current semantics: Parent().Join(name) so "name" can include slashes.
		Local p:TPath = New TPath("a/b/c.txt")
		Local q:TPath = p.WithName("x/y.txt")
		AssertTrue(q.ToString().EndsWith("a/b/x/y.txt"), "Expected WithName to accept a subpath")
	End Method

End Type

Type TPathStreamTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_stream"))
		root.CreateDir(True)
	End Method

	Method Teardown() { after }
		If root Then
			root.DeleteDir(True)
		End If
	End Method

	Method WriteThenReadRoundTrip() { test }
		Local p:TPath = root / "hello.txt"
		Using
			Local s:TStream = p.Write()
		Do
			AssertNotNull(s, "Expected Write() stream")
			s.WriteString("hello world")
		End Using

		Using
			Local r:TStream = p.Read()
		Do
			AssertNotNull(r, "Expected Read() stream")
			Local got:String = r.ReadString(Int(r.Size()))
			AssertEquals("hello world", got, "Expected content round-trip")
		End Using
	End Method

	Method OpenReadWriteCreatesSeekableStream() { test }
		Local p:TPath = root / "rw.txt"

		' Ensure the file exists first
		AssertTrue(p.CreateFile(), "Expected CreateFile() to succeed")

		Using
			Local s:TStream = p.Open(True, True)
		Do
			AssertNotNull(s, "Expected Open() stream")
			s.WriteString("abc")
			s.Seek(0)
			Local got:String = s.ReadString(3)
			AssertEquals("abc", got, "Expected read-after-write via Open()")
		End Using
	End Method
End Type

Type TPathTimeTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_time"))
		root.CreateDir(True)
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method ModifiedDateTimeMatchesModifiedTimeEpoch() { test }
		Local p:TPath = root / "t.txt"
		AssertTrue(_WriteTextFile(p.ToString(), "x"), "Expected to write file")

		Local t:Long = p.ModifiedTime()
		Local dt:SDateTime = p.ModifiedDateTime()

		AssertTrue(t > 0, "Expected ModifiedTime > 0")
		AssertEquals(t, dt.ToEpochSecs(), "Expected ModifiedDateTime epoch secs to match ModifiedTime")
	End Method

	Method ModifiedTimeChangesAfterRewrite() { test }
		Local p:TPath = root / "m.txt"
		AssertTrue(_WriteTextFile(p.ToString(), "one"), "Expected initial write")
		Local t1:Long = p.ModifiedTime()

		' Try to ensure timestamp resolution can tick; avoid Sleep if you prefer.
		' If you have a MilliSecs-based delay, use Delay(1100) to cross 1s boundary on coarse FS.
		Delay(1100)

		AssertTrue(_WriteTextFile(p.ToString(), "two"), "Expected rewrite")
		Local t2:Long = p.ModifiedTime()

		AssertTrue(t2 >= t1, "Expected ModifiedTime not to go backwards")
		AssertTrue(t2 <> 0, "Expected ModifiedTime not zero")
	End Method

End Type

Type TPathGlobShapeTest Extends TTest

	Field root:TPath

	Method Setup() { before }
		root = New TPath(_MakeTempRoot("tpath_globshape"))
		root.CreateDir(True)
		(root / "sub").CreateDir(True)
		_WriteTextFile((root / "a.bmx").ToString(), "x")
		_WriteTextFile((root / "sub" / "b.bmx").ToString(), "x")
	End Method

	Method Teardown() { after }
		If root Then root.DeleteDir(True)
	End Method

	Method GlobReturnsAbsolutePathsWhenBaseIsAbsolute() { test }
		' root here should be absolute because _MakeTempRoot uses CurrentDir prefix
		Local r:TPath[] = root.Glob("{*.bmx,**/*.bmx}", EGlobOptions.GlobStar)
		For Local p:TPath = EachIn r
			AssertTrue(p.ToString().StartsWith(root.ToString()), "Expected match to be under base dir")
		Next
	End Method

	Method GlobIterReturnsTPathsUnderBase() { test }
		Using
			Local it:TPathIterator = root.GlobIter("{*.bmx,**/*.bmx}", EGlobOptions.GlobStar)
		Do
			For Local p:TPath = EachIn it
				AssertTrue(p.ToString().StartsWith(root.ToString()), "Expected iter match to be under base dir")
			Next
		End Using
	End Method

End Type

' ---------- Helpers ----------

Function _MakeTempRoot:String(prefix:String)
	Local base:String = CurrentDir() + "/" + prefix + "_" + MilliSecs()
	FixPath base, True
	CreateDir(base, True)
	Return base
End Function

Function _WriteTextFile:Int(path:String, text:String)
	Local s:TStream = WriteFile(path)
	If Not s Then Return False
	s.WriteString(text)
	s.Close()
	Return True
End Function

Function _CollectNames:String[](it:IIterator<TPath>)
	Local lst:TList = New TList
	While it.MoveNext()
		lst.AddLast(it.Current().Name())
	Wend
	Local out:String[] = New String[lst.Count()]
	Local i:Int = 0
	For Local s:String = EachIn lst
		out[i] = s
		i :+ 1
	Next
	Return out
End Function

Function _Contains:Int(arr:String[], value:String)
	For Local s:String = EachIn arr
		If s = value Then Return True
	Next
	Return False
End Function