#include <unistd.h>
#include <sys/sysctl.h>

int bmx_os_getproccount() {
	int procCount = 0;

#ifdef __APPLE__
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

