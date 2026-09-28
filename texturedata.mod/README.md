# Texture data

`BRL.TextureData` complements `TPixmap`. It owns texture bytes and describes
rows and mip levels without requiring per-pixel colour operations or a graphics
context. Pixmap conversion helpers are included; the stored representation is
not a pixmap.

## Convert to and from a pixmap

```blitzmax
Local data:TTextureData=TTextureData.FromPixmap(pixmap)
Local copy:TPixmap=data.ToPixmap()
```

For pixmap-compatible formats, both operations make independent copies and preserve the pixel format. Pixmap
windows and padded rows work too. `FromPixmap` copies only active pixels into
compact rows. `ToPixmap(level)` selects an explicit mip level (zero by default)
and returns an ordinary editable pixmap. It does not combine mip levels.

## Supply raw bytes

```blitzmax
Local level:TTextureLevel=TTextureLevel.Create(width,height,PF_RGBA8888,bytes,pitch)
Local data:TTextureData=TTextureData.Create([level])
```

`pitch` is bytes per pixel row, or per block row for compressed formats; zero requests tightly packed rows. The byte array must
contain at least `pitch * GetPixelFormatInfo(format).StorageRows(height)` bytes,
including the final stored row's padding. Uncompressed storage has `height` rows.
Dimensions must be positive. The factory checks the format, minimum row size,
buffer length and allocation-size overflow before copying bytes. Each level is
limited to the size supported by a BlitzMax byte array (signed 32-bit length).
There is no file format or file access here: bytes can come from a stream,
archive, decoder or generated content.

`TTextureLevel.Create` copies its array, and `TTextureData.Create` copies its
levels. `CopyBytes` and `Copy` also return independent storage. `Level()` returns
the owned level itself. `Data()` deliberately exposes a borrowed native pointer
for uploads or explicit byte editing; keep the level alive and respect
`ByteSize()`. Never free that pointer.

## Mip levels

Pass levels from largest to smallest. All must have the same format, and each
width and height must halve, rounded down and clamped to one. For example,
7×5 → 3×2 → 1×1 is valid. Partial chains are accepted; extra levels after 1×1
are rejected. `CompleteMipChain()` reports whether the last level is 1×1.
`ByteSize()` counts all levels, including row padding.

## Current format and renderer limits

This version describes uncompressed formats in `BRL.PixelFormat`, including
`PF_RGBA16F` and `PF_RGBA32F`, plus BC1 and BC3 compressed blocks. It stores their bytes without interpreting
or converting colours. Floating-point channels use native host byte order.
`ToPixmap` rejects floating-point data rather than silently reducing precision or
clamping its range. BC1/BC3 blocks retain their standard little-endian byte encoding on every host.
`ToPixmap` rejects compressed data; an explicit decoder would be needed. Planar
and cube textures are not yet implemented.

Having a valid container does not imply that a renderer accepts it. Max2D
accepts RGBA8888, A8, RGBA16F, RGBA32F, BC1_RGBA or BC3_RGBA data through `LoadImage(data)` or
`TImage.FromTextureData(data)`. OpenGL and D3D11 also accept supplied mip chains,
including partial chains, floating-point formats and compressed blocks. Use
`Max2DTextureDataSupport(data,flags)` to check the active backend. Multiple levels
enable mip sampling automatically and are uploaded unchanged using straight alpha.
Other pixmap-compatible formats can be converted explicitly through `ToPixmap()`
and the existing pixmap-loading path. A single uncompressed byte-format level with
`MIPMAPPEDIMAGE` requests automatic mipmap generation where supported. Automatic
float mipmaps are not supported. On supported OpenGL and D3D11 devices, Max2D
can create floating-point render targets separately with `CreateRenderImage`.
`ReadRenderTextureData` reads these into RGBA32F data, preserving their range;
RGBA16F channels are widened to 32-bit floats.

