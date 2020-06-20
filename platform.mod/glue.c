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
#include <unistd.h>
#include <sys/sysctl.h>

int bmx_os_getproccount() {
	int procCount = 0;

#ifdef __APPLE__
	uint32_t cpuCount;
	int name[2] = { CTL_HW, HW_NCPU };

	size_t size = sizeof(cpuCount);

	int res = sysctl(name, 2, &cpuCount, &size, NULL, 0);
#elif defined(_ARM_) || defined(_ARM64_)
	procCount = sysconf(_SC_NPROCESSORS_CONF);
#else
	procCount = sysconf(_SC_NPROCESSORS_ONLN);
#endif

	return procCount;
}

