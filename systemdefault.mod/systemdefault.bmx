
Strict

Rem
bbdoc: System/System
End Rem
Module BRL.SystemDefault

ModuleInfo "Version: 1.29"
ModuleInfo "Author: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.29"
ModuleInfo "History: Split out into BRL.System and BRL.SystemDefault modules."
ModuleInfo "History: 1.28"
ModuleInfo "History: Added custom format option to CurrentDate()."
ModuleInfo "History: 1.27"
ModuleInfo "History: Moved event enums from system.h to event.mod/event.h"
ModuleInfo "Histroy: Moved keycode enums from system.h to keycodes.mod/keycodes.h"
ModuleInfo "History: 1.26 Release"
ModuleInfo "History: Fixed win32 filerequester causing activewindow dramas"
ModuleInfo "History: 1.25 Release"
ModuleInfo "History: Fixed unretained object issue with mouse tracking"
ModuleInfo "History: 1.24 Release"
ModuleInfo "History: Fixed windowed mode HideMouse issue"
ModuleInfo "History: 1.23 Release"
ModuleInfo "History: Fixed win32 requestfile default extension bug#2"
ModuleInfo "History: 1.22 Release"
ModuleInfo "History: Fixed win32 requestfile default extension bug"
ModuleInfo "History: 1.21 Release"
ModuleInfo "History: New Linux implementation of OpenURL"
ModuleInfo "History: 1.20 Release"
ModuleInfo "History: RequestFile now adds extension to filename on Windows"
ModuleInfo "History: 1.19 Release"
ModuleInfo "History: Added EVENT_GADGETLOSTFOCUS handling"
ModuleInfo "History: 1.18 Release"
ModuleInfo "History: Added EVENT_KEYREPEAT handling"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: OpenURL now attempts to fully qualify file / http url supplied"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: Fixed MacOS RequestFile to respect wild card filter"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Fixed mouse hidden by default"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed HideMouse causing mouse to disappear when in non-client areas"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Fixed Linux MoveMouse to be relative to the origin of the current Graphics window"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added Linux X11 import to remove glgraphics.mod dependency"
ModuleInfo "History: Fixed linux middle button crash"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Fixed win32 clipboard glitches with QS_ALLINPUT bbSystemWait mod"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: CGSetLocalEventsSuppressionInterval fix for MacOS bbSystemMoveMouse"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Ripped out input stuff and added hook"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Tweaked MacOS GetChar()"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added AppTitle support for requesters"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed MacOS RequestDir ignoring initial path"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added RequestDir support for MacOS"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added mouse capture to Win32"
ModuleInfo "History: Fixed C Compiler warnings"

Import BRL.System
Import BRL.KeyCodes
Import BRL.Hook

?Not android
Import "system.c"
?

?osx
Import "system.macos.bmx"
InitSystemDriver(New TMacOSSystemDriver)
?Win32
Import "system.win32.bmx"
Import "-lcomdlg32"
InitSystemDriver(New TWin32SystemDriver)
?Linux
Import "system.linux.bmx"
?