Max2D snapshots supplied texture data. Its texture-data-backed images are
read-only: uncompressed byte-format read locks return independent pixmaps; floating-point
and compressed read locks and collision tests are unavailable; dynamic flags, write locks and
pixel replacement are rejected. To edit pixels using existing Max2D facilities,
load `data.ToPixmap()` with `DYNAMICIMAGE` instead.

## Optional container loaders

`LoadTextureData(url)` uses providers registered by imported modules. Import
`Image.DDS` to read supported BC1/BC3 DDS files. No format-specific parser is
included by importing `BRL.TextureData` alone.

URLs and seekable `TStream` objects go through `ReadStream`, preserving stream
factories and BRL.IO virtual files. Unrecognised data returns `Null` and leaves a
caller-owned stream at its starting position; success advances past the texture.
Caller streams stay open. Recognised invalid or unsupported files throw an error.
Generic probing requires seeking; format-specific functions may support
forward-only streams (`LoadTextureDDS` does).

To add a container format, extend `TTextureDataLoader` and construct a module-level
instance. Its `LoadTextureData(stream)` method returns `Null` for an unknown
signature, throws for recognised errors, and never closes the stream. The
registry resets the stream before each provider. `HasTextureDataLoaders()` allows
consumers to skip probing when no provider is registered.

## Explicit display conversion

`ToPixmap()` remains an unchanged-format copy and still rejects floating-point
storage. Use `ConvertToPixmap(options,index=0)` when you deliberately want to
reduce RGBA16F/32F data to RGBA8888. RGBA8888 input is also accepted for explicit
transfer-encoding conversion. Other formats must first be converted to RGBA8888
through their existing pixmap conversion or decoding path.

```blitzmax
Local options:TTexturePixmapOptions=New TTexturePixmapOptions
options.exposureStops=-2 ' Divide linear brightness by four.
options.toneMap=ETextureToneMap.Reinhard
options.outputEncoding=ETextureEncoding.SRGB
Local pixmap:TPixmap=data.ConvertToPixmap(options)
' Pass pixmap to an existing image encoder or LoadImage.
```

Defaults are linear input/output, straight input alpha, zero exposure adjustment,
and clipping. These defaults do not guess how the source colours were authored.
Use `sourceEncoding=ETextureEncoding.SRGB` only for sRGB-encoded input. Floating
storage alone says nothing about encoding; Max2D does not automatically turn
existing drawing colours or sampled images into linear-light colours.

Conversion runs in this order:

1. Unassociate RGB if `sourceAlpha=ETextureAlphaMode.Premultiplied`.
2. Decode the source RGB encoding to linear values.
3. Multiply RGB by `2^exposureStops` (finite stops from -64 to 64).
4. Clip, or apply per-channel Reinhard `x/(1+x)` to nonnegative RGB.
5. Encode output RGB, clamp to 0–1, and round to the nearest 8-bit value.

The sRGB transfer uses the standard piecewise curve, not a gamma-2.2 approximation
([sRGB specification](https://www.w3.org/Graphics/Color/srgb)). This changes transfer
encoding only: it is not ICC profile conversion or gamut mapping. Reinhard is a
simple operator and can change saturation; it is not a filmic or local tone mapper.

Alpha is clamped independently and never gamma-corrected or exposed. Output is
straight alpha. Premultiplication is interpreted in the source's encoding, using
alpha clamped to 0–1; zero alpha produces zero RGB when unassociating. Straight
input retains hidden RGB at zero alpha. Negative values and NaN become zero;
positive infinity becomes one, including with Reinhard. No dithering is applied.

This allocates a fresh CPU pixmap, processes only the requested mip level, and
leaves source data untouched. Padded and unaligned source rows are supported.
Cache converted results instead of converting each frame. For a Max2D target,
first call `ReadRenderTextureData(target)` (which synchronizes with the GPU), then
convert its straight-alpha data. Conversion itself has no graphics dependency.

Run `tests/conversion.bmx` for numeric, half-float, row-pitch, alpha and exceptional
value tests. `Max2D/examples/texture_conversion.bmx` compares clipping, exposure
and Reinhard using cached converted images.
