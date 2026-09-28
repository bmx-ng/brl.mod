#include <windows.h>
void brl_test_dpi_aware(void){SetProcessDPIAware();}
int brl_test_client_width(HWND window){RECT rect;return GetClientRect(window,&rect)?rect.right-rect.left:0;}
