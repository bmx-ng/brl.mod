' Copyright (c) 2026 Bruce A Henderson
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
' 
SuperStrict

Rem
bbdoc: FileSystem/Glob Pattern Matching
End Rem
Module BRL.Glob

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import BRL.FileSystem
Import BRL.LinkedList

Rem
bbdoc: File globbing options
End Rem
Enum EGlobOptions Flags
	None = 0
	CaseFold = 1 Shl 0
	Period = 1 Shl 1
	GlobStar = 1 Shl 2
	NoEscape = 1 Shl 3
	NoSort = 1 Shl 4
	Mark = 1 Shl 5
	OnlyDir = 1 Shl 6
	NoDir = 1 Shl 7
End Enum

Private

Const _GLOB_BRACE_EXPAND_LIMIT:Int = 4096

Function _RootPath:String( path:String )
	If MaxIO.ioInitialized Then
		Return "/"
	End If
?Win32
	If path.StartsWith( "//" )
		Return path[ ..path.Find( "/",2 )+1 ]
	EndIf
	Local i:Int=path.Find( ":" )
	If i<>-1 And path.Find( "/" )=i+1 Return path[..i+2]
?
	If path.StartsWith( "/" ) Return "/"
End Function

Function _IsRootPath:Int( path:String )
	Return path And _RootPath( path )=path
End Function

Function _IsRealPath:Int( path:String )
	Return _RootPath( path )<>""
End Function

Public


Rem
bbdoc: Performs file globbing.
about:
Expands a glob @pattern into a list of matching files and/or directories.

The glob pattern supports the following constructs:

