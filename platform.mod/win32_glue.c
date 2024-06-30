/*
 Copyright (c) 2019-2023 Bruce A Henderson

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
#define _WIN32_WINNT 0x0601
#include "windows.h"

void bmx_os_getwindowsversion(int * major, int * minor, int * build) {

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
		int _build = versionInfo.dwBuildNumber;

		switch (_major) {
			case 5:
				if (_minor == 1 || _minor == 2) {
					*major = _major;
					*minor = _minor;
					*build = _build;
					return;	
				}
				break;
				
			case 6:
				switch (_minor) {
					case 0:
						*major = _major;
						*minor = _minor;
						*build = 0;
						return;
					case 1:
						*major = 7;
						*minor = 0;
						*build = 0;
						return;
					case 2:
						*major = 8;
						*minor = 0;
						*build = 0;
						return;
					case 3:
						*major = 8;
						*minor = 1;
						*build = 0;
						return;
					case 4:
						*major = 10;
						*minor = 0;
						*build = 0;
						return;
				}
				break;
				
			case 10:
				if (_major == 10 && _minor == 0 && _build == 22000) {
					*major = 11;
					*minor = 0;
					*build = 0;
					return;
				}

				if (_major == 10 && _minor >= 1) {
					*major = 12;
					*minor = 0;
					*build = 0;
					return;
				}

				*major = _major;
				*minor = _minor;
				*build = _build;
				return;
		}
	}

	// don't know what version this is...
	*major = 0;
	*minor = 0;
	*build = 0;
}

typedef DWORD (WINAPI *ActiveProcessorCount)(WORD);
typedef BOOL (WINAPI *LogicalProcessorInformationEx)(LOGICAL_PROCESSOR_RELATIONSHIP, PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX, PDWORD);

static int kernelLoaded = 0;
static ActiveProcessorCount gapcFunc = 0;
static LogicalProcessorInformationEx glpieFunc = 0;

int bmx_os_getproccount() {

	SYSTEM_INFO info;
	GetSystemInfo(&info);
	return info.dwNumberOfProcessors;

}

static int bmx_os_calc_processor_count() {
	
	if (glpieFunc) {
	
		DWORD bufferLength = 0;
		
		BOOL result = glpieFunc(RelationAll, NULL, &bufferLength);
		
		if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
			return -1;
		}
		
		BYTE buffer[bufferLength];
		
		result = glpieFunc(RelationAll, buffer, &bufferLength);
		
		if (!result) {
			return -1;
		}
		
		DWORD offset = 0;
		int count = 0;
		
		while (offset < bufferLength) {
		
			PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX info = (PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX)(buffer + offset);
			
			if (info->Relationship == RelationProcessorCore) {
				count++;
			}
			
			offset += info->Size;
		}

		return count;
	}

	return -1;
}

int bmx_os_getphysproccount() {
	int count = 0;

	if (!kernelLoaded) {
		HINSTANCE kernel32 = LoadLibraryA("Kernel32.dll");
		if (kernel32) {
			glpieFunc = (LogicalProcessorInformationEx)GetProcAddress(kernel32, "GetLogicalProcessorInformationEx");
			
			if (!glpieFunc) {
				gapcFunc = (ActiveProcessorCount)GetProcAddress(kernel32, "GetActiveProcessorCount");
			}
		}

		kernelLoaded = 1;
	}

	count = bmx_os_calc_processor_count();
	
	if (count >= 0) {
	
		return count;
	
	} else if (gapcFunc) { // fallback
	
		count = gapcFunc(ALL_PROCESSOR_GROUPS);
		
	} else { // fallback

		count = bmx_os_getproccount();

	}

	return count;
}
