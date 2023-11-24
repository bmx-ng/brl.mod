
SuperStrict

Rem
bbdoc: User input/Key codes
End Rem
Module BRL.KeyCodes

ModuleInfo "Version: 1.05"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Removed KEY_NUMSLASH from docs"

Const MOUSE_LEFT:Int=1
Const MOUSE_RIGHT:Int=2
Const MOUSE_MIDDLE:Int=3

Const MODIFIER_NONE:Int=0
Const MODIFIER_SHIFT:Int=1			'shift key
Const MODIFIER_CONTROL:Int=2		'ctrl key
Const MODIFIER_OPTION:Int=4			'alt or menu key
Const MODIFIER_SYSTEM:Int=8			'windows or apple key

Const MODIFIER_LMOUSE:Int=16		'reserved by Mark!
Const MODIFIER_RMOUSE:Int=32		'reserved by Mark!
Const MODIFIER_MMOUSE:Int=64		'reserved by Mark!

Const MODIFIER_ALT:Int=MODIFIER_OPTION
Const MODIFIER_MENU:Int=MODIFIER_OPTION
Const MODIFIER_APPLE:Int=MODIFIER_SYSTEM
Const MODIFIER_WINDOWS:Int=MODIFIER_SYSTEM

?MACOS
Const MODIFIER_COMMAND:Int=MODIFIER_APPLE
?Win32
Const MODIFIER_COMMAND:Int=MODIFIER_CONTROL
?Linux
Const MODIFIER_COMMAND:Int=MODIFIER_CONTROL
?

Const KEY_BACKSPACE:Int=8
Const KEY_TAB:Int=9
Const KEY_CLEAR:Int=12
Const KEY_RETURN:Int=13
Const KEY_ENTER:Int=13
Const KEY_ESCAPE:Int=27
Const KEY_SPACE:Int=32
Const KEY_PAGEUP:Int=33
Const KEY_PAGEDOWN:Int=34
Const KEY_END:Int=35
Const KEY_HOME:Int=36

Const KEY_LEFT:Int=37,KEY_UP:Int=38,KEY_RIGHT:Int=39,KEY_DOWN:Int=40

Const KEY_SELECT:Int=41
Const KEY_PRINT:Int=42
Const KEY_EXECUTE:Int=43
Const KEY_SCREEN:Int=44
Const KEY_INSERT:Int=45
Const KEY_DELETE:Int=46

Const KEY_0:Int=48,KEY_1:Int=49,KEY_2:Int=50,KEY_3:Int=51,KEY_4:Int=52
Const KEY_5:Int=53,KEY_6:Int=54,KEY_7:Int=55,KEY_8:Int=56,KEY_9:Int=57
Const KEY_A:Int=65,KEY_B:Int=66,KEY_C:Int=67,KEY_D:Int=68,KEY_E:Int=69
Const KEY_F:Int=70,KEY_G:Int=71,KEY_H:Int=72,KEY_I:Int=73,KEY_J:Int=74
Const KEY_K:Int=75,KEY_L:Int=76,KEY_M:Int=77,KEY_N:Int=78,KEY_O:Int=79
Const KEY_P:Int=80,KEY_Q:Int=81,KEY_R:Int=82,KEY_S:Int=83,KEY_T:Int=84
Const KEY_U:Int=85,KEY_V:Int=86,KEY_W:Int=87,KEY_X:Int=88,KEY_Y:Int=89
Const KEY_Z:Int=90

Const KEY_NUM0:Int=96
Const KEY_NUM1:Int=97
Const KEY_NUM2:Int=98
Const KEY_NUM3:Int=99
Const KEY_NUM4:Int=100
Const KEY_NUM5:Int=101
Const KEY_NUM6:Int=102
Const KEY_NUM7:Int=103
Const KEY_NUM8:Int=104
Const KEY_NUM9:Int=105

Const KEY_NUMMULTIPLY:Int=106
Const KEY_NUMADD:Int=107
Const KEY_NUMSUBTRACT:Int=109
Const KEY_NUMDECIMAL:Int=110
Const KEY_NUMDIVIDE:Int=111

Const KEY_F1:Int=112
Const KEY_F2:Int=113
Const KEY_F3:Int=114
Const KEY_F4:Int=115
Const KEY_F5:Int=116
Const KEY_F6:Int=117
Const KEY_F7:Int=118
Const KEY_F8:Int=119
Const KEY_F9:Int=120
Const KEY_F10:Int=121
Const KEY_F11:Int=122
Const KEY_F12:Int=123

