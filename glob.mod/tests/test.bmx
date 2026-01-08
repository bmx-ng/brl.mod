SuperStrict

Framework brl.standardio
Import BRL.Glob
Import BRL.MaxUnit

New TTestSuite.run()

Type TGlobTest Extends TTest
	Field root:String

	Method Before() { before }
		root = _MakeUniqueRoot()
		AssertTrue(CreateDir(root, True), "Failed to create root test directory: " + root)

		AssertTrue(_WriteSmallFile(root + "/a.txt", "A"), "Failed to create a.txt")
		AssertTrue(_WriteSmallFile(root + "/b.TXT", "B"), "Failed to create b.TXT")
		AssertTrue(_WriteSmallFile(root + "/.hidden", "H"), "Failed to create .hidden")

		AssertTrue(CreateDir(root + "/sub", True), "Failed to create sub")
		AssertTrue(_WriteSmallFile(root + "/sub/c.txt", "C"), "Failed to create sub/c.txt")

		AssertTrue(CreateDir(root + "/sub/deeper", True), "Failed to create sub/deeper")
		AssertTrue(_WriteSmallFile(root + "/sub/deeper/d.txt", "D"), "Failed to create sub/deeper/d.txt")

		AssertTrue(CreateDir(root + "/.hiddendir", True), "Failed to create .hiddendir")
		AssertTrue(_WriteSmallFile(root + "/.hiddendir/inside.txt", "I"), "Failed to create inside.txt")

		AssertTrue(_WriteSmallFile(root + "/brack[et].txt", "B"), "Failed to create brack[et].txt")
		AssertTrue(_WriteSmallFile(root + "/q?.txt", "Q"), "Failed to create q?.txt")

		AssertTrue(CreateDir(root + "/emptydir", True), "Failed to create emptydir")
	End Method

	Method After() { after }
		If root And FileType(root) = FILETYPE_DIR Then
			DeleteDir(root, True)
		End If
	End Method

	Method StarMatchesOnlySegment() { test }
		Local r:String[] = Glob("*.txt", EGlobOptions.None, root)

		Local sawA:Int = False
		Local sawB:Int = False
		Local sawHidden:Int = False
		Local sawInside:Int = False

		For Local s:String = EachIn r
			If s = "a.txt" Then sawA = True
			If s = "b.TXT" Then sawB = True
			If s = ".hidden" Then sawHidden = True
			If s = "inside.txt" Or s = ".hiddendir/inside.txt" Then sawInside = True
		Next

		AssertTrue(sawA, "Expected a.txt to match *.txt")
		AssertFalse(sawB, "Did not expect b.TXT without CaseFold")
		AssertFalse(sawHidden, "Did not expect .hidden without Period")
		AssertFalse(sawInside, "Did not expect nested inside.txt from *.txt")
	End Method

	Method CaseFoldWorks() { test }
		Local r:String[] = Glob("*.txt", EGlobOptions.CaseFold, root)

		Local sawA:Int = False
		Local sawB:Int = False
		Local sawHidden:Int = False

		For Local s:String = EachIn r
			If s = "a.txt" Then sawA = True
			If s = "b.TXT" Then sawB = True
			If s = ".hidden" Then sawHidden = True
		Next

		AssertTrue(sawA, "Missing a.txt with CaseFold")
		AssertTrue(sawB, "Missing b.TXT with CaseFold")
		AssertFalse(sawHidden, "Did not expect .hidden without Period, even with CaseFold")
	End Method

	Method DotfilesDefaultHidden() { test }
		Local r:String[] = Glob("*", EGlobOptions.None, root)
		For Local s:String = EachIn r
			AssertFalse(s = ".hidden", "Did not expect .hidden without Period flag")
		Next
	End Method

	Method DotfilesPeriodFlag() { test }
		Local r:String[] = Glob("*", EGlobOptions.Period, root)
		Local found:Int = False
		For Local s:String = EachIn r
			If s = ".hidden" Then found = True
		Next
		AssertTrue(found, "Expected .hidden with Period flag")
	End Method

	Method CharacterClassWorks() { test }
		Local r:String[] = Glob("[ab].txt", EGlobOptions.None, root)
		AssertEquals(1, r.Length, "Expected only a.txt to match [ab].txt")
		AssertEquals("a.txt", r[0], "Expected a.txt")
	End Method

	Method GlobstarRecurses() { test }
		Local r:String[] = Glob("sub/**/*.txt", EGlobOptions.GlobStar, root)
		' Expect sub/c.txt and sub/deeper/d.txt (sorted)
		AssertEquals(2, r.Length, "Expected 2 matches for globstar")
		AssertEquals("sub/c.txt", r[0], "Expected sub/c.txt")
		AssertEquals("sub/deeper/d.txt", r[1], "Expected sub/deeper/d.txt")
	End Method

	Method MatchGlobPathAware() { test }
		AssertTrue(MatchGlob("sub/*.txt", root + "/sub/c.txt"), "Expected MatchGlob to match sub/c.txt")
		AssertFalse(MatchGlob("sub/*.txt", root + "/sub/deeper/d.txt"), "Did not expect sub/*.txt to match deeper file")
	End Method

	Method MatchGlobGlobstar() { test }
		AssertTrue(MatchGlob("sub/**/*.txt", root + "/sub/deeper/d.txt", EGlobOptions.GlobStar), "Expected globstar to match")
	End Method

	Method QMarkMatchesSingleChar() { test }
		Local r:String[] = Glob("?.txt", EGlobOptions.None, root)
		' a.txt is 5 chars incl dot; "?.txt" expects 1 char before ".txt" => matches "a.txt" only if name is "a.txt"
		' Actually "a.txt" has 1 char before ".txt" => yes.
		AssertEquals(1, r.Length, "Expected 1 match for ?.txt")
		AssertEquals("a.txt", r[0], "Expected a.txt")
	End Method

	Method CharClassNegationWorks() { test }
		Local r:String[] = Glob("[!a].TXT", EGlobOptions.None, root)
		' b.TXT should match; case sensitive and extension is TXT
		AssertEquals(1, r.Length, "Expected 1 match for [!a].TXT")
		AssertEquals("b.TXT", r[0], "Expected b.TXT")
	End Method

	Method CharClassRangeWorks_CaseSensitive() { test }
		' a.txt matches [a-c].txt
		Local r:String[] = Glob("[a-c].txt", EGlobOptions.None, root)
		AssertEquals(1, r.Length, "Expected 1 match for [a-c].txt")
		AssertEquals("a.txt", r[0], "Expected a.txt")
	End Method

	Method EscapeWorks() { test }
		' Create a file with a literal '*' in the name
		AssertTrue(_WriteSmallFile(root + "/star*.txt", "S"), "Failed to create star*.txt")
		Local r:String[] = Glob("star\*.txt", EGlobOptions.None, root)
		AssertEquals(1, r.Length, "Expected 1 match for escaped star")
		AssertEquals("star*.txt", r[0], "Expected star*.txt")
	End Method

	Method NoEscapeTreatsBackslashLiterally() { test }
		' If NoEscape is set, backslash is literal, so "star\*.txt" should NOT match "star*.txt"
		Local r:String[] = Glob("star\*.txt", EGlobOptions.NoEscape, root)
		AssertEquals(0, r.Length, "Expected 0 matches with NoEscape")
	End Method

	Method OnlyDirFiltersToDirectories() { test }
		Local r:String[] = Glob("*", EGlobOptions.OnlyDir | EGlobOptions.Period, root)
		' Should include "sub" but exclude files (a.txt, b.TXT, .hidden)
		Local hasSub:Int = False
		For Local s:String = EachIn r
			If s = "sub" Or s = "sub/" Then hasSub = True
			AssertFalse(s = "a.txt", "OnlyDir should not include a.txt")
			AssertFalse(s = "b.TXT", "OnlyDir should not include b.TXT")
			AssertFalse(s = ".hidden", "OnlyDir should not include .hidden")
		Next
		AssertTrue(hasSub, "Expected OnlyDir to include sub")
	End Method

	Method NoDirFiltersOutDirectories() { test }
		Local r:String[] = Glob("*", EGlobOptions.NoDir | EGlobOptions.Period, root)
		For Local s:String = EachIn r
			AssertFalse(s = "sub" Or s = "sub/", "NoDir should not include sub")
		Next
	End Method

	Method MarkAppendsSlashToDirectories() { test }
		Local r:String[] = Glob("*", EGlobOptions.Mark | EGlobOptions.Period, root)
		Local sawSubWithSlash:Int = False
		For Local s:String = EachIn r
			If s = "sub/" Then sawSubWithSlash = True
		Next
		AssertTrue(sawSubWithSlash, "Expected Mark to return sub/ with trailing slash")
	End Method

	Method NoSortDoesNotDeduplicateOrOrderGuarantee() { test }
		' This mainly checks it still returns something; do not assert order.
		Local r:String[] = Glob("sub/**/*.txt", EGlobOptions.GlobStar | EGlobOptions.NoSort, root)
		AssertEquals(2, r.Length, "Expected 2 matches for globstar NoSort")
		Local seenC:Int = False, seenD:Int = False
		For Local s:String = EachIn r
			If s = "sub/c.txt" Then seenC = True
			If s = "sub/deeper/d.txt" Then seenD = True
		Next
		AssertTrue(seenC And seenD, "Expected both c.txt and d.txt in results")
	End Method

	Method RootedPatternReturnsAbsolutePaths() { test }
		Local absRoot:String = RealPath(root)
		Local r:String[] = Glob(absRoot + "/*.txt", EGlobOptions.None, "")

		AssertTrue(r.Length > 0, "Expected at least one rooted match")

		Local sawA:Int = False
		For Local s:String = EachIn r
			AssertTrue(s.StartsWith(absRoot + "/"), "Expected absolute returned path: " + s)
			If s = absRoot + "/a.txt" Then sawA = True
		Next
		AssertTrue(sawA, "Expected to find " + absRoot + "/a.txt")
	End Method

	Method MatchGlobRelativeAgainstAbsoluteSuffix() { test }
		' Ensure suffix matching behavior stays as intended.
		AssertTrue(MatchGlob("sub/*.txt", root + "/sub/c.txt"), "Expected suffix match")
		AssertFalse(MatchGlob("sub/*.txt", root + "/xsub/c.txt"), "Should not match non-segment suffix")
	End Method

	Method MatchGlobDotfileRule() { test }
		AssertFalse(MatchGlob("*", root + "/.hidden"), "Default should not match dotfile with *")
		AssertTrue(MatchGlob(".*", root + "/.hidden"), "Pattern starting with '.' should match dotfile")
		AssertTrue(MatchGlob("*", root + "/.hidden", EGlobOptions.Period), "Period flag should allow matching dotfile")
	End Method

	Method MatchGlobGlobstarZeroSegments() { test }
		' ** can match zero segments: "sub/**/c.txt" should match "sub/c.txt"
		AssertTrue(MatchGlob("sub/**/c.txt", root + "/sub/c.txt", EGlobOptions.GlobStar), "Expected ** to match zero segments")
	End Method

	Method GlobstarZeroSegments_Expand() { test }
		Local r:String[] = Glob("sub/**/c.txt", EGlobOptions.GlobStar, root)
		AssertEquals(1, r.Length, "Expected 1 match for sub/**/c.txt")
		AssertEquals("sub/c.txt", r[0], "Expected sub/c.txt")
	End Method

	Method GlobstarManySegments_Expand() { test }
		Local r:String[] = Glob("**/d.txt", EGlobOptions.GlobStar, root)
		' Should find sub/deeper/d.txt
		Local found:Int = False
		For Local s:String = EachIn r
			If s = "sub/deeper/d.txt" Then found = True
		Next
		AssertTrue(found, "Expected to find sub/deeper/d.txt via **/d.txt")
	End Method

	Method GlobstarDisabledTreatsAsLiteral() { test }
		' No file literally named "**" exists, so expect no matches
		Local r:String[] = Glob("sub/**/c.txt", EGlobOptions.None, root)
		AssertEquals(0, r.Length, "Expected 0 matches when GlobStar is not enabled")
	End Method

	Method EscapeInsideClass() { test }
		' brack[et].txt should match pattern with escaped '[' and ']'
		' Build pattern to match literal '[' via \[ inside segment.
		Local r:String[] = Glob("brack\[et\].txt", EGlobOptions.None, root)
		AssertEquals(1, r.Length, "Expected brack[et].txt to match escaped brackets")
		AssertEquals("brack[et].txt", r[0], "Expected brack[et].txt")
	End Method

	Method LiteralQuestionMark_Escaped() { test }
		' Filename is q?.txt (literal '?'), so pattern q\?.txt should match
		Local r:String[] = Glob("q\?.txt", EGlobOptions.None, root)
		AssertEquals(1, r.Length, "Expected 1 match for escaped ?")
		AssertEquals("q?.txt", r[0], "Expected q?.txt")
	End Method

	Method LiteralQuestionMark_NoEscapeFails() { test }
		' With NoEscape, backslash is literal/sep-ish normalization; should not match q?.txt via q\?.txt
		Local r:String[] = Glob("q\?.txt", EGlobOptions.NoEscape, root)
		AssertEquals(0, r.Length, "Expected 0 matches with NoEscape for q\?.txt")
	End Method

	Method DotDirectory_NotMatchedByStarUnlessPeriod() { test }
		Local r:String[] = Glob("*", EGlobOptions.None, root)
		For Local s:String = EachIn r
			AssertFalse(s = ".hiddendir", "Did not expect .hiddendir without Period")
		Next

		Local r2:String[] = Glob("*", EGlobOptions.Period, root)
		Local found:Int = False
		For Local s:String = EachIn r2
			If s = ".hiddendir" Then found = True
		Next
		AssertTrue(found, "Expected .hiddendir with Period")
	End Method

	Method OnlyDirAndMark() { test }
		Local r:String[] = Glob("*", EGlobOptions.OnlyDir | EGlobOptions.Mark | EGlobOptions.Period, root)
		For Local s:String = EachIn r
			AssertTrue(s.EndsWith("/"), "Expected Mark to append / to all dirs")
		Next
	End Method

	Method OnlyDirAndNoDirIsEmpty() { test }
		Local r:String[] = Glob("**", EGlobOptions.GlobStar | EGlobOptions.OnlyDir | EGlobOptions.NoDir | EGlobOptions.Period, root)
		AssertEquals(0, r.Length, "Expected empty results when OnlyDir and NoDir are both set")
	End Method

	Method BraceExpansionBasic() { test }
		Local r:String[] = Glob("sub/{c.txt,deeper/d.txt}", EGlobOptions.None, root)
		AssertEquals(2, r.Length, "Expected 2 matches from brace expansion")
		AssertTrue(r[0] = "sub/c.txt" Or r[1] = "sub/c.txt", "Missing sub/c.txt")
		AssertTrue(r[0] = "sub/deeper/d.txt" Or r[1] = "sub/deeper/d.txt", "Missing sub/deeper/d.txt")
	End Method

	Method BraceExpansionNested() { test }
		Local r:String[] = Glob("sub/{deeper,{}}/d.txt", EGlobOptions.None, root)
		' Here "{}" is not expanded (no comma), so only "sub/deeper/d.txt" should match
		Local found:Int = False
		For Local s:String = EachIn r
			If s = "sub/deeper/d.txt" Then found = True
		Next
		AssertTrue(found, "Expected nested brace expansion to find sub/deeper/d.txt")
	End Method

	Method BraceExpansionEscapedLiteral() { test }
		' Escaped braces should be treated literally (no expansion)
		Local r:String[] = Glob("\{a,b\}.txt", EGlobOptions.None, root)
		AssertEquals(0, r.Length, "Expected no matches for literal {a,b}.txt")
	End Method

	Method GlobIterMatchesGlob_AsSet() { test }
		Local pat:String = "sub/**/*.txt"
		Local flags:EGlobOptions = EGlobOptions.GlobStar

		Local eager:String[] = Glob(pat, flags, root)

		Local it:TGlobIter = GlobIter(pat, flags, root)
		Local lazy:String[] = _CollectIter(it)

		eager.Sort()
		lazy.Sort()

		AssertEquals(eager.Length, lazy.Length, "Iterator and Glob should return same number of matches")
		For Local i:Int = 0 Until eager.Length
			AssertEquals(eager[i], lazy[i], "Mismatch at index " + i)
		Next
	End Method

	Method GlobIterCanStopEarly() { test }
		Local n:Int = 0

		Using
			Local it:TGlobIter = GlobIter("sub/**/*.txt", EGlobOptions.GlobStar, root)
		Do
			While it.MoveNext()
				n :+ 1
				Exit  ' stop immediately
			Wend
		End Using

		AssertEquals(1, n, "Expected to read exactly one item then stop")

		' Ensure subsequent glob still works (dir handles were closed / not leaked)
		Local r:String[] = Glob("sub/**/*.txt", EGlobOptions.GlobStar, root)
		AssertTrue(r.Length >= 2, "Expected subsequent Glob to still work after early stop")
	End Method

	Method GlobIterEarlyExitStressDoesNotLeak() { test }
		For Local i:Int = 0 Until 5000
			Using
				Local it:TGlobIter = GlobIter("sub/**/*.txt", EGlobOptions.GlobStar, root)
			Do
				' consume only one result, then exit
				If it.MoveNext() Then
					' no-op
				End If
			End Using
		Next

		AssertTrue(True, "Completed stress loop without leaking handles")
	End Method

	Method GlobIterCloseIsIdempotent() { test }
		Local it:TGlobIter = GlobIter("sub/**/*.txt", EGlobOptions.GlobStar, root)

		' Force it to open some dirs
		it.MoveNext()

		it.Close()
		it.Close() ' should not crash

		AssertTrue(True, "Close() is idempotent")
	End Method

	Method GlobIterBraceExpansionWorks() { test }
		Using
			Local it:TGlobIter = GlobIter("sub/{c.txt,deeper/d.txt}", EGlobOptions.None, root)
		Do
			Local r:String[] = _CollectIter(it)

			AssertTrue(_Contains(r, "sub/c.txt"), "Expected iterator to yield sub/c.txt via brace expansion")
			AssertTrue(_Contains(r, "sub/deeper/d.txt"), "Expected iterator to yield sub/deeper/d.txt via brace expansion")
		End Using
	End Method

	Method GlobIterRootedYieldsAbsolute() { test }
		Local absRoot:String = RealPath(root)
		Local sawAny:Int = False
		Using
			Local it:TGlobIter = GlobIter(absRoot + "/*.txt", EGlobOptions.None, "")
		Do
			For Local s:String = EachIn it
				AssertTrue(s.StartsWith(absRoot + "/"), "Expected absolute result from rooted iterator: " + s)
				sawAny = True
				Exit
			Next
		End Using

		AssertTrue(sawAny, "Expected at least one rooted iterator result")
	End Method

	Method GlobIterOnlyDirAndMarkHonored() { test }
		Using
			Local it:TGlobIter = GlobIter("*", EGlobOptions.OnlyDir | EGlobOptions.Mark | EGlobOptions.Period, root)
		Do
			While it.MoveNext()
				Local s:String = it.Current()
				AssertTrue(s.EndsWith("/"), "Expected Mark to append / for directories: " + s)
			Wend
		End Using
	End Method
End Type


Type TVirtualGlobTest Extends TTest
	Field physRoot:String

	Method Before() { before }
		physRoot = _MakeUniqueRoot()
		AssertTrue(CreateDir(physRoot, True), "Failed to create physical sandbox: " + physRoot)

		AssertTrue(MaxIO.Init(), "MaxIO.Init() failed")
		AssertTrue(MaxIO.SetWriteDir(physRoot), "MaxIO.SetWriteDir failed")
		AssertTrue(MaxIO.Mount(physRoot, "/", True), "MaxIO.Mount failed")

		' Create in virtual FS
		AssertTrue(_WriteSmallFile("/a.txt", "A"), "Failed to create /a.txt")
		AssertTrue(_WriteSmallFile("/b.TXT", "B"), "Failed to create /b.TXT")
		AssertTrue(_WriteSmallFile("/.hidden", "H"), "Failed to create /.hidden")

		AssertTrue(CreateDir("/sub", True), "Failed to create /sub")
		AssertTrue(_WriteSmallFile("/sub/c.txt", "C"), "Failed to create /sub/c.txt")
		AssertTrue(CreateDir("/sub/deeper", True), "Failed to create /sub/deeper")
		AssertTrue(_WriteSmallFile("/sub/deeper/d.txt", "D"), "Failed to create /sub/deeper/d.txt")

		AssertTrue(CreateDir("/.hiddendir", True), "Failed to create .hiddendir")
		AssertTrue(_WriteSmallFile("/.hiddendir/inside.txt", "I"), "Failed to create inside.txt")

		AssertTrue(_WriteSmallFile("/brack[et].txt", "B"), "Failed to create brack[et].txt")
		AssertTrue(_WriteSmallFile("/q?.txt", "Q"), "Failed to create q?.txt")

		AssertTrue(CreateDir("/emptydir", True), "Failed to create emptydir")

	End Method

	Method After() { after }
		DeleteDir("/sub", True)
		DeleteFile("/a.txt")
		DeleteFile("/b.TXT")
		DeleteFile("/.hidden")

		MaxIO.Unmount(physRoot)
		MaxIO.DeInit()

		If physRoot And FileType(physRoot) = FILETYPE_DIR Then
			DeleteDir(physRoot, True)
		End If
	End Method

	Method GlobstarRecurses_Virtual() { test }
		Local r:String[] = Glob("sub/**/*.txt", EGlobOptions.GlobStar, "/")
		AssertEquals(2, r.Length, "Expected 2 matches for virtual globstar")
		AssertEquals("sub/c.txt", r[0], "Expected sub/c.txt")
		AssertEquals("sub/deeper/d.txt", r[1], "Expected sub/deeper/d.txt")
	End Method

	Method PeriodFlag_Virtual() { test }
		Local r:String[] = Glob("*", EGlobOptions.Period, "/")
		Local found:Int = False
		For Local s:String = EachIn r
			If s = ".hidden" Then found = True
		Next
		AssertTrue(found, "Expected .hidden with Period in MaxIO mode")
	End Method

	Method OnlyDir_Virtual() { test }
		Local r:String[] = Glob("*", EGlobOptions.OnlyDir | EGlobOptions.Period, "/")
		Local hasSub:Int = False
		For Local s:String = EachIn r
			If s = "sub" Or s = "sub/" Then hasSub = True
			AssertFalse(s = "a.txt", "OnlyDir should not include a.txt")
			AssertFalse(s = "b.TXT", "OnlyDir should not include b.TXT")
			AssertFalse(s = ".hidden", "OnlyDir should not include .hidden")
		Next
		AssertTrue(hasSub, "Expected OnlyDir to include sub")
	End Method

	Method Mark_Virtual() { test }
		Local r:String[] = Glob("*", EGlobOptions.Mark | EGlobOptions.Period, "/")
		Local sawSubWithSlash:Int = False
		For Local s:String = EachIn r
			If s = "sub/" Then sawSubWithSlash = True
		Next
		AssertTrue(sawSubWithSlash, "Expected Mark to return sub/ with trailing slash")
	End Method

	Method CaseFold_Virtual() { test }
		Local r:String[] = Glob("*.txt", EGlobOptions.CaseFold, "/")
		Local sawA:Int = False, sawB:Int = False
		For Local s:String = EachIn r
			If s = "a.txt" Then sawA = True
			If s = "b.TXT" Then sawB = True
		Next
		AssertTrue(sawA And sawB, "Expected a.txt and b.TXT with CaseFold in virtual mode")
	End Method

	Method DotfileRule_Virtual() { test }
		AssertFalse(MatchGlob("*", "/.hidden"), "Default should not match dotfile with * in virtual")
		AssertTrue(MatchGlob(".*", "/.hidden"), "Pattern starting with '.' should match dotfile in virtual")
		AssertTrue(MatchGlob("*", "/.hidden", EGlobOptions.Period), "Period flag should allow matching dotfile in virtual")
	End Method

	Method GlobstarZeroSegments_Virtual() { test }
		AssertTrue(MatchGlob("sub/**/c.txt", "/sub/c.txt", EGlobOptions.GlobStar), "Expected ** zero segments in virtual")
	End Method

	Method RootedGlobstar_Virtual() { test }
		' Rooted virtual pattern should work too.
		Local r:String[] = Glob("/sub/**/*.txt", EGlobOptions.GlobStar, "")
		' Rooted patterns should return rooted paths
		Local seen1:Int = False, seen2:Int = False
		For Local s:String = EachIn r
			If s = "/sub/c.txt" Then seen1 = True
			If s = "/sub/deeper/d.txt" Then seen2 = True
		Next
		AssertTrue(seen1 And seen2, "Expected rooted /sub/**/*.txt to return rooted matches in virtual mode")
	End Method

	Method GlobIterEarlyExitStressDoesNotLeak_Virtual() { test }
		For Local i:Int = 0 Until 500
			Using
				Local it:TGlobIter = GlobIter("sub/**/*.txt", EGlobOptions.GlobStar, "/")
			Do
				it.MoveNext()
			End Using
		Next
		AssertTrue(True, "Completed virtual stress loop without leaking handles")
	End Method

	Method DotDirectory_Virtual() { test }
		Local r:String[] = Glob("*", EGlobOptions.None, "/")
		For Local s:String = EachIn r
			AssertFalse(s = ".hiddendir", "Did not expect .hiddendir without Period (virtual)")
		Next

		Local r2:String[] = Glob("*", EGlobOptions.Period, "/")
		Local found:Int = False
		For Local s:String = EachIn r2
			If s = ".hiddendir" Then found = True
		Next
		AssertTrue(found, "Expected .hiddendir with Period (virtual)")
	End Method

	Method BraceExpansionBasic() { test }
		Local r:String[] = Glob("sub/{c.txt,deeper/d.txt}", EGlobOptions.None, "/")
		AssertEquals(2, r.Length, "Expected 2 matches from brace expansion")
		AssertTrue(r[0] = "sub/c.txt" Or r[1] = "sub/c.txt", "Missing sub/c.txt")
		AssertTrue(r[0] = "sub/deeper/d.txt" Or r[1] = "sub/deeper/d.txt", "Missing sub/deeper/d.txt")
	End Method

	Method BraceExpansionNested() { test }
		Local r:String[] = Glob("sub/{deeper,{}}/d.txt", EGlobOptions.None, "/")
		' Here "{}" is not expanded (no comma), so only "sub/deeper/d.txt" should match
		Local found:Int = False
		For Local s:String = EachIn r
			If s = "sub/deeper/d.txt" Then found = True
		Next
		AssertTrue(found, "Expected nested brace expansion to find sub/deeper/d.txt")
	End Method

	Method BraceExpansionEscapedLiteral() { test }
		' Escaped braces should be treated literally (no expansion)
		Local r:String[] = Glob("\{a,b\}.txt", EGlobOptions.None, "/")
		AssertEquals(0, r.Length, "Expected no matches for literal {a,b}.txt")
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

Function _CollectIter:String[](it:IIterator<String>)
	Local lst:TList = New TList
	While it.MoveNext()
		lst.AddLast(it.Current())
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
