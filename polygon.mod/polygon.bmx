' ISC License
' 
' Copyright (c) 2023, Bruce A Henderson
' 
' Permission to use, copy, modify, and/or distribute this software for any purpose
' with or without fee is hereby granted, provided that the above copyright notice
' and this permission notice appear in all copies.
' 
' THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
' REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
' FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
' INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
' OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
' TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
' THIS SOFTWARE.
'
SuperStrict

Rem
bbdoc: Polygons
End Rem
Module BRL.Polygon

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: ISC"
ModuleInfo "earcut - Copyright: 2015 mapbox"
ModuleInfo "Copyright: 2023 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

ModuleInfo "CPP_OPTS: -std=c++11"

Import "common.bmx"


Rem
bbdoc: Runs a tesselation against a polygon #SVec2I array, returning a list of triangle indices.
returns: An array of indices that refer to the vertices of the input polygon. Three subsequent indices form a triangle.
End Rem
Function TriangulatePoly:Int[](poly:SVec2I[])
	Return bmx_polygon_tri_svec2i(poly, poly.Length)
End Function

Rem
bbdoc: Runs a tesselation against a polygon #SVec2F array, returning a list of triangle indices.
returns: An array of indices that refer to the vertices of the input polygon. Three subsequent indices form a triangle.
End Rem
Function TriangulatePoly:Int[](poly:SVec2F[])
	Return bmx_polygon_tri_svec2f(poly, poly.Length)
End Function

Rem
bbdoc: Runs a tesselation against a polygon #Float array, returning a list of triangle indices.
returns: An array of indices that refer to the vertices of the input polygon. Three subsequent indices form a triangle.
about: The array consists of pairs of x, y vertices.  Output triangles are clockwise.
End Rem
Function TriangulatePoly:Int[](poly:Float[])
	Return bmx_polygon_tri_svec2f(poly, poly.Length / 2)
End Function