Const KEY_TILDE:Int=192
Const KEY_MINUS:Int=189
Const KEY_EQUALS:Int=187

Const KEY_OPENBRACKET:Int=219
Const KEY_CLOSEBRACKET:Int=221
Const KEY_BACKSLASH:Int=226

Const KEY_SEMICOLON:Int=186
Const KEY_QUOTES:Int=222

Const KEY_COMMA:Int=188
Const KEY_PERIOD:Int=190
Const KEY_SLASH:Int=191

Const KEY_LSHIFT:Int=160
Const KEY_RSHIFT:Int=161
Const KEY_LCONTROL:Int=162
Const KEY_RCONTROL:Int=163
Const KEY_LALT:Int=164
Const KEY_RALT:Int=165
Const KEY_LSYS:Int=91
Const KEY_RSYS:Int=92

Const KEY_BROWSER_BACK:Int=166
Const KEY_BROWSER_FORWARD:Int=167
Const KEY_BROWSER_REFRESH:Int=168
Const KEY_BROWSER_STOP:Int=169
Const KEY_BROWSER_SEARCH:Int=170
Const KEY_BROWSER_FAVORITES:Int=171
Const KEY_BROWSER_HOME:Int=172
Rem
Const KEY_PAUSE:Int=19
Const KEY_CAPSLOCK:Int=20
Const KEY_HELP:Int=47
Const KEY_NUMSLASH:Int=108
Const KEY_START:Int=93
Const KEY_NUMLOCK:Int=144
Const KEY_SCROLL:Int=145
Const KEY_VOLUME_MUTE:Int=173
Const KEY_VOLUME_DOWN:Int=174
Const KEY_VOLUME_UP:Int=175
Const KEY_MEDIA_NEXT_TRACK:Int=176
Const KEY_MEDIA_PREV_TRACK:Int=177
Const KEY_MEDIA_STOP:Int=178
Const KEY_MEDIA_PLAY_PAUSE:Int=179
Const KEY_LAUNCH_MAIL:Int=180
Const KEY_LAUNCH_MEDIA_SELECT:Int=181
Const KEY_LAUNCH_APP1:Int=182
Const KEY_LAUNCH_APP2:Int=183
End Rem