* `*` matches zero or more characters within a single path segment.
* `?` matches exactly one character within a single path segment.
* Character classes such as `[abc]`, `[a-z]`, and negated classes `[!abc]` or `[^abc]`.
* Backslash escaping of metacharacters (unless the #EGlobOptions.NoEscape flag is set).
* The `**` globstar operator (when #EGlobOptions.GlobStar is enabled) to match zero or more directory levels.

By default, wildcard patterns do not match entries whose names begin with `.`.
This behavior can be changed by enabling the #EGlobOptions.Period flag.

Brace expansion using curly braces is supported.

A pattern of the form `{a,b}` is expanded into multiple patterns before globbing is performed. For example:

* `"src/{core,ui}/*.bmx"` expands to `"src/core/*.bmx"` and `"src/ui/*.bmx"`.

Brace expressions may be nested. Expansion is purely textual and occurs before any wildcard matching.

Only brace expressions containing at least one top-level comma are expanded.
Malformed or unterminated brace expressions are treated as literal text.

Backslash-escaped braces (`\{` and `\}`) are treated literally unless #EGlobOptions.NoEscape is specified.

If @pattern is not rooted, globbing begins relative to @baseDir if supplied,
or the current directory as returned by #CurrentDir.
If @pattern is rooted, @baseDir is ignored and matching begins at the root.

The returned paths are:

* Rooted paths if @pattern is rooted.
* Paths relative to @baseDir (or the current directory) if @pattern is not rooted.

The @flags parameter controls additional matching behavior and result filtering.
See #EGlobOptions for details.

The globbing implementation works consistently for both the native filesystem
and the virtual filesystem when #BRL.Io / #MaxIO is enabled.
End Rem

Function Glob:String[](pattern:String, flags:EGlobOptions = EGlobOptions.None, baseDir:String = "")
	' Normalize pattern in a glob-safe way (preserves escapes)
	pattern = _FixGlobPattern(pattern, flags)

	Local pats:String[] = _ExpandBraces(pattern, flags)

	Local merged:TList = New TList
	For Local p:String = EachIn pats
		Local r:String[] = _GlobOne(p, flags, baseDir)
		For Local s:String = EachIn r
			merged.AddLast(s)
		Next
	Next

	' Convert to array
	Local out:String[] = New String[merged.Count()]
	Local i:Int = 0
	For Local s:String = EachIn merged
		out[i] = s
		i :+ 1
	Next

	' Final sort/unique happens once across all expansions
	If (flags & EGlobOptions.NoSort) <> EGlobOptions.NoSort Then
		_SortStrings(out)
		out = _UniqueSorted(out)
	End If

	Return out
End Function

Rem
bbdoc: Matches a path against a glob pattern.
about:
Checks whether a file path @path matches the glob @pattern.

The matching rules are identical to those used by #Glob, including support for
wildcards (`*`, `?`), character classes (`[ ]`), escaping, and the `**` globstar
operator when #EGlobOptions.GlobStar is enabled.

Brace expansion using curly braces is supported.

Brace expressions such as `{a,b}` are expanded into multiple patterns before
matching is performed. For example, `"sub/{a,b}.txt"` is equivalent to matching
against `"sub/a.txt"` or `"sub/b.txt"`.

Only well-formed brace expressions containing at least one top-level comma are
expanded. Escaped or malformed brace expressions are treated as literal text.

If @pattern does not contain any path separators (`/`), it is matched only against
the final path segment of @path (the file or directory name).

If @pattern contains path separators and is not rooted, it is matched against the
trailing segments of @path. This allows relative patterns such as `"sub/*.txt"`
to match absolute paths like `"/path/to/sub/file.txt"`.

If @pattern is rooted, @path must also be rooted at the same location for a match
to succeed.

The @flags parameter controls matching behavior such as case folding, dotfile
matching, globstar support, and escaping. See #EGlobOptions for details.

This function performs no filesystem access and does not require the path to exist.
End Rem
Function MatchGlob:Int(pattern:String, path:String, flags:EGlobOptions = EGlobOptions.None)
	pattern = _FixGlobPattern(pattern, flags)
	FixPath path

	Local pats:String[] = _ExpandBraces(pattern, flags)
	For Local p:String = EachIn pats
		If _MatchGlobOne(p, path, flags) Then Return True
	Next
	Return False
End Function

Extern
	Function bbFoldChar:Short(c:Short)
End Extern

Private

' match full arrays of segments, consuming all of sSegs
Function _MatchPathSegs:Int(pSegs:String[], sSegs:String[], flags:EGlobOptions)
	Local _pi:Int = 0
	Local _si:Int = 0
	Local starPi:Int = -1
	Local starSi:Int = -1

	While _si < sSegs.Length
		If _pi < pSegs.Length Then
			Local ps:String = pSegs[_pi]

			If ps = "**" And (flags & EGlobOptions.GlobStar) = EGlobOptions.GlobStar Then
				starPi = _pi
				starSi = _si
				_pi :+ 1
				Continue
			End If

			If _MatchSegment(ps, sSegs[_si], flags) Then
				_pi :+ 1
				_si :+ 1
				Continue
			End If
		End If

		' Backtrack to last **
		If starPi <> -1 And (flags & EGlobOptions.GlobStar) = EGlobOptions.GlobStar Then
			starSi :+ 1
			_si = starSi
			_pi = starPi + 1
			Continue
		End If

		Return False
	Wend

	' Consume trailing ** in pattern
	While _pi < pSegs.Length
		If pSegs[_pi] = "**" And (flags & EGlobOptions.GlobStar) = EGlobOptions.GlobStar Then
			_pi :+ 1
		Else
			Exit
		End If
	Wend

	Return _pi = pSegs.Length
End Function

' Returns True if seg contains glob metacharacters that require matching/enumeration.
Function _HasMeta:Int(seg:String, flags:EGlobOptions)
	Local i:Int = 0
	While i < seg.Length
		Local c:Int = seg[i]

		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") Then
			' Skip escaped character, if any
			i :+ 2
			Continue
		End If

		Select c
			Case Asc("*"), Asc("?"), Asc("[")
				Return True
		End Select

		i :+ 1
	Wend
	Return False
End Function

Function _Fold:Int(c:Int) Inline
	' Only fold when the input is a valid UTF-16 code unit range.
	' (We never want to fold negative sentinel values.)
	If c < 0 Then
		Return c
	End If
	Return bbFoldChar(Short(c)) & $FFFF
End Function

Function _CharEq:Int(a:Int, b:Int, flags:EGlobOptions) Inline
	If (flags & EGlobOptions.CaseFold) = EGlobOptions.CaseFold Then
		a = _Fold(a)
		b = _Fold(b)
	End If
	Return a = b
End Function

' Matches a single path segment (no '/').
' Supports *, ?, [..], escapes (unless NoEscape), CaseFold, Period dotfile rule.
Function _MatchSegment:Int(pat:String, name:String, flags:EGlobOptions)
	' Dotfile rule: if name begins with '.' and Period is NOT set,
	' the pattern must begin with a literal '.' (or escaped '.').
	If name.Length > 0 And name[0] = Asc(".") And (flags & EGlobOptions.Period) <> EGlobOptions.Period Then
		If pat.Length = 0 Then
			Return False
		End If

		If pat[0] = Asc(".") Then
			' ok
		ElseIf (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And pat[0] = Asc("\") And pat.Length > 1 And pat[1] = Asc(".") Then
			' ok (escaped dot)
		Else
			Return False
		End If
	End If

	Local p:Int = 0
	Local n:Int = 0
	Local starP:Int = -1
	Local starN:Int = -1

	While n < name.Length
		If p < pat.Length Then
			Local pc:Int = pat[p]

			' Escaped literal
			If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And pc = Asc("\") And (p + 1) < pat.Length Then
				p :+ 1
				pc = pat[p]

				If _CharEq(pc, name[n], flags) Then
					p :+ 1; n :+ 1
					Continue
				End If

			' Single char wildcard
			ElseIf pc = Asc("?") Then
				p :+ 1; n :+ 1
				Continue

			' Star wildcard
			ElseIf pc = Asc("*") Then
				starP = p
				p :+ 1
				starN = n
				Continue

			' Character class
			ElseIf pc = Asc("[") Then
				Local nextP:Int
				If _MatchClass(pat, p, name[n], flags, nextP) And nextP <> -1 Then
					p = nextP
					n :+ 1
					Continue
				ElseIf nextP = -1 Then
					' Invalid class: treat '[' literally below
				Else
					' Valid class but didn't match: fall through to backtracking
				End If
			End If

			' Literal compare
			If _CharEq(pc, name[n], flags) Then
				p :+ 1; n :+ 1
				Continue
			End If
		End If

		' Mismatch: try to backtrack to last '*'
		If starP <> -1 Then
			starN :+ 1
			n = starN
			p = starP + 1
			Continue
		End If

		Return False
	Wend

	' Consume trailing '*' in pattern
	While p < pat.Length And pat[p] = Asc("*")
		p :+ 1
	Wend

	Return p = pat.Length
End Function

Function _MatchClass:Int(pat:String, start:Int, ch:Int, flags:EGlobOptions, nextIndex:Int Var)
	nextIndex = -1

	Local i:Int = start + 1
	If i >= pat.Length Then
		Return False
	End If

	' Negation: [!...] or [^...]
	Local neg:Int = False
	Local c0:Int = pat[i]
	If c0 = Asc("!") Or c0 = Asc("^") Then
		neg = True
		i :+ 1
	End If

	Local matched:Int = False
	Local firstInClass:Int = True
	Local prev:Int = -1 ' prev is only valid when havePrev=True and prev >= 0
	Local havePrev:Int = False

	' Special-case: leading ']' can be literal in many glob implementations: "[]a]"
	' Allow ']' as a literal if it appears first after optional negation.
	While i < pat.Length
		Local c:Int = pat[i]

		' End of class?
		If c = Asc("]") And Not firstInClass Then
			nextIndex = i + 1
			If neg Then
				matched = Not matched
			End If
			Return matched
		End If

		' Handle escape inside class (if enabled)
		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") And i + 1 < pat.Length Then
			i :+ 1
			c = pat[i]
		End If

		' Range handling: prev '-' next
		' Only treat '-' as range operator when it has a previous char and a following char
		' and it isn't the first unescaped char in the class.
		If c = Asc("-") And havePrev And (i + 1) < pat.Length Then
			' Peek next (respect escape)
			Local j:Int = i + 1
			Local nxt:Int = pat[j]
			If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And nxt = Asc("\") And (j + 1) < pat.Length Then
				j :+ 1
				nxt = pat[j]
			End If

			' A '-' right before ']' is treated literally: [a-]
			If nxt <> Asc("]") And prev >= 0 Then
				Local lo:Int = prev
				Local hi:Int = nxt
				Local chv:Int = ch

				If (flags & EGlobOptions.CaseFold) = EGlobOptions.CaseFold Then
					lo = _Fold(lo)
					hi = _Fold(hi)
					chv = _Fold(chv)
				End If

				If lo <= hi Then
					If chv >= lo And chv <= hi Then
						matched = True
					End If
				End If

				' Consume range end
				i = j
				prev = -1
				havePrev = False
				firstInClass = False
				i :+ 1
				Continue
			End If
		End If

		' Compare literal char in class
		Local cc:Int = c
		Local nch:Int = ch
		If (flags & EGlobOptions.CaseFold) = EGlobOptions.CaseFold Then
			cc = _Fold(cc)
			nch = _Fold(nch)
		End If

		If cc = nch Then matched = True

		prev = c
		havePrev = True
		firstInClass = False
		i :+ 1
	Wend

	' No closing ']': invalid class
	nextIndex = -1
	Return False
End Function

Function _IsSep:Int(c:Int) Inline
	Return c = Asc("/")
End Function

Function _SplitSegments:String[](path:String)
	' path is expected to be FixPath-normalized and NOT include the root prefix (if rooted patterns)
	If path = "" Then
		Return New String[0]
	End If

	Local parts:String[] = New String[0]
	Local start:Int = 0
	Local i:Int = 0

	While i <= path.Length
		If i = path.Length Or path[i] = Asc("/") Then
			If i > start Then
				Local seg:String = path[start..i]
				' ignore empty segments
				parts = parts[..parts.Length + 1]
				parts[parts.Length - 1] = seg
			End If
			start = i + 1
		End If
		i :+ 1
	Wend

	Return parts
End Function

Function _JoinPath:String(a:String, b:String)
	If a = "" Then
		Return b
	End If
	If a.EndsWith("/") Then
		Return a + b
	End If
	Return a + "/" + b
End Function

Function _IsMetaSegment:Int(seg:String, flags:EGlobOptions) Inline
	' ** is treated specially by caller
	Return _HasMeta(seg, flags)
End Function

Function _EmitOk:Int(path:String, flags:EGlobOptions)
	Local ft:Int = FileType(path)
	If ft = FILETYPE_NONE Then
		Return False
	End If

	If (flags & EGlobOptions.OnlyDir) = EGlobOptions.OnlyDir And ft <> FILETYPE_DIR Then
		Return False
	End If

	If (flags & EGlobOptions.NoDir) = EGlobOptions.NoDir And ft = FILETYPE_DIR Then
		Return False
	End If

	Return True
End Function

Function _MaybeMark:String(path:String, flags:EGlobOptions)
	If (flags & EGlobOptions.Mark) <> EGlobOptions.Mark Then
		Return path
	End If
	If FileType(path) = FILETYPE_DIR And Not path.EndsWith("/") Then
		Return path + "/"
	End If
	Return path
End Function

Function _StripPrefix:String(path:String, prefix:String)
	' If path starts with prefix + "/", strip that.
	' prefix should be normalized and without trailing slash unless root.
	If prefix = "" Then
		Return path
	End If

	Local p:String = prefix
	If Not p.EndsWith("/") Then
		p :+ "/"
	End If

	If path.StartsWith(p) Then
		Return path[p.Length..]
	End If

	' If exact match, return empty (caller can decide what to do)
	If path = prefix Then
		Return ""
	End If
	Return path
End Function

Function _SortStrings(arr:String[])
	If arr.Length <= 1 Then
		Return
	End If
	arr.Sort()
End Function

Function _UniqueSorted:String[](arr:String[])
	If arr.Length <= 1 Then
		Return arr
	End If
	Local out:String[] = New String[arr.Length]
	Local n:Int = 0
	Local last:String = Chr(0) ' something that can't equal a normal path
	For Local i:Int = 0 Until arr.Length
		If i = 0 Or arr[i] <> last Then
			out[n] = arr[i]
			n :+ 1
			last = arr[i]
		End If
	Next
	Return out[..n]
End Function

Function _ExpandGlob(results:TList, base:String, segs:String[], idx:Int, flags:EGlobOptions)
	If idx = segs.Length Then
		If _EmitOk(base, flags) Then
			results.AddLast(_MaybeMark(base, flags))
		End If
		Return
	End If

	Local seg:String = segs[idx]

	' Globstar
	If seg = "**" And (flags & EGlobOptions.GlobStar) = EGlobOptions.GlobStar Then
		' Option: match zero segments
		_ExpandGlob(results, base, segs, idx + 1, flags)

		' Option: match one+ directories
		If FileType(base) <> FILETYPE_DIR Then
			Return
		End If

		Local d:Byte Ptr = ReadDir(base)
		If Not d Then
			Return
		End If

		While True
			Local f:String = NextFile(d)
			If Not f Exit
			If f = "." Or f = ".." Then
				Continue
			End If

			Local p:String = _JoinPath(base, f)
			If FileType(p) = FILETYPE_DIR Then
				_ExpandGlob(results, p, segs, idx, flags)
			End If
		Wend
		CloseDir(d)
		Return
	End If

	' Fast path: no metas in this segment
	If Not _IsMetaSegment(seg, flags) Then
		Local litSeg:String = _UnescapeGlobLiteral(seg, flags)
		Local nextPath:String = _JoinPath(base, litSeg)
		If idx < segs.Length - 1 Then
			If FileType(nextPath) = FILETYPE_DIR Then
				_ExpandGlob(results, nextPath, segs, idx + 1, flags)
			End If
		Else
			_ExpandGlob(results, nextPath, segs, idx + 1, flags)
		End If
		Return
	End If

	' Meta segment: enumerate
	If FileType(base) <> FILETYPE_DIR Then
		Return
	End If

	Local dir:Byte Ptr = ReadDir(base)
	If Not dir Then
		Return
	End If

	While True
		Local name:String = NextFile(dir)
		If Not name Exit
		If name = "." Or name = ".." Then
			Continue
		End If

		If _MatchSegment(seg, name, flags) Then
			Local p:String = _JoinPath(base, name)
			If idx < segs.Length - 1 Then
				If FileType(p) = FILETYPE_DIR Then
					_ExpandGlob(results, p, segs, idx + 1, flags)
				End If
			Else
				_ExpandGlob(results, p, segs, idx + 1, flags)
			End If
		End If
	Wend

	CloseDir(dir)
End Function

Function _FixGlobPattern:String(pat:String, flags:EGlobOptions)
	' Normalize separators to "/", but preserve backslash escapes
	' when NoEscape is NOT set and the next char is a glob meta or backslash.

	If pat = "" Then
		Return pat
	End If

	Local out:String = ""
	Local i:Int = 0

	While i < pat.Length
		Local c:Int = pat[i]

		If c = Asc("\") Then
			If (flags & EGlobOptions.NoEscape) = EGlobOptions.NoEscape Then
				' NoEscape: treat "\" like a path separator for normalization
				out :+ "/"
				i :+ 1
				Continue
			End If

			' Escape mode: preserve "\" when escaping a meta char or "\" itself
			If i + 1 < pat.Length Then
				Local n:Int = pat[i + 1]
				If n = Asc("*") Or n = Asc("?") Or n = Asc("[") Or n = Asc("]") Or n = Asc("\") Or n = Asc("{") Or n = Asc("}") Then
					out :+ "\"
					out :+ Chr(n)
					i :+ 2
					Continue
				End If
			End If

			' Otherwise treat "\" as a path separator
			out :+ "/"
			i :+ 1
			Continue
		End If

		out :+ Chr(c)
		i :+ 1
	Wend

	Return out
End Function

Function _UnescapeGlobLiteral:String(seg:String, flags:EGlobOptions)
	' Remove backslash escaping when escapes are enabled.
	' Example: "star\*.txt" -> "star*.txt"
	If (flags & EGlobOptions.NoEscape) = EGlobOptions.NoEscape Then
		Return seg
	End If

	Local out:String = ""
	Local i:Int = 0
	While i < seg.Length
		Local c:Int = seg[i]
		If c = Asc("\") And (i + 1) < seg.Length Then
			' Drop the backslash, keep the next character literally
			i :+ 1
			out :+ Chr(seg[i])
			i :+ 1
		Else
			out :+ Chr(c)
			i :+ 1
		End If
	Wend
	Return out
End Function

Function _ExpandBraces:String[](pattern:String, flags:EGlobOptions)
	' Returns all brace-expanded patterns (or [pattern] if none expand)
	Local lst:TList = New TList
	Local count:Int = 0
	_ExpandBracesToList(lst, pattern, flags, count)

	Local out:String[] = New String[lst.Count()]
	Local i:Int = 0
	For Local s:String = EachIn lst
		out[i] = s
		i :+ 1
	Next
	Return out
End Function

Function _ExpandBracesToList(results:TList, pat:String, flags:EGlobOptions, count:Int Var)
	' Recursively expands braces into results.
	' count tracks number of emitted patterns for explosion control.

	If count >= _GLOB_BRACE_EXPAND_LIMIT Then
		' Stop expanding further; treat remaining braces literally
		results.AddLast(pat)
		count :+ 1
		Return
	End If

	Local openIndex:Int, closeIndex:Int
	If Not _FindFirstBrace(pat, flags, openIndex, closeIndex) Then
		results.AddLast(pat)
		count :+ 1
		Return
	End If

	Local prefix:String = pat[..openIndex]
	Local inner:String = pat[openIndex + 1 .. closeIndex]
	Local suffix:String = pat[closeIndex + 1 ..]

	' If there is no top-level comma, do NOT expand; treat as literal braces.
	If Not _BraceHasTopLevelComma(inner, flags) Then
		' Continue scanning after this brace pair by expanding the suffix part recursively.
		' Easiest: replace the first "{...}" with itself and expand braces in the suffix.
		' This maintains correct behavior for patterns like "a{b}c{d,e}".
		Local nextPat:String = prefix + "{" + inner + "}" + suffix

		' To avoid infinite loops, skip past this brace by temporarily masking it:
		' We'll expand braces in the suffix by searching from after the close brace.
		' Simple approach: expand braces in suffix only, then rejoin.
		Local suffixExp:TList = New TList
		Local tmpCount:Int = 0
		_ExpandBracesToList(suffixExp, suffix, flags, tmpCount)

		For Local s:String = EachIn suffixExp
			If count >= _GLOB_BRACE_EXPAND_LIMIT Then Exit
			results.AddLast(prefix + "{" + inner + "}" + s)
			count :+ 1
		Next
		Return
	End If

	' Expand
	Local opts:String[] = _SplitTopLevelCommas(inner, flags)
	For Local opt:String = EachIn opts
		If count >= _GLOB_BRACE_EXPAND_LIMIT Then Exit
		_ExpandBracesToList(results, prefix + opt + suffix, flags, count)
	Next
End Function

Function _SplitTopLevelCommas:String[](inner:String, flags:EGlobOptions)
	' Splits "a,{b,c},d" -> ["a", "{b,c}", "d"] (only top-level commas)
	Local parts:TList = New TList
	Local depth:Int = 0
	Local start:Int = 0
	Local i:Int = 0

	While i <= inner.Length
		If i = inner.Length Then
			parts.AddLast(inner[start..i])
			Exit
		End If

		Local c:Int = inner[i]

		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") Then
			i :+ 2
			Continue
		End If

		If c = Asc("{") Then
			depth :+ 1
		ElseIf c = Asc("}") Then
			If depth > 0 Then depth :- 1
		ElseIf c = Asc(",") And depth = 0 Then
			parts.AddLast(inner[start..i])
			start = i + 1
		End If

		i :+ 1
	Wend

	Local out:String[] = New String[parts.Count()]
	Local n:Int = 0
	For Local s:String = EachIn parts
		out[n] = s
		n :+ 1
	Next
	Return out
End Function

Function _BraceHasTopLevelComma:Int(inner:String, flags:EGlobOptions)
	' Returns True if inner contains a comma at nesting depth 0 (escape-aware)
	Local depth:Int = 0
	Local i:Int = 0
	While i < inner.Length
		Local c:Int = inner[i]

		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") Then
			i :+ 2
			Continue
		End If

		If c = Asc("{") Then
			depth :+ 1
		ElseIf c = Asc("}") Then
			If depth > 0 Then depth :- 1
		ElseIf c = Asc(",") And depth = 0 Then
			Return True
		End If

		i :+ 1
	Wend
	Return False
End Function

Function _IsEscaped:Int(s:String, i:Int, flags:EGlobOptions)
	' True if s[i] is escaped by a preceding backslash (when escaping is enabled)
	If (flags & EGlobOptions.NoEscape) = EGlobOptions.NoEscape Then Return False
	If i <= 0 Then Return False
	Return s[i - 1] = Asc("\")
End Function

Function _FindFirstBrace:Int(pat:String, flags:EGlobOptions, openIndex:Int Var, closeIndex:Int Var)
	' Finds the first unescaped '{' and its matching unescaped '}' (with nesting),
	' returning True if found, else False.
	openIndex = -1
	closeIndex = -1

	Local i:Int = 0
	While i < pat.Length
		Local c:Int = pat[i]

		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") Then
			i :+ 2
			Continue
		End If

		If c = Asc("{") Then
			openIndex = i
			Exit
		End If

		i :+ 1
	Wend

	If openIndex = -1 Then Return False

	' Find matching close brace
	Local depth:Int = 0
	i = openIndex
	While i < pat.Length
		Local c:Int = pat[i]

		If (flags & EGlobOptions.NoEscape) <> EGlobOptions.NoEscape And c = Asc("\") Then
			i :+ 2
			Continue
		End If

		If c = Asc("{") Then
			depth :+ 1
		ElseIf c = Asc("}") Then
			depth :- 1
			If depth = 0 Then
				closeIndex = i
				Return True
			End If
		End If

		i :+ 1
	Wend

	' No matching close brace
	openIndex = -1
	closeIndex = -1
	Return False
End Function

Function _GlobOne:String[](pattern:String, flags:EGlobOptions = EGlobOptions.None, baseDir:String = "")
	pattern = _FixGlobPattern(pattern, flags)

	Local start:String
	Local root:String = ""
	Local rooted:Int = False

	If MaxIO.ioInitialized Then
		rooted = pattern.StartsWith("/")
		If rooted Then
			root = "/"
		End If
	Else
		root = _RootPath(pattern)
		rooted = (root <> "")
	End If

	Local remainder:String = pattern

	If rooted Then
		start = root
		remainder = pattern[root.Length..]
	Else
		If baseDir <> "" Then
			start = baseDir
			FixPath start, True
		Else
			start = CurrentDir()
		End If
	End If

	' Normalize start: do not strip slash for roots
	FixPath start, True
	If Not _IsRootPath(start) Then
		start = StripSlash(start)
	End If

	' If pattern is rooted, ensure start is exactly the root path (already has trailing slash sometimes)
	If rooted Then
		start = root
		FixPath start, True
		If Not _IsRootPath(start) Then
			start = StripSlash(start)
		End If
	End If

	' Split into segments (ignore empty)
	Local segs:String[] = _SplitSegments(remainder)

	Local results:TList = New TList

	' Special case: pattern with no segments => match start itself
	If segs.Length = 0 Then
		If _EmitOk(start, flags) Then
			results.AddLast(_MaybeMark(start, flags))
		End If
	Else
		_ExpandGlob(results, start, segs, 0, flags)
	End If

	' Convert to array
	Local out:String[] = New String[results.Count()]
	Local i:Int = 0
	For Local s:String = EachIn results
		out[i] = s
		i :+ 1
	Next

	' ' Sorting + uniq
	' If (flags & EGlobOptions.NoSort) <> EGlobOptions.NoSort Then
	' 	_SortStrings(out)
	' 	out = _UniqueSorted(out)
	' End If

	' If not rooted, return paths relative to start (baseDir or CurrentDir)
	If Not rooted Then
		For i = 0 Until out.Length
			Local raw:String = out[i]
			' preserve Mark suffix if present
			Local marked:Int = raw.EndsWith("/")
			Local p:String = raw
			If marked Then
				p = raw[..raw.Length - 1]
			End If

			Local rel:String = _StripPrefix(p, start)
			If marked And rel <> "" And Not rel.EndsWith("/") Then
				rel :+ "/"
			End If
			out[i] = rel
		Next
	End If

	Return out
End Function

Function _MatchGlobOne:Int(pattern:String, path:String, flags:EGlobOptions = EGlobOptions.None)
	pattern = _FixGlobPattern(pattern, flags)
	FixPath path

	' If pattern has no '/', match just the filename part
	If pattern.Find("/") = -1 Then
		Return _MatchSegment(pattern, StripDir(path), flags)
	End If

	' Root handling: rooted patterns must match rooted paths from the same root
	Local root:String = ""
	If MaxIO.ioInitialized Then
		If pattern.StartsWith("/") Then
			root = "/"
		End If
	Else
		root = _RootPath(pattern)
	End If

	If root <> "" Then
		If Not path.StartsWith(root) Then
			Return False
		End If
		pattern = pattern[root.Length..]
		path = path[root.Length..]
		Local pSegs:String[] = _SplitSegments(pattern)
		Local sSegs:String[] = _SplitSegments(path)
		Return _MatchPathSegs(pSegs, sSegs, flags)
	End If

	' Pattern is NOT rooted.
	' If path is rooted, we match against a suffix of the path (end-anchored),
	' so "sub/*.txt" matches "/x/y/sub/c.txt".
	Local pathRoot:String = _RootPath(path)
	If pathRoot <> "" Then
		path = path[pathRoot.Length..]
	End If

	Local pSegs:String[] = _SplitSegments(pattern)
	Local sSegs:String[] = _SplitSegments(path)

	' If no globstar, only need to check the end-aligned window.
	If (flags & EGlobOptions.GlobStar) <> EGlobOptions.GlobStar Then
		If pSegs.Length > sSegs.Length Then
			Return False
		End If
		Local start:Int = sSegs.Length - pSegs.Length
		Local window:String[] = sSegs[start..]
		Return _MatchPathSegs(pSegs, window, flags)
	End If

	' With globstar, try matching pattern starting at any segment boundary,
	' but require the match to consume to the end (suffix match).
	For Local start:Int = 0 Until sSegs.Length + 1
		Local window:String[] = sSegs[start..]
		If _MatchPathSegs(pSegs, window, flags) Then
			Return True
		End If
	Next

	Return False
End Function
