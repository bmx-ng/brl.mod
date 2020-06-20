/*
 Copyright (c) 2019-2020 Bruce A Henderson

 This software is provided 'as-is', without any express or implied
 warranty. In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
 
    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
 
    3. This notice may not be removed or altered from any source
    distribution.
*/
#include "windows.h"

bmx_os_getwindowsversion(int * major, int * minor) {

	OSVERSIONINFOEX versionInfo = {0};
	versionInfo.dwOSVersionInfoSize = sizeof(versionInfo);

	HINSTANCE nt = LoadLibrary("ntdll.dll");

	if (nt != NULL) {

		NTSTATUS (WINAPI *rtlGetVersion)(PRTL_OSVERSIONINFOW lpVersionInformation) = (NTSTATUS (WINAPI *)(PRTL_OSVERSIONINFOW)) GetProcAddress (nt, "RtlGetVersion");
		
		if (rtlGetVersion != NULL) {
			rtlGetVersion(&versionInfo);
		} else {
			GetVersionEx(&versionInfo);
		}

		int _major = versionInfo.dwMajorVersion;
		int _minor = versionInfo.dwMinorVersion;

		switch (_major) {
			case 5:
				if (_minor == 1 || _minor == 2) {
					*major = _major;
					*minor = _minor;
					return;	
				}
				break;
				
			case 6:
				switch (_minor) {
					case 0:
						*major = _major;
						*minor = _minor;
						return;
					case 1:
						*major = 7;
						*minor = 0;
						return;
					case 2:
						*major = 8;
						*minor = 0;
						return;
					case 3:
						*major = 8;
						*minor = 1;
						return;
				}
				break;
				
			case 10:
				*major = _major;
				*minor = 0;
				return;
		}
	}

	// don't know what version this is...
	*major = 0;
	*minor = 0;
}

int bmx_os_getproccount() {
	SYSTEM_INFO info;
	GetSystemInfo(&info);
	return info.dwNumberOfProcessors;
}