Function NameForKey:String( key:Int )
	Select key
	Case KEY_BACKSPACE	Return "Backspace"
	Case KEY_TAB		Return "Tab"
	Case KEY_CLEAR		Return "Clear"
	Case KEY_RETURN		Return "Return"
	Case KEY_ENTER		Return "Enter"
	Case KEY_ESCAPE		Return "Esc"
	Case KEY_SPACE		Return "Space"
	Case KEY_PAGEUP		Return "Page Up"
	Case KEY_PAGEDOWN	Return "Page Down"
	Case KEY_END		Return "End"
	Case KEY_HOME		Return "Home"

	Case KEY_LEFT		Return "Left"
	Case KEY_UP			Return "Up"
	Case KEY_RIGHT		Return "Right"
	Case KEY_DOWN		Return "Down"

	Case KEY_SELECT		Return "Select"
	Case KEY_PRINT		Return "Print"
	Case KEY_EXECUTE	Return "Execute"
	Case KEY_SCREEN		Return "Screen"
	Case KEY_INSERT		Return "Insert"
	Case KEY_DELETE		Return "Delete"

	Case KEY_0	Return "0"
	Case KEY_1	Return "1"
	Case KEY_2	Return "2"
	Case KEY_3	Return "3"
	Case KEY_4	Return "4"
	Case KEY_5	Return "5"
	Case KEY_6	Return "6"
	Case KEY_7	Return "7"
	Case KEY_8	Return "8"
	Case KEY_9	Return "9"
	Case KEY_A	Return "A"
	Case KEY_B	Return "B"
	Case KEY_C	Return "C"
	Case KEY_D	Return "D"
	Case KEY_E	Return "E"
	Case KEY_F	Return "F"
	Case KEY_G	Return "G"
	Case KEY_H	Return "H"
	Case KEY_I	Return "I"
	Case KEY_J	Return "J"
	Case KEY_K	Return "K"
	Case KEY_L	Return "L"
	Case KEY_M	Return "M"
	Case KEY_N	Return "N"
	Case KEY_O	Return "O"
	Case KEY_P	Return "P"
	Case KEY_Q	Return "Q"
	Case KEY_R	Return "R"
	Case KEY_S	Return "S"
	Case KEY_T	Return "T"
	Case KEY_U	Return "U"
	Case KEY_V	Return "V"
	Case KEY_W	Return "W"
	Case KEY_X	Return "X"
	Case KEY_Y	Return "Y"
	Case KEY_Z	Return "Z"

	Case KEY_NUM0	Return "Num 0"
	Case KEY_NUM1	Return "Num 1"
	Case KEY_NUM2	Return "Num 2"
	Case KEY_NUM3	Return "Num 3"
	Case KEY_NUM4	Return "Num 4"
	Case KEY_NUM5	Return "Num 5"
	Case KEY_NUM6	Return "Num 6"
	Case KEY_NUM7	Return "Num 7"
	Case KEY_NUM8	Return "Num 8"
	Case KEY_NUM9	Return "Num 9"

	Case KEY_NUMMULTIPLY	Return "Num Mul"
	Case KEY_NUMADD			Return "Num Add"
	Case KEY_NUMSUBTRACT	Return "Num Sub"
	Case KEY_NUMDECIMAL		Return "Num Dec"
	Case KEY_NUMDIVIDE		Return "Num Div"

	Case KEY_F1		Return "F1"
	Case KEY_F2		Return "F2"
	Case KEY_F3		Return "F3"
	Case KEY_F4		Return "F4"
	Case KEY_F5		Return "F5"
	Case KEY_F6		Return "F6"
	Case KEY_F7		Return "F7"
	Case KEY_F8		Return "F8"
	Case KEY_F9		Return "F9"
	Case KEY_F10	Return "F10"
	Case KEY_F11	Return "F11"
	Case KEY_F12	Return "F12"

	Case KEY_TILDE	Return "~~"
	Case KEY_MINUS	Return "-"
	Case KEY_EQUALS	Return "="

	Case KEY_OPENBRACKET	Return "("
	Case KEY_CLOSEBRACKET	Return ")"
	Case KEY_BACKSLASH		Return "Back Slash"

	Case KEY_SEMICOLON	Return "Semi"
	Case KEY_QUOTES		Return "~q"

	Case KEY_COMMA	Return "Comma"
	Case KEY_PERIOD	Return "Period"
	Case KEY_SLASH	Return "Slash"

	Case KEY_LSHIFT		Return "Left Shift"
	Case KEY_RSHIFT		Return "Right Shift"
	Case KEY_LCONTROL	Return "Left Ctrl"
	Case KEY_RCONTROL	Return "Right Ctrl"
	Case KEY_LALT		Return "Left Alt"
	Case KEY_RALT		Return "Right Alt"
	Case KEY_LSYS		Return "Left Sys"
	Case KEY_RSYS		Return "Right Sys"

	Case KEY_BROWSER_BACK		Return "Browser Back"
	Case KEY_BROWSER_FORWARD	Return "Browser Forward"
	Case KEY_BROWSER_REFRESH	Return "Browser Refresh"
	Case KEY_BROWSER_STOP		Return "Browser Stop"
	Case KEY_BROWSER_SEARCH		Return "Browser Search"
	Case KEY_BROWSER_FAVORITES	Return "Browser Favorites"
	Case KEY_BROWSER_HOME		Return "Browser Home"
	End Select
End Function

