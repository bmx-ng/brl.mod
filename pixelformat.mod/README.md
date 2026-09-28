# Pixel formats

`BRL.PixelFormat` provides format identifiers and storage information without a
window, renderer, SDL dependency or image decoder. `BRL.Pixmap` imports it, so
existing Pixmap applications can continue using the same constants.

The catalog describes the existing byte-addressable formats plus R8, RG88,
intensity/alpha pairs, RGB332,
RGB565/BGR565, four 4444 channel orders, and four 5551/1555 channel orders. Indexed pixels, float channels, planar video and GPU-compressed
blocks remain future additions; their storage must not be inferred using a
whole-number bytes-per-pixel formula.

## Choose the byte order your consumer needs

```blitzmax
Local pixels:TPixmap=CreatePixmap(240,320,PF_RGB565_BE,1)
pixels.ClearPixels($ff000000)
pixels.WritePixel(10,20,$ffff0000)
```

Import `BRL.Pixmap` for this example. Each red pixel is stored as the bytes
`F8 00`, on every host. `PF_RGB565_LE` stores `00 F8`. The `PF_RGB565` alias uses
host-native byte order. BGR565 reverses the red and blue bit fields; it does not
reverse the byte order. Choose channel order and byte order independently based
on your display or image consumer. Controller commands and display transfer
protocols remain the display driver's responsibility.

The default Pixmap row alignment is four bytes. Passing `1` above requests tight
rows. External buffers can have padding and need not be word-aligned.

`ReadPixel` returns the existing ARGB integer representation. RGB565/BGR565 have
no alpha, so reads return alpha 255 and writes discard it. Eight-bit colour
channels are quantised by dropping low bits; expansion repeats high bits to fill
eight bits. Conversion does not perform dithering or colour-space transforms.

## Query storage without creating an image

```blitzmax
Local info:TPixelFormatInfo=GetPixelFormatInfo(PF_RGB565_BE)
Local pitch:Long=info.RowPitch(240,4)
Local bytes:Long=info.StorageSize(240,320,4)
```

`GetPixelFormatInfo` returns a new snapshot or `Null` for an unknown identifier.
Retain it for repeated queries. It reports channel precision, bytes per pixel,
and packed-word order/bit positions. Byte-array formats have `PIXEL_ORDER_BYTES`;
their existing names describe channel order in memory. Packed formats specify
`PIXEL_ORDER_LITTLE_ENDIAN` or `PIXEL_ORDER_BIG_ENDIAN`.

Size calculations use `Long`, reject negative dimensions/nonpositive alignment,
and reject overflow. A computed size is not an allocation guarantee: TPixmap's
existing fields and allocation limits are unchanged. The legacy Pixmap tables
remain available, including their historical values; the descriptor reports
storage information independently of those mutable tables.

## Using these images elsewhere

Pixmap supports conversion, copying, cropping, flips, resizing, clearing and both
pixel-write overloads for the new formats. A consumer that accepts only RGB888
or RGBA8888 should receive an explicit `pixmap.Convert(...)` result. Format
metadata describes storage, not support by every encoder, device or renderer.

Ordinary Max2D images convert these formats to RGBA8. Its opt-in PF_A8
coverage path can retain single-channel storage; other compact GPU formats
remain separate renderer work.

## Compatibility and testing

Existing identifiers 1–14 and the TPixmap field layout are preserved. RGB565/BGR565
formats occupy 15–18; the additional compact formats occupy 19–35, and the
new channel formats occupy 36–39. Applications importing BRL.Pixmap retain access to all
existing constants. Rebuild dependent modules after installing this update.
The shared module has no SDL dependency.

`pixmap.mod/tests/packed_formats.bmx` covers every 16-bit packed value in both
channel and byte orders, known raw bytes, padded/external storage, pixel writes,
conversions and common operations. It also guards existing ARGB/ABGR write and
clear behaviour, including untouched row padding and buffer boundaries.

From the SDK directory:

```sh
bin/bmk makeapp -r -o /tmp/packed-formats mod/brl.mod/pixmap.mod/tests/packed_formats.bmx
/tmp/packed-formats
```

On Windows use `bin\bmk.exe` and a suitable executable output path. The test
requires no graphics context. Omit `-r` to test a debug build.

## Compact colour with alpha

| Format family | Storage | Alpha |
| --- | --- | --- |
| `PF_RGB332` | One byte: red bits 5–7, green 2–4, blue 0–1 | Opaque |
| `PF_RGB565`, `PF_BGR565` | Two bytes, 5/6/5-bit colour | Opaque |
| `PF_RGBA4444`, `PF_BGRA4444`, `PF_ARGB4444`, `PF_ABGR4444` | Two bytes, four bits per channel | 16 levels |
| `PF_RGBA5551`, `PF_BGRA5551` | Two bytes, five bits per colour channel | One low bit |
| `PF_ARGB1555`, `PF_ABGR1555` | Two bytes, five bits per colour channel | One high bit |

For every two-byte family, use `_LE` or `_BE` to choose storage explicitly; the
unsuffixed name means host-native byte order. Names describe channel fields from
the most-significant bit to the least-significant bit of the decoded word.
For example, `PF_RGBA4444_BE` stores RG in its first byte and BA in its second.

Writes discard low channel bits. Reads expand bits by replication, including
alpha. Four-bit alpha expands to 0, 17, 34, ..., 255. One-bit alpha writes 0 for
values 0–127 and 1 for 128–255, then reads as 0 or 255. These are storage rules,
independent of the blend mode subsequently used to draw the image.

