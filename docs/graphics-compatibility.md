# Graphics compatibility review

Baseline: BRL `c22ccef8b6e13c4c4052b15d94b13eb22f877ae8`.
Review date: 24 September 2026.

The graphics changes have no dependency on the new Max2D namespace. BRL.Max2D's
public drawing API, image/frame hierarchy, and driver selection remain intact.
The BRL.D3D9Max2D changes are explicit numeric conversions for the corrected
DirectX declarations. D3D7 graphics and both D3D7 Max2D implementations are disabled;
D3D9 is the supported Direct3D minimum.

## Compatibility correction found during review

Applying 96-DPI logical sizing to every D3D9 window changed the old coordinate
contract for already-DPI-aware programs. At 200%, a legacy `Graphics(320,240)` had
320 drawing units but 640 native mouse/client units. Ordinary `CreateGraphics`
now retains native client units. `CreateLogicalGraphics` explicitly opts into the
new logical-size convention for adapters that map input separately. Existing BRL
callers do not need to change. The new Max2D adapter uses the opt-in factory.

## Standalone BRL regressions

These tests require only BRL/Pub; they can ship and run without max2d.mod:

- `glgraphics.mod/tests/legacy_render.bmx`: clear, primitive/image readback, viewport.
- `glgraphics.mod/tests/legacy_window_management.bmx`: resize/move, textures and drawing.
- `dxgraphics.mod/tests/legacy_d3d9.bmx`: legacy D3D9 resize/move and image readback.
- `dxgraphics.mod/tests/legacy_dpi.bmx`: already-aware D3D9 client/drawing units,
  including resize. A 200% Windows VM exposed the mismatch before the correction.

Fresh Windows 11 VM runs passed legacy GL rendering, D3D9 window management, and
D3D9 already-aware coordinate consistency after the correction.

The same `legacy_render.bmx` was compiled against the baseline and current
GLGraphics sources, with the same compiler and remaining modules:

| Environment | Baseline | Current |
|---|---|---|
| macOS Retina, default drawable | Primitive readback fails | Same failure |
| Linux ARM64 Xwayland, VM acceleration | Image readback fails | Same failure |
| Linux ARM64 Xwayland, Mesa software | Pass | Pass |

These failures predate this work; their exact causes are not yet established.
They should not be dismissed as driver bugs without further investigation.
Existing legacy GL window-management checks passed previously on macOS/Windows;
Linux passes those checks with software rendering. New Max2D backend tests are
additional coverage, not substitutes for legacy tests.

## Merge requirements and limits

- Merge the companion Pub.DirectX type corrections, Pub.DXGI, and Pub.Direct3D11
  bindings with/before BRL. BRL.DXGraphics imports the new bindings on Windows.
  D3D11/DXGI DLL entry points are resolved dynamically when used.
- Linux GL now needs the Xrandr development library to build. Borderless capability
  requires EWMH fullscreen support and RandR 1.5. Runtime exclusive remains absent.
- Rebuild affected modules/applications; binary compatibility with prebuilt module
  interfaces is not promised after adding graphics methods/fields.
- Resize/position were previously no-ops in GLGraphics. They now perform requests
  and may throw for invalid/unsupported contexts or WM refusal/timeouts.
- Attached-widget management, 32-bit builds, physical Windows GPUs, mixed-DPI and
  multiple-monitor/hotplug cases still need dedicated validation.

No claim is made that every legacy platform scenario has been exhaustively tested.

## Targeted legacy rendering follow-up

The macOS failure is fixed in BRL.GLMax2D. The window's Retina drawable can be
640x480 for a 320x240 logical canvas. Readback and clipping previously used the
logical coordinates as backing-pixel coordinates. The fix scales backbuffer
pixel operations using the attached view's drawable size. `GrabPixmap` still
returns the requested dimensions, and render-image coordinates remain unchanged.
The regression now also covers DrawPixmap/readback and switching to/from a render
image. This is a coordinate correction, with no new drawing API or frame model.

The Linux VM issue reproduces in a standalone native GLX program, without BlitzMax:
`glgraphics.mod/tests/legacy_texture_probe.c`. On virgl (Apple M4 Max Compat), the
primitive is green as expected but the red texture samples white; llvmpipe returns
red correctly. This isolates the failure to the VM's accelerated legacy OpenGL
path. An explicit RGBA8 allocation did not fix it, so no speculative texture-format
change or renderer replacement is included. The workaround for affected legacy
apps is `LIBGL_ALWAYS_SOFTWARE=1 ./application`.

Native reproduction on Linux:

```sh
cc mod/brl.mod/glgraphics.mod/tests/legacy_texture_probe.c -o /tmp/legacy-texture-probe -lX11 -lGL
/tmp/legacy-texture-probe
LIBGL_ALWAYS_SOFTWARE=1 /tmp/legacy-texture-probe
```