Function KeyForName:Int( name:String )
	Select name
	Case "Backspace" 	Return KEY_BACKSPACE
	Case "Tab" 			Return KEY_TAB
	Case "Clear" 		Return KEY_CLEAR
	Case "Return" 		Return KEY_RETURN
	Case "Enter" 		Return KEY_ENTER
	Case "Esc" 			Return KEY_ESCAPE
	Case "Space" 		Return KEY_SPACE
	Case "Page Up" 		Return KEY_PAGEUP
	Case "Page Down" 	Return KEY_PAGEDOWN
	Case "End" 			Return KEY_END
	Case "Home" 		Return KEY_HOME

	Case "Left" 	Return KEY_LEFT
	Case "Up" 		Return KEY_UP
	Case "Right" 	Return KEY_RIGHT
	Case "Down" 	Return KEY_DOWN

	Case "Select" 	Return KEY_SELECT
	Case "Print" 	Return KEY_PRINT
	Case "Execute" 	Return KEY_EXECUTE
	Case "Screen" 	Return KEY_SCREEN
	Case "Insert" 	Return KEY_INSERT
	Case "Delete" 	Return KEY_DELETE

	Case "0" Return KEY_0
	Case "1" Return KEY_1
	Case "2" Return KEY_2
	Case "3" Return KEY_3
	Case "4" Return KEY_4
	Case "5" Return KEY_5
	Case "6" Return KEY_6
	Case "7" Return KEY_7
	Case "8" Return KEY_8
	Case "9" Return KEY_9
	Case "A" Return KEY_A
	Case "B" Return KEY_B
	Case "C" Return KEY_C
	Case "D" Return KEY_D
	Case "E" Return KEY_E
	Case "F" Return KEY_F
	Case "G" Return KEY_G
	Case "H" Return KEY_H
	Case "I" Return KEY_I
	Case "J" Return KEY_J
	Case "K" Return KEY_K
	Case "L" Return KEY_L
	Case "M" Return KEY_M
	Case "N" Return KEY_N
	Case "O" Return KEY_O
	Case "P" Return KEY_P
	Case "Q" Return KEY_Q
	Case "R" Return KEY_R
	Case "S" Return KEY_S
	Case "T" Return KEY_T
	Case "U" Return KEY_U
	Case "V" Return KEY_V
	Case "W" Return KEY_W
	Case "X" Return KEY_X
	Case "Y" Return KEY_Y
	Case "Z" Return KEY_Z

	Case "Num 0" Return KEY_NUM0
	Case "Num 1" Return KEY_NUM1
	Case "Num 2" Return KEY_NUM2
	Case "Num 3" Return KEY_NUM3
	Case "Num 4" Return KEY_NUM4
	Case "Num 5" Return KEY_NUM5
	Case "Num 6" Return KEY_NUM6
	Case "Num 7" Return KEY_NUM7
	Case "Num 8" Return KEY_NUM8
	Case "Num 9" Return KEY_NUM9

	Case "Num Mul" Return KEY_NUMMULTIPLY
	Case "Num Add" Return KEY_NUMADD
	Case "Num Sub" Return KEY_NUMSUBTRACT
	Case "Num Dec" Return KEY_NUMDECIMAL
	Case "Num Div" Return KEY_NUMDIVIDE

	Case "F1" 	Return KEY_F1
	Case "F2" 	Return KEY_F2
	Case "F3" 	Return KEY_F3
	Case "F4" 	Return KEY_F4
	Case "F5" 	Return KEY_F5
	Case "F6" 	Return KEY_F6
	Case "F7" 	Return KEY_F7
	Case "F8" 	Return KEY_F8
	Case "F9" 	Return KEY_F9
	Case "F10" 	Return KEY_F10
	Case "F11" 	Return KEY_F11
	Case "F12" 	Return KEY_F12

	Case "~~" Return KEY_TILDE
	Case "-"  Return KEY_MINUS
	Case "="  Return KEY_EQUALS

	Case "(" 			Return KEY_OPENBRACKET
	Case ")" 			Return KEY_CLOSEBRACKET
	Case "Back Slash" 	Return KEY_BACKSLASH

	Case "Semi" Return KEY_SEMICOLON
	Case "~q" 	Return KEY_QUOTES

	Case "Comma" 	Return KEY_COMMA
	Case "Period" 	Return KEY_PERIOD
	Case "Slash" 	Return KEY_SLASH

	Case "Left Shift" 	Return KEY_LSHIFT
	Case "Right Shift" 	Return KEY_RSHIFT
	Case "Left Ctrl" 	Return KEY_LCONTROL
	Case "Right Ctrl" 	Return KEY_RCONTROL
	Case "Left Alt" 	Return KEY_LALT
	Case "Right Alt" 	Return KEY_RALT
	Case "Left Sys" 	Return KEY_LSYS
	Case "Right Sys" 	Return KEY_RSYS

	Case "Browser Back" 		Return KEY_BROWSER_BACK
	Case "Browser Forward" 		Return KEY_BROWSER_FORWARD
	Case "Browser Refresh" 		Return KEY_BROWSER_REFRESH
	Case "Browser Stop" 		Return KEY_BROWSER_STOP
	Case "Browser Search" 		Return KEY_BROWSER_SEARCH
	Case "Browser Favorites" 	Return KEY_BROWSER_FAVORITES
	Case "Browser Home" 		Return KEY_BROWSER_HOME
	End Select
End Function