All these formats support the ordinary Pixmap operations. Conversion uses no
per-pixel managed allocations. The packed-format descriptor now includes
`alphaShift`, alongside colour shifts, for locating alpha within the word.
An absent alpha channel has `alphaBits=0`; ignore its shift value.

`pixmap.mod/tests/compact_formats.bmx` checks every possible stored value in each
new format, independently specified channel-placement examples, alpha thresholds,
unaligned/padded storage and standard operations. Build it like the earlier test.

### Existing Pixmap applications

Constants are defined in `BRL.PixelFormat`. Importing `BRL.Pixmap` still makes
unqualified names such as `PF_RGBA8888` available. For qualified access, use
`BRL.PixelFormat.PF_RGBA8888`. Existing field types, default row
alignment, standard format, and historical entries in the lookup tables remain
unchanged. New formats are opt-in. The intentional fixes to existing behaviour
are the ARGB clear buffer overrun and incorrect ABGR integer-write/clear channels.

`pixmap.mod/tests/legacy_formats.bmx` exercises existing identifiers and lookup
tables, both pixel-write overloads, clears, copies, flips,
resizing, and every conversion/paste pair among the established formats.

## Single- and dual-channel pixels

| Format | Bytes in memory | Expanded RGBA |
| --- | --- | --- |
| `PF_A8` (existing) | Alpha | White RGB, stored alpha |
| `PF_I8` (existing) | Intensity | Stored intensity in RGB, opaque alpha |
| `PF_R8` | Red | Stored red, zero green/blue, opaque alpha |
| `PF_RG88` | Red, green | Stored red/green, zero blue, opaque alpha |
| `PF_IA88` | Intensity, alpha | Stored intensity in RGB, stored alpha |
| `PF_AI88` | Alpha, intensity | Stored intensity in RGB, stored alpha |

These are byte arrays: their memory order is the same on every host, without
endian suffixes. Values are unsigned 0–255. `PF_R8` is distinct from legacy
`PF_RED`; that older format's conversion behaviour has deliberately been retained.

For intensity/alpha formats, RGB input becomes the arithmetic mean of its red,
green and blue channels, just like `PF_I8`. Alpha is independent. This is not a
colour-space or luminance-weighted conversion. Red and red/green formats simply
retain their named colour channels and discard input alpha.

```blitzmax
Local mask:TPixmap=CreatePixmap(256,256,PF_A8)
mask.ClearPixels($80ffffff) ' 128 coverage, one byte per pixel

Local grayscale:TPixmap=CreatePixmap(256,256,PF_IA88)
grayscale.ClearPixels($80808080) ' 128 intensity and 128 alpha, two bytes
```

All new formats support read/write (including SColor8), conversion, paste, clear,
copy, windows, flips and resize. `channel_formats.bmx` tests every representable
byte pair, raw channel interpretation, padded/unaligned buffers, operations and
preservation of the older `PF_RED` conversion.

Glyph coverage should use `PF_A8`, not `PF_R8`: coverage controls transparency,
whereas red-channel pixels represent colour/data. Supporting one-channel GPU
storage requires the renderer to preserve that distinction when sampling.
Max2D can retain PF_A8 glyph coverage on the CPU and in its non-mipmapped
OpenGL and supported D3D11 textures. Other backends currently expand coverage
to RGBA for upload.
The new R8/RG88/IA88/AI88 CPU formats alone do not reduce GPU storage.

## Floating-point texture formats

`PF_RGBA16F` stores four IEEE binary16 channels (8 bytes per pixel), and
`PF_RGBA32F` stores four IEEE binary32 channels (16 bytes per pixel). Channels
are ordered R, G, B, A; multi-byte channel values use native host byte order.
`GetPixelFormatInfo` reports `floatingPoint=True`, channel bit counts, byte order
and storage sizes. This metadata does not assert renderer support.

These formats belong in `BRL.TextureData`. They are not supported by TPixmap's
integer colour operations, and pixmap factories/conversion functions reject them.
The legacy Pixmap lookup arrays remain unchanged; use `GetPixelFormatInfo` for
storage formats outside that pixmap catalog. No automatic clamping, tone mapping,
or precision reduction is performed.

## Compressed blocks

`PF_BC1_RGBA` and `PF_BC3_RGBA` describe BC1/DXT1 and BC3/DXT5 UNORM texture
storage. Both use 4×4 blocks: eight bytes for BC1, sixteen for BC3. BC1 supports
one-bit transparency; BC3 stores interpolated alpha. They do not request sRGB
sampling. Block bytes use the standard little-endian encoding on all hosts.

For compressed formats, `compressed` is true, `bytesPerPixel` and channel bit
counts are zero, and `blockWidth`, `blockHeight` and `bytesPerBlock` describe the
storage unit. `RowPitch(width)` rounds up to whole blocks; `StorageRows(height)`
returns block rows; `StorageSize(width,height)` includes edge blocks. Even a 1×1
mip level needs one full block. For uncompressed formats, block dimensions are
one, `bytesPerBlock` equals `bytesPerPixel`, and existing size calculations are
unchanged.

Use these formats with `TTextureData`. TPixmap operations reject them, and no
encoder or decoder is implied by the metadata. Backend support is a separate
query: D3D11, for example, requires block-aligned base texture dimensions.
