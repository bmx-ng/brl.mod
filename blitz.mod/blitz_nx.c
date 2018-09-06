#include <stdio.h>

extern void * __tls_end;

int switch_log_write(const char* text, int length) {
	return 0;
}

void *switch_get_stack_bottom(void) {
	return __tls_end;
}
