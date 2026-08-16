#include "../blitz.h"

int bmx_test_object_compare_wide_identity(void) {
#if UINTPTR_MAX > 0xffffffffU
	BBObject *low = (BBObject *)(uintptr_t)0x0000000000001000ULL;
	BBObject *high = (BBObject *)(uintptr_t)0x0000000100001000ULL;
	return bbObjectCompare(low, high) < 0 && bbObjectCompare(high, low) > 0;
#else
	return 1;
#endif
}
