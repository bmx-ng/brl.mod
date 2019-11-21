SuperStrict

Framework brl.standardio
Import brl.color
Import BRL.MaxUnit

New TTestSuite.run()

Type TColorTest Extends TTest

	Method TestToHSL() { test }
		Local h:Float, s:Float, l:Float
		SColor8.Red.ToHSL(h, s, l)
		AssertEquals(0, h)
		AssertEquals(1, s)
		AssertEquals(0.5, l)

		SColor8.Green.ToHSL(h, s, l)
		AssertEquals(120, h)
		AssertEquals(1, s)
		AssertEquals(0.5, l)

		SColor8.Blue.ToHSL(h, s, l)
		AssertEquals(240, h)
		AssertEquals(1, s)
		AssertEquals(0.5, l)

		SColor8.LightGrey.ToHSL(h, s, l)
		AssertEquals(0, h)
		AssertEquals(0, s)
		AssertEquals(0.827, l, 0.001)
	End Method

	Method TestToHSV() { test }
		Local h:Float, s:Float, v:Float
		SColor8.Red.ToHSV(h, s, v)
		AssertEquals(0, h)
		AssertEquals(1, s)
		AssertEquals(1, v)
	End Method

	'\tMethod TestGlobalColors\1\(\) {test}\n\t\tAssertEquals\($FF\2\3\4, SColor8.\1.ToRGBA\(\)\)\n\t\tAssertEquals\($\2, SColor8.\1.r\)\n\t\tAssertEquals\($\3, SColor8.\1.g\)\n\t\tAssertEquals\($\4, SColor8.\1.b\)\n\t\tAssertEquals\($FF, SColor8.\1.a\)\n\tEnd Method\n

	Method TestGlobalColorsAliceBlue() {test}
		AssertEquals($FFF0F8FF, SColor8.AliceBlue.ToRGBA())
		AssertEquals($F0, SColor8.AliceBlue.r)
		AssertEquals($F8, SColor8.AliceBlue.g)
		AssertEquals($FF, SColor8.AliceBlue.b)
		AssertEquals($FF, SColor8.AliceBlue.a)
	End Method

	Method TestGlobalColorsAntiqueWhite() {test}
		AssertEquals($FFFAEBD7, SColor8.AntiqueWhite.ToRGBA())
		AssertEquals($FA, SColor8.AntiqueWhite.r)
		AssertEquals($EB, SColor8.AntiqueWhite.g)
		AssertEquals($D7, SColor8.AntiqueWhite.b)
		AssertEquals($FF, SColor8.AntiqueWhite.a)
	End Method

	Method TestGlobalColorsAqua() {test}
		AssertEquals($FF00FFFF, SColor8.Aqua.ToRGBA())
		AssertEquals($00, SColor8.Aqua.r)
		AssertEquals($FF, SColor8.Aqua.g)
		AssertEquals($FF, SColor8.Aqua.b)
		AssertEquals($FF, SColor8.Aqua.a)
	End Method

	Method TestGlobalColorsAquamarine() {test}
		AssertEquals($FF7FFFD4, SColor8.Aquamarine.ToRGBA())
		AssertEquals($7F, SColor8.Aquamarine.r)
		AssertEquals($FF, SColor8.Aquamarine.g)
		AssertEquals($D4, SColor8.Aquamarine.b)
		AssertEquals($FF, SColor8.Aquamarine.a)
	End Method

	Method TestGlobalColorsAzure() {test}
		AssertEquals($FFF0FFFF, SColor8.Azure.ToRGBA())
		AssertEquals($F0, SColor8.Azure.r)
		AssertEquals($FF, SColor8.Azure.g)
		AssertEquals($FF, SColor8.Azure.b)
		AssertEquals($FF, SColor8.Azure.a)
	End Method

	Method TestGlobalColorsBeige() {test}
		AssertEquals($FFF5F5DC, SColor8.Beige.ToRGBA())
		AssertEquals($F5, SColor8.Beige.r)
		AssertEquals($F5, SColor8.Beige.g)
		AssertEquals($DC, SColor8.Beige.b)
		AssertEquals($FF, SColor8.Beige.a)
	End Method

	Method TestGlobalColorsBisque() {test}
		AssertEquals($FFFFE4C4, SColor8.Bisque.ToRGBA())
		AssertEquals($FF, SColor8.Bisque.r)
		AssertEquals($E4, SColor8.Bisque.g)
		AssertEquals($C4, SColor8.Bisque.b)
		AssertEquals($FF, SColor8.Bisque.a)
	End Method

	Method TestGlobalColorsBlack() {test}
		AssertEquals($FF000000, SColor8.Black.ToRGBA())
		AssertEquals($00, SColor8.Black.r)
		AssertEquals($00, SColor8.Black.g)
		AssertEquals($00, SColor8.Black.b)
		AssertEquals($FF, SColor8.Black.a)
	End Method

	Method TestGlobalColorsBlanchedAlmond() {test}
		AssertEquals($FFFFEBCD, SColor8.BlanchedAlmond.ToRGBA())
		AssertEquals($FF, SColor8.BlanchedAlmond.r)
		AssertEquals($EB, SColor8.BlanchedAlmond.g)
		AssertEquals($CD, SColor8.BlanchedAlmond.b)
		AssertEquals($FF, SColor8.BlanchedAlmond.a)
	End Method

	Method TestGlobalColorsBlue() {test}
		AssertEquals($FF0000FF, SColor8.Blue.ToRGBA())
		AssertEquals($00, SColor8.Blue.r)
		AssertEquals($00, SColor8.Blue.g)
		AssertEquals($FF, SColor8.Blue.b)
		AssertEquals($FF, SColor8.Blue.a)
	End Method

	Method TestGlobalColorsBlueViolet() {test}
		AssertEquals($FF8A2BE2, SColor8.BlueViolet.ToRGBA())
		AssertEquals($8A, SColor8.BlueViolet.r)
		AssertEquals($2B, SColor8.BlueViolet.g)
		AssertEquals($E2, SColor8.BlueViolet.b)
		AssertEquals($FF, SColor8.BlueViolet.a)
	End Method

	Method TestGlobalColorsBrown() {test}
		AssertEquals($FFA52A2A, SColor8.Brown.ToRGBA())
		AssertEquals($A5, SColor8.Brown.r)
		AssertEquals($2A, SColor8.Brown.g)
		AssertEquals($2A, SColor8.Brown.b)
		AssertEquals($FF, SColor8.Brown.a)
	End Method

	Method TestGlobalColorsBurlyWood() {test}
		AssertEquals($FFDEB887, SColor8.BurlyWood.ToRGBA())
		AssertEquals($DE, SColor8.BurlyWood.r)
		AssertEquals($B8, SColor8.BurlyWood.g)
		AssertEquals($87, SColor8.BurlyWood.b)
		AssertEquals($FF, SColor8.BurlyWood.a)
	End Method

	Method TestGlobalColorsCadetBlue() {test}
		AssertEquals($FF5F9EA0, SColor8.CadetBlue.ToRGBA())
		AssertEquals($5F, SColor8.CadetBlue.r)
		AssertEquals($9E, SColor8.CadetBlue.g)
		AssertEquals($A0, SColor8.CadetBlue.b)
		AssertEquals($FF, SColor8.CadetBlue.a)
	End Method

	Method TestGlobalColorsChartreuse() {test}
		AssertEquals($FF7FFF00, SColor8.Chartreuse.ToRGBA())
		AssertEquals($7F, SColor8.Chartreuse.r)
		AssertEquals($FF, SColor8.Chartreuse.g)
		AssertEquals($00, SColor8.Chartreuse.b)
		AssertEquals($FF, SColor8.Chartreuse.a)
	End Method

	Method TestGlobalColorsChocolate() {test}
		AssertEquals($FFD2691E, SColor8.Chocolate.ToRGBA())
		AssertEquals($D2, SColor8.Chocolate.r)
		AssertEquals($69, SColor8.Chocolate.g)
		AssertEquals($1E, SColor8.Chocolate.b)
		AssertEquals($FF, SColor8.Chocolate.a)
	End Method

	Method TestGlobalColorsCoral() {test}
		AssertEquals($FFFF7F50, SColor8.Coral.ToRGBA())
		AssertEquals($FF, SColor8.Coral.r)
		AssertEquals($7F, SColor8.Coral.g)
		AssertEquals($50, SColor8.Coral.b)
		AssertEquals($FF, SColor8.Coral.a)
	End Method

	Method TestGlobalColorsCornflowerBlue() {test}
		AssertEquals($FF6495ED, SColor8.CornflowerBlue.ToRGBA())
		AssertEquals($64, SColor8.CornflowerBlue.r)
		AssertEquals($95, SColor8.CornflowerBlue.g)
		AssertEquals($ED, SColor8.CornflowerBlue.b)
		AssertEquals($FF, SColor8.CornflowerBlue.a)
	End Method

	Method TestGlobalColorsCornsilk() {test}
		AssertEquals($FFFFF8DC, SColor8.Cornsilk.ToRGBA())
		AssertEquals($FF, SColor8.Cornsilk.r)
		AssertEquals($F8, SColor8.Cornsilk.g)
		AssertEquals($DC, SColor8.Cornsilk.b)
		AssertEquals($FF, SColor8.Cornsilk.a)
	End Method

	Method TestGlobalColorsCrimson() {test}
		AssertEquals($FFDC143C, SColor8.Crimson.ToRGBA())
		AssertEquals($DC, SColor8.Crimson.r)
		AssertEquals($14, SColor8.Crimson.g)
		AssertEquals($3C, SColor8.Crimson.b)
		AssertEquals($FF, SColor8.Crimson.a)
	End Method

	Method TestGlobalColorsCyan() {test}
		AssertEquals($FF00FFFF, SColor8.Cyan.ToRGBA())
		AssertEquals($00, SColor8.Cyan.r)
		AssertEquals($FF, SColor8.Cyan.g)
		AssertEquals($FF, SColor8.Cyan.b)
		AssertEquals($FF, SColor8.Cyan.a)
	End Method

	Method TestGlobalColorsDarkBlue() {test}
		AssertEquals($FF00008B, SColor8.DarkBlue.ToRGBA())
		AssertEquals($00, SColor8.DarkBlue.r)
		AssertEquals($00, SColor8.DarkBlue.g)
		AssertEquals($8B, SColor8.DarkBlue.b)
		AssertEquals($FF, SColor8.DarkBlue.a)
	End Method

	Method TestGlobalColorsDarkCyan() {test}
		AssertEquals($FF008B8B, SColor8.DarkCyan.ToRGBA())
		AssertEquals($00, SColor8.DarkCyan.r)
		AssertEquals($8B, SColor8.DarkCyan.g)
		AssertEquals($8B, SColor8.DarkCyan.b)
		AssertEquals($FF, SColor8.DarkCyan.a)
	End Method

	Method TestGlobalColorsDarkGoldenRod() {test}
		AssertEquals($FFB8860B, SColor8.DarkGoldenRod.ToRGBA())
		AssertEquals($B8, SColor8.DarkGoldenRod.r)
		AssertEquals($86, SColor8.DarkGoldenRod.g)
		AssertEquals($0B, SColor8.DarkGoldenRod.b)
		AssertEquals($FF, SColor8.DarkGoldenRod.a)
	End Method

	Method TestGlobalColorsDarkGray() {test}
		AssertEquals($FFA9A9A9, SColor8.DarkGray.ToRGBA())
		AssertEquals($A9, SColor8.DarkGray.r)
		AssertEquals($A9, SColor8.DarkGray.g)
		AssertEquals($A9, SColor8.DarkGray.b)
		AssertEquals($FF, SColor8.DarkGray.a)
	End Method

	Method TestGlobalColorsDarkGrey() {test}
		AssertEquals($FFA9A9A9, SColor8.DarkGrey.ToRGBA())
		AssertEquals($A9, SColor8.DarkGrey.r)
		AssertEquals($A9, SColor8.DarkGrey.g)
		AssertEquals($A9, SColor8.DarkGrey.b)
		AssertEquals($FF, SColor8.DarkGrey.a)
	End Method

	Method TestGlobalColorsDarkGreen() {test}
		AssertEquals($FF006400, SColor8.DarkGreen.ToRGBA())
		AssertEquals($00, SColor8.DarkGreen.r)
		AssertEquals($64, SColor8.DarkGreen.g)
		AssertEquals($00, SColor8.DarkGreen.b)
		AssertEquals($FF, SColor8.DarkGreen.a)
	End Method

	Method TestGlobalColorsDarkKhaki() {test}
		AssertEquals($FFBDB76B, SColor8.DarkKhaki.ToRGBA())
		AssertEquals($BD, SColor8.DarkKhaki.r)
		AssertEquals($B7, SColor8.DarkKhaki.g)
		AssertEquals($6B, SColor8.DarkKhaki.b)
		AssertEquals($FF, SColor8.DarkKhaki.a)
	End Method

	Method TestGlobalColorsDarkMagenta() {test}
		AssertEquals($FF8B008B, SColor8.DarkMagenta.ToRGBA())
		AssertEquals($8B, SColor8.DarkMagenta.r)
		AssertEquals($00, SColor8.DarkMagenta.g)
		AssertEquals($8B, SColor8.DarkMagenta.b)
		AssertEquals($FF, SColor8.DarkMagenta.a)
	End Method

	Method TestGlobalColorsDarkOliveGreen() {test}
		AssertEquals($FF556B2F, SColor8.DarkOliveGreen.ToRGBA())
		AssertEquals($55, SColor8.DarkOliveGreen.r)
		AssertEquals($6B, SColor8.DarkOliveGreen.g)
		AssertEquals($2F, SColor8.DarkOliveGreen.b)
		AssertEquals($FF, SColor8.DarkOliveGreen.a)
	End Method

	Method TestGlobalColorsDarkOrange() {test}
		AssertEquals($FFFF8C00, SColor8.DarkOrange.ToRGBA())
		AssertEquals($FF, SColor8.DarkOrange.r)
		AssertEquals($8C, SColor8.DarkOrange.g)
		AssertEquals($00, SColor8.DarkOrange.b)
		AssertEquals($FF, SColor8.DarkOrange.a)
	End Method

	Method TestGlobalColorsDarkOrchid() {test}
		AssertEquals($FF9932CC, SColor8.DarkOrchid.ToRGBA())
		AssertEquals($99, SColor8.DarkOrchid.r)
		AssertEquals($32, SColor8.DarkOrchid.g)
		AssertEquals($CC, SColor8.DarkOrchid.b)
		AssertEquals($FF, SColor8.DarkOrchid.a)
	End Method

	Method TestGlobalColorsDarkRed() {test}
		AssertEquals($FF8B0000, SColor8.DarkRed.ToRGBA())
		AssertEquals($8B, SColor8.DarkRed.r)
		AssertEquals($00, SColor8.DarkRed.g)
		AssertEquals($00, SColor8.DarkRed.b)
		AssertEquals($FF, SColor8.DarkRed.a)
	End Method

	Method TestGlobalColorsDarkSalmon() {test}
		AssertEquals($FFE9967A, SColor8.DarkSalmon.ToRGBA())
		AssertEquals($E9, SColor8.DarkSalmon.r)
		AssertEquals($96, SColor8.DarkSalmon.g)
		AssertEquals($7A, SColor8.DarkSalmon.b)
		AssertEquals($FF, SColor8.DarkSalmon.a)
	End Method

	Method TestGlobalColorsDarkSeaGreen() {test}
		AssertEquals($FF8FBC8F, SColor8.DarkSeaGreen.ToRGBA())
		AssertEquals($8F, SColor8.DarkSeaGreen.r)
		AssertEquals($BC, SColor8.DarkSeaGreen.g)
		AssertEquals($8F, SColor8.DarkSeaGreen.b)
		AssertEquals($FF, SColor8.DarkSeaGreen.a)
	End Method

	Method TestGlobalColorsDarkSlateBlue() {test}
		AssertEquals($FF483D8B, SColor8.DarkSlateBlue.ToRGBA())
		AssertEquals($48, SColor8.DarkSlateBlue.r)
		AssertEquals($3D, SColor8.DarkSlateBlue.g)
		AssertEquals($8B, SColor8.DarkSlateBlue.b)
		AssertEquals($FF, SColor8.DarkSlateBlue.a)
	End Method

	Method TestGlobalColorsDarkSlateGray() {test}
		AssertEquals($FF2F4F4F, SColor8.DarkSlateGray.ToRGBA())
		AssertEquals($2F, SColor8.DarkSlateGray.r)
		AssertEquals($4F, SColor8.DarkSlateGray.g)
		AssertEquals($4F, SColor8.DarkSlateGray.b)
		AssertEquals($FF, SColor8.DarkSlateGray.a)
	End Method

	Method TestGlobalColorsDarkSlateGrey() {test}
		AssertEquals($FF2F4F4F, SColor8.DarkSlateGrey.ToRGBA())
		AssertEquals($2F, SColor8.DarkSlateGrey.r)
		AssertEquals($4F, SColor8.DarkSlateGrey.g)
		AssertEquals($4F, SColor8.DarkSlateGrey.b)
		AssertEquals($FF, SColor8.DarkSlateGrey.a)
	End Method

	Method TestGlobalColorsDarkTurquoise() {test}
		AssertEquals($FF00CED1, SColor8.DarkTurquoise.ToRGBA())
		AssertEquals($00, SColor8.DarkTurquoise.r)
		AssertEquals($CE, SColor8.DarkTurquoise.g)
		AssertEquals($D1, SColor8.DarkTurquoise.b)
		AssertEquals($FF, SColor8.DarkTurquoise.a)
	End Method

	Method TestGlobalColorsDarkViolet() {test}
		AssertEquals($FF9400D3, SColor8.DarkViolet.ToRGBA())
		AssertEquals($94, SColor8.DarkViolet.r)
		AssertEquals($00, SColor8.DarkViolet.g)
		AssertEquals($D3, SColor8.DarkViolet.b)
		AssertEquals($FF, SColor8.DarkViolet.a)
	End Method

	Method TestGlobalColorsDeepPink() {test}
		AssertEquals($FFFF1493, SColor8.DeepPink.ToRGBA())
		AssertEquals($FF, SColor8.DeepPink.r)
		AssertEquals($14, SColor8.DeepPink.g)
		AssertEquals($93, SColor8.DeepPink.b)
		AssertEquals($FF, SColor8.DeepPink.a)
	End Method

	Method TestGlobalColorsDeepSkyBlue() {test}
		AssertEquals($FF00BFFF, SColor8.DeepSkyBlue.ToRGBA())
		AssertEquals($00, SColor8.DeepSkyBlue.r)
		AssertEquals($BF, SColor8.DeepSkyBlue.g)
		AssertEquals($FF, SColor8.DeepSkyBlue.b)
		AssertEquals($FF, SColor8.DeepSkyBlue.a)
	End Method

	Method TestGlobalColorsDimGray() {test}
		AssertEquals($FF696969, SColor8.DimGray.ToRGBA())
		AssertEquals($69, SColor8.DimGray.r)
		AssertEquals($69, SColor8.DimGray.g)
		AssertEquals($69, SColor8.DimGray.b)
		AssertEquals($FF, SColor8.DimGray.a)
	End Method

	Method TestGlobalColorsDimGrey() {test}
		AssertEquals($FF696969, SColor8.DimGrey.ToRGBA())
		AssertEquals($69, SColor8.DimGrey.r)
		AssertEquals($69, SColor8.DimGrey.g)
		AssertEquals($69, SColor8.DimGrey.b)
		AssertEquals($FF, SColor8.DimGrey.a)
	End Method

	Method TestGlobalColorsDodgerBlue() {test}
		AssertEquals($FF1E90FF, SColor8.DodgerBlue.ToRGBA())
		AssertEquals($1E, SColor8.DodgerBlue.r)
		AssertEquals($90, SColor8.DodgerBlue.g)
		AssertEquals($FF, SColor8.DodgerBlue.b)
		AssertEquals($FF, SColor8.DodgerBlue.a)
	End Method

	Method TestGlobalColorsFireBrick() {test}
		AssertEquals($FFB22222, SColor8.FireBrick.ToRGBA())
		AssertEquals($B2, SColor8.FireBrick.r)
		AssertEquals($22, SColor8.FireBrick.g)
		AssertEquals($22, SColor8.FireBrick.b)
		AssertEquals($FF, SColor8.FireBrick.a)
	End Method

	Method TestGlobalColorsFloralWhite() {test}
		AssertEquals($FFFFFAF0, SColor8.FloralWhite.ToRGBA())
		AssertEquals($FF, SColor8.FloralWhite.r)
		AssertEquals($FA, SColor8.FloralWhite.g)
		AssertEquals($F0, SColor8.FloralWhite.b)
		AssertEquals($FF, SColor8.FloralWhite.a)
	End Method

	Method TestGlobalColorsForestGreen() {test}
		AssertEquals($FF228B22, SColor8.ForestGreen.ToRGBA())
		AssertEquals($22, SColor8.ForestGreen.r)
		AssertEquals($8B, SColor8.ForestGreen.g)
		AssertEquals($22, SColor8.ForestGreen.b)
		AssertEquals($FF, SColor8.ForestGreen.a)
	End Method

	Method TestGlobalColorsFuchsia() {test}
		AssertEquals($FFFF00FF, SColor8.Fuchsia.ToRGBA())
		AssertEquals($FF, SColor8.Fuchsia.r)
		AssertEquals($00, SColor8.Fuchsia.g)
		AssertEquals($FF, SColor8.Fuchsia.b)
		AssertEquals($FF, SColor8.Fuchsia.a)
	End Method

	Method TestGlobalColorsGainsboro() {test}
		AssertEquals($FFDCDCDC, SColor8.Gainsboro.ToRGBA())
		AssertEquals($DC, SColor8.Gainsboro.r)
		AssertEquals($DC, SColor8.Gainsboro.g)
		AssertEquals($DC, SColor8.Gainsboro.b)
		AssertEquals($FF, SColor8.Gainsboro.a)
	End Method

	Method TestGlobalColorsGhostWhite() {test}
		AssertEquals($FFF8F8FF, SColor8.GhostWhite.ToRGBA())
		AssertEquals($F8, SColor8.GhostWhite.r)
		AssertEquals($F8, SColor8.GhostWhite.g)
		AssertEquals($FF, SColor8.GhostWhite.b)
		AssertEquals($FF, SColor8.GhostWhite.a)
	End Method

	Method TestGlobalColorsGold() {test}
		AssertEquals($FFFFD700, SColor8.Gold.ToRGBA())
		AssertEquals($FF, SColor8.Gold.r)
		AssertEquals($D7, SColor8.Gold.g)
		AssertEquals($00, SColor8.Gold.b)
		AssertEquals($FF, SColor8.Gold.a)
	End Method

	Method TestGlobalColorsGoldenRod() {test}
		AssertEquals($FFDAA520, SColor8.GoldenRod.ToRGBA())
		AssertEquals($DA, SColor8.GoldenRod.r)
		AssertEquals($A5, SColor8.GoldenRod.g)
		AssertEquals($20, SColor8.GoldenRod.b)
		AssertEquals($FF, SColor8.GoldenRod.a)
	End Method

	Method TestGlobalColorsGray() {test}
		AssertEquals($FF808080, SColor8.Gray.ToRGBA())
		AssertEquals($80, SColor8.Gray.r)
		AssertEquals($80, SColor8.Gray.g)
		AssertEquals($80, SColor8.Gray.b)
		AssertEquals($FF, SColor8.Gray.a)
	End Method

	Method TestGlobalColorsGrey() {test}
		AssertEquals($FF808080, SColor8.Grey.ToRGBA())
		AssertEquals($80, SColor8.Grey.r)
		AssertEquals($80, SColor8.Grey.g)
		AssertEquals($80, SColor8.Grey.b)
		AssertEquals($FF, SColor8.Grey.a)
	End Method

	Method TestGlobalColorsGreen() {test}
		AssertEquals($FF00FF00, SColor8.Green.ToRGBA())
		AssertEquals($00, SColor8.Green.r)
		AssertEquals($FF, SColor8.Green.g)
		AssertEquals($00, SColor8.Green.b)
		AssertEquals($FF, SColor8.Green.a)
	End Method

	Method TestGlobalColorsGreenYellow() {test}
		AssertEquals($FFADFF2F, SColor8.GreenYellow.ToRGBA())
		AssertEquals($AD, SColor8.GreenYellow.r)
		AssertEquals($FF, SColor8.GreenYellow.g)
		AssertEquals($2F, SColor8.GreenYellow.b)
		AssertEquals($FF, SColor8.GreenYellow.a)
	End Method

	Method TestGlobalColorsHoneyDew() {test}
		AssertEquals($FFF0FFF0, SColor8.HoneyDew.ToRGBA())
		AssertEquals($F0, SColor8.HoneyDew.r)
		AssertEquals($FF, SColor8.HoneyDew.g)
		AssertEquals($F0, SColor8.HoneyDew.b)
		AssertEquals($FF, SColor8.HoneyDew.a)
	End Method

	Method TestGlobalColorsHotPink() {test}
		AssertEquals($FFFF69B4, SColor8.HotPink.ToRGBA())
		AssertEquals($FF, SColor8.HotPink.r)
		AssertEquals($69, SColor8.HotPink.g)
		AssertEquals($B4, SColor8.HotPink.b)
		AssertEquals($FF, SColor8.HotPink.a)
	End Method

	Method TestGlobalColorsIndianRed() {test}
		AssertEquals($FFCD5C5C, SColor8.IndianRed.ToRGBA())
		AssertEquals($CD, SColor8.IndianRed.r)
		AssertEquals($5C, SColor8.IndianRed.g)
		AssertEquals($5C, SColor8.IndianRed.b)
		AssertEquals($FF, SColor8.IndianRed.a)
	End Method

	Method TestGlobalColorsIndigo() {test}
		AssertEquals($FF4B0082, SColor8.Indigo.ToRGBA())
		AssertEquals($4B, SColor8.Indigo.r)
		AssertEquals($00, SColor8.Indigo.g)
		AssertEquals($82, SColor8.Indigo.b)
		AssertEquals($FF, SColor8.Indigo.a)
	End Method

	Method TestGlobalColorsIvory() {test}
		AssertEquals($FFFFFFF0, SColor8.Ivory.ToRGBA())
		AssertEquals($FF, SColor8.Ivory.r)
		AssertEquals($FF, SColor8.Ivory.g)
		AssertEquals($F0, SColor8.Ivory.b)
		AssertEquals($FF, SColor8.Ivory.a)
	End Method

	Method TestGlobalColorsKhaki() {test}
		AssertEquals($FFF0E68C, SColor8.Khaki.ToRGBA())
		AssertEquals($F0, SColor8.Khaki.r)
		AssertEquals($E6, SColor8.Khaki.g)
		AssertEquals($8C, SColor8.Khaki.b)
		AssertEquals($FF, SColor8.Khaki.a)
	End Method

	Method TestGlobalColorsLavender() {test}
		AssertEquals($FFE6E6FA, SColor8.Lavender.ToRGBA())
		AssertEquals($E6, SColor8.Lavender.r)
		AssertEquals($E6, SColor8.Lavender.g)
		AssertEquals($FA, SColor8.Lavender.b)
		AssertEquals($FF, SColor8.Lavender.a)
	End Method

	Method TestGlobalColorsLavenderBlush() {test}
		AssertEquals($FFFFF0F5, SColor8.LavenderBlush.ToRGBA())
		AssertEquals($FF, SColor8.LavenderBlush.r)
		AssertEquals($F0, SColor8.LavenderBlush.g)
		AssertEquals($F5, SColor8.LavenderBlush.b)
		AssertEquals($FF, SColor8.LavenderBlush.a)
	End Method

	Method TestGlobalColorsLawnGreen() {test}
		AssertEquals($FF7CFC00, SColor8.LawnGreen.ToRGBA())
		AssertEquals($7C, SColor8.LawnGreen.r)
		AssertEquals($FC, SColor8.LawnGreen.g)
		AssertEquals($00, SColor8.LawnGreen.b)
		AssertEquals($FF, SColor8.LawnGreen.a)
	End Method

	Method TestGlobalColorsLemonChiffon() {test}
		AssertEquals($FFFFFACD, SColor8.LemonChiffon.ToRGBA())
		AssertEquals($FF, SColor8.LemonChiffon.r)
		AssertEquals($FA, SColor8.LemonChiffon.g)
		AssertEquals($CD, SColor8.LemonChiffon.b)
		AssertEquals($FF, SColor8.LemonChiffon.a)
	End Method

	Method TestGlobalColorsLightBlue() {test}
		AssertEquals($FFADD8E6, SColor8.LightBlue.ToRGBA())
		AssertEquals($AD, SColor8.LightBlue.r)
		AssertEquals($D8, SColor8.LightBlue.g)
		AssertEquals($E6, SColor8.LightBlue.b)
		AssertEquals($FF, SColor8.LightBlue.a)
	End Method

	Method TestGlobalColorsLightCoral() {test}
		AssertEquals($FFF08080, SColor8.LightCoral.ToRGBA())
		AssertEquals($F0, SColor8.LightCoral.r)
		AssertEquals($80, SColor8.LightCoral.g)
		AssertEquals($80, SColor8.LightCoral.b)
		AssertEquals($FF, SColor8.LightCoral.a)
	End Method

	Method TestGlobalColorsLightCyan() {test}
		AssertEquals($FFE0FFFF, SColor8.LightCyan.ToRGBA())
		AssertEquals($E0, SColor8.LightCyan.r)
		AssertEquals($FF, SColor8.LightCyan.g)
		AssertEquals($FF, SColor8.LightCyan.b)
		AssertEquals($FF, SColor8.LightCyan.a)
	End Method

	Method TestGlobalColorsLightGoldenRodYellow() {test}
		AssertEquals($FFFAFAD2, SColor8.LightGoldenRodYellow.ToRGBA())
		AssertEquals($FA, SColor8.LightGoldenRodYellow.r)
		AssertEquals($FA, SColor8.LightGoldenRodYellow.g)
		AssertEquals($D2, SColor8.LightGoldenRodYellow.b)
		AssertEquals($FF, SColor8.LightGoldenRodYellow.a)
	End Method

	Method TestGlobalColorsLightGray() {test}
		AssertEquals($FFD3D3D3, SColor8.LightGray.ToRGBA())
		AssertEquals($D3, SColor8.LightGray.r)
		AssertEquals($D3, SColor8.LightGray.g)
		AssertEquals($D3, SColor8.LightGray.b)
		AssertEquals($FF, SColor8.LightGray.a)
	End Method

	Method TestGlobalColorsLightGrey() {test}
		AssertEquals($FFD3D3D3, SColor8.LightGrey.ToRGBA())
		AssertEquals($D3, SColor8.LightGrey.r)
		AssertEquals($D3, SColor8.LightGrey.g)
		AssertEquals($D3, SColor8.LightGrey.b)
		AssertEquals($FF, SColor8.LightGrey.a)
	End Method

	Method TestGlobalColorsLightGreen() {test}
		AssertEquals($FF90EE90, SColor8.LightGreen.ToRGBA())
		AssertEquals($90, SColor8.LightGreen.r)
		AssertEquals($EE, SColor8.LightGreen.g)
		AssertEquals($90, SColor8.LightGreen.b)
		AssertEquals($FF, SColor8.LightGreen.a)
	End Method

	Method TestGlobalColorsLightPink() {test}
		AssertEquals($FFFFB6C1, SColor8.LightPink.ToRGBA())
		AssertEquals($FF, SColor8.LightPink.r)
		AssertEquals($B6, SColor8.LightPink.g)
		AssertEquals($C1, SColor8.LightPink.b)
		AssertEquals($FF, SColor8.LightPink.a)
	End Method

	Method TestGlobalColorsLightSalmon() {test}
		AssertEquals($FFFFA07A, SColor8.LightSalmon.ToRGBA())
		AssertEquals($FF, SColor8.LightSalmon.r)
		AssertEquals($A0, SColor8.LightSalmon.g)
		AssertEquals($7A, SColor8.LightSalmon.b)
		AssertEquals($FF, SColor8.LightSalmon.a)
	End Method

	Method TestGlobalColorsLightSeaGreen() {test}
		AssertEquals($FF20B2AA, SColor8.LightSeaGreen.ToRGBA())
		AssertEquals($20, SColor8.LightSeaGreen.r)
		AssertEquals($B2, SColor8.LightSeaGreen.g)
		AssertEquals($AA, SColor8.LightSeaGreen.b)
		AssertEquals($FF, SColor8.LightSeaGreen.a)
	End Method

	Method TestGlobalColorsLightSkyBlue() {test}
		AssertEquals($FF87CEFA, SColor8.LightSkyBlue.ToRGBA())
		AssertEquals($87, SColor8.LightSkyBlue.r)
		AssertEquals($CE, SColor8.LightSkyBlue.g)
		AssertEquals($FA, SColor8.LightSkyBlue.b)
		AssertEquals($FF, SColor8.LightSkyBlue.a)
	End Method

	Method TestGlobalColorsLightSlateGray() {test}
		AssertEquals($FF778899, SColor8.LightSlateGray.ToRGBA())
		AssertEquals($77, SColor8.LightSlateGray.r)
		AssertEquals($88, SColor8.LightSlateGray.g)
		AssertEquals($99, SColor8.LightSlateGray.b)
		AssertEquals($FF, SColor8.LightSlateGray.a)
	End Method

	Method TestGlobalColorsLightSlateGrey() {test}
		AssertEquals($FF778899, SColor8.LightSlateGrey.ToRGBA())
		AssertEquals($77, SColor8.LightSlateGrey.r)
		AssertEquals($88, SColor8.LightSlateGrey.g)
		AssertEquals($99, SColor8.LightSlateGrey.b)
		AssertEquals($FF, SColor8.LightSlateGrey.a)
	End Method

	Method TestGlobalColorsLightSteelBlue() {test}
		AssertEquals($FFB0C4DE, SColor8.LightSteelBlue.ToRGBA())
		AssertEquals($B0, SColor8.LightSteelBlue.r)
		AssertEquals($C4, SColor8.LightSteelBlue.g)
		AssertEquals($DE, SColor8.LightSteelBlue.b)
		AssertEquals($FF, SColor8.LightSteelBlue.a)
	End Method

	Method TestGlobalColorsLightYellow() {test}
		AssertEquals($FFFFFFE0, SColor8.LightYellow.ToRGBA())
		AssertEquals($FF, SColor8.LightYellow.r)
		AssertEquals($FF, SColor8.LightYellow.g)
		AssertEquals($E0, SColor8.LightYellow.b)
		AssertEquals($FF, SColor8.LightYellow.a)
	End Method

	Method TestGlobalColorsLimeGreen() {test}
		AssertEquals($FF32CD32, SColor8.LimeGreen.ToRGBA())
		AssertEquals($32, SColor8.LimeGreen.r)
		AssertEquals($CD, SColor8.LimeGreen.g)
		AssertEquals($32, SColor8.LimeGreen.b)
		AssertEquals($FF, SColor8.LimeGreen.a)
	End Method

	Method TestGlobalColorsLinen() {test}
		AssertEquals($FFFAF0E6, SColor8.Linen.ToRGBA())
		AssertEquals($FA, SColor8.Linen.r)
		AssertEquals($F0, SColor8.Linen.g)
		AssertEquals($E6, SColor8.Linen.b)
		AssertEquals($FF, SColor8.Linen.a)
	End Method

	Method TestGlobalColorsMagenta() {test}
		AssertEquals($FFFF00FF, SColor8.Magenta.ToRGBA())
		AssertEquals($FF, SColor8.Magenta.r)
		AssertEquals($00, SColor8.Magenta.g)
		AssertEquals($FF, SColor8.Magenta.b)
		AssertEquals($FF, SColor8.Magenta.a)
	End Method

	Method TestGlobalColorsMaroon() {test}
		AssertEquals($FF800000, SColor8.Maroon.ToRGBA())
		AssertEquals($80, SColor8.Maroon.r)
		AssertEquals($00, SColor8.Maroon.g)
		AssertEquals($00, SColor8.Maroon.b)
		AssertEquals($FF, SColor8.Maroon.a)
	End Method

	Method TestGlobalColorsMediumAquaMarine() {test}
		AssertEquals($FF66CDAA, SColor8.MediumAquaMarine.ToRGBA())
		AssertEquals($66, SColor8.MediumAquaMarine.r)
		AssertEquals($CD, SColor8.MediumAquaMarine.g)
		AssertEquals($AA, SColor8.MediumAquaMarine.b)
		AssertEquals($FF, SColor8.MediumAquaMarine.a)
	End Method

	Method TestGlobalColorsMediumBlue() {test}
		AssertEquals($FF0000CD, SColor8.MediumBlue.ToRGBA())
		AssertEquals($00, SColor8.MediumBlue.r)
		AssertEquals($00, SColor8.MediumBlue.g)
		AssertEquals($CD, SColor8.MediumBlue.b)
		AssertEquals($FF, SColor8.MediumBlue.a)
	End Method

	Method TestGlobalColorsMediumOrchid() {test}
		AssertEquals($FFBA55D3, SColor8.MediumOrchid.ToRGBA())
		AssertEquals($BA, SColor8.MediumOrchid.r)
		AssertEquals($55, SColor8.MediumOrchid.g)
		AssertEquals($D3, SColor8.MediumOrchid.b)
		AssertEquals($FF, SColor8.MediumOrchid.a)
	End Method

	Method TestGlobalColorsMediumPurple() {test}
		AssertEquals($FF9370DB, SColor8.MediumPurple.ToRGBA())
		AssertEquals($93, SColor8.MediumPurple.r)
		AssertEquals($70, SColor8.MediumPurple.g)
		AssertEquals($DB, SColor8.MediumPurple.b)
		AssertEquals($FF, SColor8.MediumPurple.a)
	End Method

	Method TestGlobalColorsMediumSeaGreen() {test}
		AssertEquals($FF3CB371, SColor8.MediumSeaGreen.ToRGBA())
		AssertEquals($3C, SColor8.MediumSeaGreen.r)
		AssertEquals($B3, SColor8.MediumSeaGreen.g)
		AssertEquals($71, SColor8.MediumSeaGreen.b)
		AssertEquals($FF, SColor8.MediumSeaGreen.a)
	End Method

	Method TestGlobalColorsMediumSlateBlue() {test}
		AssertEquals($FF7B68EE, SColor8.MediumSlateBlue.ToRGBA())
		AssertEquals($7B, SColor8.MediumSlateBlue.r)
		AssertEquals($68, SColor8.MediumSlateBlue.g)
		AssertEquals($EE, SColor8.MediumSlateBlue.b)
		AssertEquals($FF, SColor8.MediumSlateBlue.a)
	End Method

	Method TestGlobalColorsMediumSpringGreen() {test}
		AssertEquals($FF00FA9A, SColor8.MediumSpringGreen.ToRGBA())
		AssertEquals($00, SColor8.MediumSpringGreen.r)
		AssertEquals($FA, SColor8.MediumSpringGreen.g)
		AssertEquals($9A, SColor8.MediumSpringGreen.b)
		AssertEquals($FF, SColor8.MediumSpringGreen.a)
	End Method

	Method TestGlobalColorsMediumTurquoise() {test}
		AssertEquals($FF48D1CC, SColor8.MediumTurquoise.ToRGBA())
		AssertEquals($48, SColor8.MediumTurquoise.r)
		AssertEquals($D1, SColor8.MediumTurquoise.g)
		AssertEquals($CC, SColor8.MediumTurquoise.b)
		AssertEquals($FF, SColor8.MediumTurquoise.a)
	End Method

	Method TestGlobalColorsMediumVioletRed() {test}
		AssertEquals($FFC71585, SColor8.MediumVioletRed.ToRGBA())
		AssertEquals($C7, SColor8.MediumVioletRed.r)
		AssertEquals($15, SColor8.MediumVioletRed.g)
		AssertEquals($85, SColor8.MediumVioletRed.b)
		AssertEquals($FF, SColor8.MediumVioletRed.a)
	End Method

	Method TestGlobalColorsMidnightBlue() {test}
		AssertEquals($FF191970, SColor8.MidnightBlue.ToRGBA())
		AssertEquals($19, SColor8.MidnightBlue.r)
		AssertEquals($19, SColor8.MidnightBlue.g)
		AssertEquals($70, SColor8.MidnightBlue.b)
		AssertEquals($FF, SColor8.MidnightBlue.a)
	End Method

	Method TestGlobalColorsMintCream() {test}
		AssertEquals($FFF5FFFA, SColor8.MintCream.ToRGBA())
		AssertEquals($F5, SColor8.MintCream.r)
		AssertEquals($FF, SColor8.MintCream.g)
		AssertEquals($FA, SColor8.MintCream.b)
		AssertEquals($FF, SColor8.MintCream.a)
	End Method

	Method TestGlobalColorsMistyRose() {test}
		AssertEquals($FFFFE4E1, SColor8.MistyRose.ToRGBA())
		AssertEquals($FF, SColor8.MistyRose.r)
		AssertEquals($E4, SColor8.MistyRose.g)
		AssertEquals($E1, SColor8.MistyRose.b)
		AssertEquals($FF, SColor8.MistyRose.a)
	End Method

	Method TestGlobalColorsMoccasin() {test}
		AssertEquals($FFFFE4B5, SColor8.Moccasin.ToRGBA())
		AssertEquals($FF, SColor8.Moccasin.r)
		AssertEquals($E4, SColor8.Moccasin.g)
		AssertEquals($B5, SColor8.Moccasin.b)
		AssertEquals($FF, SColor8.Moccasin.a)
	End Method

	Method TestGlobalColorsNavajoWhite() {test}
		AssertEquals($FFFFDEAD, SColor8.NavajoWhite.ToRGBA())
		AssertEquals($FF, SColor8.NavajoWhite.r)
		AssertEquals($DE, SColor8.NavajoWhite.g)
		AssertEquals($AD, SColor8.NavajoWhite.b)
		AssertEquals($FF, SColor8.NavajoWhite.a)
	End Method

	Method TestGlobalColorsNavy() {test}
		AssertEquals($FF000080, SColor8.Navy.ToRGBA())
		AssertEquals($00, SColor8.Navy.r)
		AssertEquals($00, SColor8.Navy.g)
		AssertEquals($80, SColor8.Navy.b)
		AssertEquals($FF, SColor8.Navy.a)
	End Method

	Method TestGlobalColorsOldLace() {test}
		AssertEquals($FFFDF5E6, SColor8.OldLace.ToRGBA())
		AssertEquals($FD, SColor8.OldLace.r)
		AssertEquals($F5, SColor8.OldLace.g)
		AssertEquals($E6, SColor8.OldLace.b)
		AssertEquals($FF, SColor8.OldLace.a)
	End Method

	Method TestGlobalColorsOlive() {test}
		AssertEquals($FF808000, SColor8.Olive.ToRGBA())
		AssertEquals($80, SColor8.Olive.r)
		AssertEquals($80, SColor8.Olive.g)
		AssertEquals($00, SColor8.Olive.b)
		AssertEquals($FF, SColor8.Olive.a)
	End Method

	Method TestGlobalColorsOliveDrab() {test}
		AssertEquals($FF6B8E23, SColor8.OliveDrab.ToRGBA())
		AssertEquals($6B, SColor8.OliveDrab.r)
		AssertEquals($8E, SColor8.OliveDrab.g)
		AssertEquals($23, SColor8.OliveDrab.b)
		AssertEquals($FF, SColor8.OliveDrab.a)
	End Method

	Method TestGlobalColorsOrange() {test}
		AssertEquals($FFFFA500, SColor8.Orange.ToRGBA())
		AssertEquals($FF, SColor8.Orange.r)
		AssertEquals($A5, SColor8.Orange.g)
		AssertEquals($00, SColor8.Orange.b)
		AssertEquals($FF, SColor8.Orange.a)
	End Method

	Method TestGlobalColorsOrangeRed() {test}
		AssertEquals($FFFF4500, SColor8.OrangeRed.ToRGBA())
		AssertEquals($FF, SColor8.OrangeRed.r)
		AssertEquals($45, SColor8.OrangeRed.g)
		AssertEquals($00, SColor8.OrangeRed.b)
		AssertEquals($FF, SColor8.OrangeRed.a)
	End Method

	Method TestGlobalColorsOrchid() {test}
		AssertEquals($FFDA70D6, SColor8.Orchid.ToRGBA())
		AssertEquals($DA, SColor8.Orchid.r)
		AssertEquals($70, SColor8.Orchid.g)
		AssertEquals($D6, SColor8.Orchid.b)
		AssertEquals($FF, SColor8.Orchid.a)
	End Method

	Method TestGlobalColorsPaleGoldenRod() {test}
		AssertEquals($FFEEE8AA, SColor8.PaleGoldenRod.ToRGBA())
		AssertEquals($EE, SColor8.PaleGoldenRod.r)
		AssertEquals($E8, SColor8.PaleGoldenRod.g)
		AssertEquals($AA, SColor8.PaleGoldenRod.b)
		AssertEquals($FF, SColor8.PaleGoldenRod.a)
	End Method

	Method TestGlobalColorsPaleGreen() {test}
		AssertEquals($FF98FB98, SColor8.PaleGreen.ToRGBA())
		AssertEquals($98, SColor8.PaleGreen.r)
		AssertEquals($FB, SColor8.PaleGreen.g)
		AssertEquals($98, SColor8.PaleGreen.b)
		AssertEquals($FF, SColor8.PaleGreen.a)
	End Method

	Method TestGlobalColorsPaleTurquoise() {test}
		AssertEquals($FFAFEEEE, SColor8.PaleTurquoise.ToRGBA())
		AssertEquals($AF, SColor8.PaleTurquoise.r)
		AssertEquals($EE, SColor8.PaleTurquoise.g)
		AssertEquals($EE, SColor8.PaleTurquoise.b)
		AssertEquals($FF, SColor8.PaleTurquoise.a)
	End Method

	Method TestGlobalColorsPaleVioletRed() {test}
		AssertEquals($FFDB7093, SColor8.PaleVioletRed.ToRGBA())
		AssertEquals($DB, SColor8.PaleVioletRed.r)
		AssertEquals($70, SColor8.PaleVioletRed.g)
		AssertEquals($93, SColor8.PaleVioletRed.b)
		AssertEquals($FF, SColor8.PaleVioletRed.a)
	End Method

	Method TestGlobalColorsPapayaWhip() {test}
		AssertEquals($FFFFEFD5, SColor8.PapayaWhip.ToRGBA())
		AssertEquals($FF, SColor8.PapayaWhip.r)
		AssertEquals($EF, SColor8.PapayaWhip.g)
		AssertEquals($D5, SColor8.PapayaWhip.b)
		AssertEquals($FF, SColor8.PapayaWhip.a)
	End Method

	Method TestGlobalColorsPeachPuff() {test}
		AssertEquals($FFFFDAB9, SColor8.PeachPuff.ToRGBA())
		AssertEquals($FF, SColor8.PeachPuff.r)
		AssertEquals($DA, SColor8.PeachPuff.g)
		AssertEquals($B9, SColor8.PeachPuff.b)
		AssertEquals($FF, SColor8.PeachPuff.a)
	End Method

	Method TestGlobalColorsPeru() {test}
		AssertEquals($FFCD853F, SColor8.Peru.ToRGBA())
		AssertEquals($CD, SColor8.Peru.r)
		AssertEquals($85, SColor8.Peru.g)
		AssertEquals($3F, SColor8.Peru.b)
		AssertEquals($FF, SColor8.Peru.a)
	End Method

	Method TestGlobalColorsPink() {test}
		AssertEquals($FFFFC0CB, SColor8.Pink.ToRGBA())
		AssertEquals($FF, SColor8.Pink.r)
		AssertEquals($C0, SColor8.Pink.g)
		AssertEquals($CB, SColor8.Pink.b)
		AssertEquals($FF, SColor8.Pink.a)
	End Method

	Method TestGlobalColorsPlum() {test}
		AssertEquals($FFDDA0DD, SColor8.Plum.ToRGBA())
		AssertEquals($DD, SColor8.Plum.r)
		AssertEquals($A0, SColor8.Plum.g)
		AssertEquals($DD, SColor8.Plum.b)
		AssertEquals($FF, SColor8.Plum.a)
	End Method

	Method TestGlobalColorsPowderBlue() {test}
		AssertEquals($FFB0E0E6, SColor8.PowderBlue.ToRGBA())
		AssertEquals($B0, SColor8.PowderBlue.r)
		AssertEquals($E0, SColor8.PowderBlue.g)
		AssertEquals($E6, SColor8.PowderBlue.b)
		AssertEquals($FF, SColor8.PowderBlue.a)
	End Method

	Method TestGlobalColorsPurple() {test}
		AssertEquals($FF800080, SColor8.Purple.ToRGBA())
		AssertEquals($80, SColor8.Purple.r)
		AssertEquals($00, SColor8.Purple.g)
		AssertEquals($80, SColor8.Purple.b)
		AssertEquals($FF, SColor8.Purple.a)
	End Method

	Method TestGlobalColorsRebeccaPurple() {test}
		AssertEquals($FF663399, SColor8.RebeccaPurple.ToRGBA())
		AssertEquals($66, SColor8.RebeccaPurple.r)
		AssertEquals($33, SColor8.RebeccaPurple.g)
		AssertEquals($99, SColor8.RebeccaPurple.b)
		AssertEquals($FF, SColor8.RebeccaPurple.a)
	End Method

	Method TestGlobalColorsRed() {test}
		AssertEquals($FFFF0000, SColor8.Red.ToRGBA())
		AssertEquals($FF, SColor8.Red.r)
		AssertEquals($00, SColor8.Red.g)
		AssertEquals($00, SColor8.Red.b)
		AssertEquals($FF, SColor8.Red.a)
	End Method

	Method TestGlobalColorsRosyBrown() {test}
		AssertEquals($FFBC8F8F, SColor8.RosyBrown.ToRGBA())
		AssertEquals($BC, SColor8.RosyBrown.r)
		AssertEquals($8F, SColor8.RosyBrown.g)
		AssertEquals($8F, SColor8.RosyBrown.b)
		AssertEquals($FF, SColor8.RosyBrown.a)
	End Method

	Method TestGlobalColorsRoyalBlue() {test}
		AssertEquals($FF4169E1, SColor8.RoyalBlue.ToRGBA())
		AssertEquals($41, SColor8.RoyalBlue.r)
		AssertEquals($69, SColor8.RoyalBlue.g)
		AssertEquals($E1, SColor8.RoyalBlue.b)
		AssertEquals($FF, SColor8.RoyalBlue.a)
	End Method

	Method TestGlobalColorsSaddleBrown() {test}
		AssertEquals($FF8B4513, SColor8.SaddleBrown.ToRGBA())
		AssertEquals($8B, SColor8.SaddleBrown.r)
		AssertEquals($45, SColor8.SaddleBrown.g)
		AssertEquals($13, SColor8.SaddleBrown.b)
		AssertEquals($FF, SColor8.SaddleBrown.a)
	End Method

	Method TestGlobalColorsSalmon() {test}
		AssertEquals($FFFA8072, SColor8.Salmon.ToRGBA())
		AssertEquals($FA, SColor8.Salmon.r)
		AssertEquals($80, SColor8.Salmon.g)
		AssertEquals($72, SColor8.Salmon.b)
		AssertEquals($FF, SColor8.Salmon.a)
	End Method

	Method TestGlobalColorsSandyBrown() {test}
		AssertEquals($FFF4A460, SColor8.SandyBrown.ToRGBA())
		AssertEquals($F4, SColor8.SandyBrown.r)
		AssertEquals($A4, SColor8.SandyBrown.g)
		AssertEquals($60, SColor8.SandyBrown.b)
		AssertEquals($FF, SColor8.SandyBrown.a)
	End Method

	Method TestGlobalColorsSeaGreen() {test}
		AssertEquals($FF2E8B57, SColor8.SeaGreen.ToRGBA())
		AssertEquals($2E, SColor8.SeaGreen.r)
		AssertEquals($8B, SColor8.SeaGreen.g)
		AssertEquals($57, SColor8.SeaGreen.b)
		AssertEquals($FF, SColor8.SeaGreen.a)
	End Method

	Method TestGlobalColorsSeaShell() {test}
		AssertEquals($FFFFF5EE, SColor8.SeaShell.ToRGBA())
		AssertEquals($FF, SColor8.SeaShell.r)
		AssertEquals($F5, SColor8.SeaShell.g)
		AssertEquals($EE, SColor8.SeaShell.b)
		AssertEquals($FF, SColor8.SeaShell.a)
	End Method

	Method TestGlobalColorsSienna() {test}
		AssertEquals($FFA0522D, SColor8.Sienna.ToRGBA())
		AssertEquals($A0, SColor8.Sienna.r)
		AssertEquals($52, SColor8.Sienna.g)
		AssertEquals($2D, SColor8.Sienna.b)
		AssertEquals($FF, SColor8.Sienna.a)
	End Method

	Method TestGlobalColorsSilver() {test}
		AssertEquals($FFC0C0C0, SColor8.Silver.ToRGBA())
		AssertEquals($C0, SColor8.Silver.r)
		AssertEquals($C0, SColor8.Silver.g)
		AssertEquals($C0, SColor8.Silver.b)
		AssertEquals($FF, SColor8.Silver.a)
	End Method

	Method TestGlobalColorsSkyBlue() {test}
		AssertEquals($FF87CEEB, SColor8.SkyBlue.ToRGBA())
		AssertEquals($87, SColor8.SkyBlue.r)
		AssertEquals($CE, SColor8.SkyBlue.g)
		AssertEquals($EB, SColor8.SkyBlue.b)
		AssertEquals($FF, SColor8.SkyBlue.a)
	End Method

	Method TestGlobalColorsSlateBlue() {test}
		AssertEquals($FF6A5ACD, SColor8.SlateBlue.ToRGBA())
		AssertEquals($6A, SColor8.SlateBlue.r)
		AssertEquals($5A, SColor8.SlateBlue.g)
		AssertEquals($CD, SColor8.SlateBlue.b)
		AssertEquals($FF, SColor8.SlateBlue.a)
	End Method

	Method TestGlobalColorsSlateGray() {test}
		AssertEquals($FF708090, SColor8.SlateGray.ToRGBA())
		AssertEquals($70, SColor8.SlateGray.r)
		AssertEquals($80, SColor8.SlateGray.g)
		AssertEquals($90, SColor8.SlateGray.b)
		AssertEquals($FF, SColor8.SlateGray.a)
	End Method

	Method TestGlobalColorsSlateGrey() {test}
		AssertEquals($FF708090, SColor8.SlateGrey.ToRGBA())
		AssertEquals($70, SColor8.SlateGrey.r)
		AssertEquals($80, SColor8.SlateGrey.g)
		AssertEquals($90, SColor8.SlateGrey.b)
		AssertEquals($FF, SColor8.SlateGrey.a)
	End Method

	Method TestGlobalColorsSnow() {test}
		AssertEquals($FFFFFAFA, SColor8.Snow.ToRGBA())
		AssertEquals($FF, SColor8.Snow.r)
		AssertEquals($FA, SColor8.Snow.g)
		AssertEquals($FA, SColor8.Snow.b)
		AssertEquals($FF, SColor8.Snow.a)
	End Method

	Method TestGlobalColorsSpringGreen() {test}
		AssertEquals($FF00FF7F, SColor8.SpringGreen.ToRGBA())
		AssertEquals($00, SColor8.SpringGreen.r)
		AssertEquals($FF, SColor8.SpringGreen.g)
		AssertEquals($7F, SColor8.SpringGreen.b)
		AssertEquals($FF, SColor8.SpringGreen.a)
	End Method

	Method TestGlobalColorsSteelBlue() {test}
		AssertEquals($FF4682B4, SColor8.SteelBlue.ToRGBA())
		AssertEquals($46, SColor8.SteelBlue.r)
		AssertEquals($82, SColor8.SteelBlue.g)
		AssertEquals($B4, SColor8.SteelBlue.b)
		AssertEquals($FF, SColor8.SteelBlue.a)
	End Method

	Method TestGlobalColorsTan() {test}
		AssertEquals($FFD2B48C, SColor8.Tan.ToRGBA())
		AssertEquals($D2, SColor8.Tan.r)
		AssertEquals($B4, SColor8.Tan.g)
		AssertEquals($8C, SColor8.Tan.b)
		AssertEquals($FF, SColor8.Tan.a)
	End Method

	Method TestGlobalColorsTeal() {test}
		AssertEquals($FF008080, SColor8.Teal.ToRGBA())
		AssertEquals($00, SColor8.Teal.r)
		AssertEquals($80, SColor8.Teal.g)
		AssertEquals($80, SColor8.Teal.b)
		AssertEquals($FF, SColor8.Teal.a)
	End Method

	Method TestGlobalColorsThistle() {test}
		AssertEquals($FFD8BFD8, SColor8.Thistle.ToRGBA())
		AssertEquals($D8, SColor8.Thistle.r)
		AssertEquals($BF, SColor8.Thistle.g)
		AssertEquals($D8, SColor8.Thistle.b)
		AssertEquals($FF, SColor8.Thistle.a)
	End Method

	Method TestGlobalColorsTomato() {test}
		AssertEquals($FFFF6347, SColor8.Tomato.ToRGBA())
		AssertEquals($FF, SColor8.Tomato.r)
		AssertEquals($63, SColor8.Tomato.g)
		AssertEquals($47, SColor8.Tomato.b)
		AssertEquals($FF, SColor8.Tomato.a)
	End Method

	Method TestGlobalColorsTurquoise() {test}
		AssertEquals($FF40E0D0, SColor8.Turquoise.ToRGBA())
		AssertEquals($40, SColor8.Turquoise.r)
		AssertEquals($E0, SColor8.Turquoise.g)
		AssertEquals($D0, SColor8.Turquoise.b)
		AssertEquals($FF, SColor8.Turquoise.a)
	End Method

	Method TestGlobalColorsViolet() {test}
		AssertEquals($FFEE82EE, SColor8.Violet.ToRGBA())
		AssertEquals($EE, SColor8.Violet.r)
		AssertEquals($82, SColor8.Violet.g)
		AssertEquals($EE, SColor8.Violet.b)
		AssertEquals($FF, SColor8.Violet.a)
	End Method

	Method TestGlobalColorsWheat() {test}
		AssertEquals($FFF5DEB3, SColor8.Wheat.ToRGBA())
		AssertEquals($F5, SColor8.Wheat.r)
		AssertEquals($DE, SColor8.Wheat.g)
		AssertEquals($B3, SColor8.Wheat.b)
		AssertEquals($FF, SColor8.Wheat.a)
	End Method

	Method TestGlobalColorsWhite() {test}
		AssertEquals($FFFFFFFF, SColor8.White.ToRGBA())
		AssertEquals($FF, SColor8.White.r)
		AssertEquals($FF, SColor8.White.g)
		AssertEquals($FF, SColor8.White.b)
		AssertEquals($FF, SColor8.White.a)
	End Method

	Method TestGlobalColorsWhiteSmoke() {test}
		AssertEquals($FFF5F5F5, SColor8.WhiteSmoke.ToRGBA())
		AssertEquals($F5, SColor8.WhiteSmoke.r)
		AssertEquals($F5, SColor8.WhiteSmoke.g)
		AssertEquals($F5, SColor8.WhiteSmoke.b)
		AssertEquals($FF, SColor8.WhiteSmoke.a)
	End Method

	Method TestGlobalColorsYellow() {test}
		AssertEquals($FFFFFF00, SColor8.Yellow.ToRGBA())
		AssertEquals($FF, SColor8.Yellow.r)
		AssertEquals($FF, SColor8.Yellow.g)
		AssertEquals($00, SColor8.Yellow.b)
		AssertEquals($FF, SColor8.Yellow.a)
	End Method

	Method TestGlobalColorsYellowGreen() {test}
		AssertEquals($FF9ACD32, SColor8.YellowGreen.ToRGBA())
		AssertEquals($9A, SColor8.YellowGreen.r)
		AssertEquals($CD, SColor8.YellowGreen.g)
		AssertEquals($32, SColor8.YellowGreen.b)
		AssertEquals($FF, SColor8.YellowGreen.a)
	End Method

End Type
