#include <windows.h>
#include <stdlib.h>
typedef struct {
 HWND hwnd;
 int borderless;
 RECT savedWindowRect,savedClientRect;
 LONG_PTR savedStyle,savedExStyle;
} D9Window;
void *bmx_d9_window_create(HWND hwnd){
 D9Window *state=(D9Window*)calloc(1,sizeof(D9Window));
 if(state)state->hwnd=hwnd;
 return state;
}
void bmx_d9_window_free(void *state){free(state);}
static int setWindowStyle(HWND window,int index,LONG_PTR style){
	SetLastError(0);
	return SetWindowLongPtr(window,index,style)!=0 || GetLastError()==0;
}
static void d9_convert_rect(HWND hwnd,RECT *rect,int toPhysical){
 typedef BOOL (WINAPI *ConvertPoint)(HWND,POINT *);
 ConvertPoint convert=(ConvertPoint)GetProcAddress(GetModuleHandleW(L"user32.dll"),
  toPhysical?"LogicalToPhysicalPointForPerMonitorDPI":"PhysicalToLogicalPointForPerMonitorDPI");
 if(convert){convert(hwnd,(POINT*)rect);convert(hwnd,((POINT*)rect)+1);}
}
int d9_window_mode(D9Window *context,int enabled){
	RECT before,target,savedClient;
	LONG_PTR style,exStyle,newStyle,newExStyle;
	MONITORINFO monitor;
	if(!context)return 0;
	enabled=!!enabled;
	if(context->borderless==enabled)return 1;
	if(!GetWindowRect(context->hwnd,&before))return 0;
	style=GetWindowLongPtr(context->hwnd,GWL_STYLE);
	exStyle=GetWindowLongPtr(context->hwnd,GWL_EXSTYLE);
	if(enabled){
		if(!GetClientRect(context->hwnd,&savedClient))return 0;
		MapWindowPoints(context->hwnd,NULL,(POINT*)&savedClient,2);
		d9_convert_rect(context->hwnd,&savedClient,1);
		memset(&monitor,0,sizeof(monitor));monitor.cbSize=sizeof(monitor);
		if(!GetMonitorInfo(MonitorFromWindow(context->hwnd,MONITOR_DEFAULTTONEAREST),&monitor))return 0;
		target=monitor.rcMonitor;
		newStyle=(style & ~WS_OVERLAPPEDWINDOW)|WS_POPUP;
		newExStyle=exStyle & ~(WS_EX_WINDOWEDGE|WS_EX_CLIENTEDGE|WS_EX_STATICEDGE|WS_EX_DLGMODALFRAME);
	}else{
		RECT client=context->savedClientRect,frame;
		newStyle=context->savedStyle;newExStyle=context->savedExStyle;
		d9_convert_rect(context->hwnd,&client,0);
		frame.left=frame.top=0;frame.right=client.right-client.left;frame.bottom=client.bottom-client.top;
		if(!AdjustWindowRectEx(&frame,(DWORD)newStyle,FALSE,(DWORD)newExStyle))return 0;
		target.left=client.left+frame.left;target.top=client.top+frame.top;
		target.right=client.left+frame.right;target.bottom=client.top+frame.bottom;
	}
	if(!setWindowStyle(context->hwnd,GWL_STYLE,newStyle) ||
	   !setWindowStyle(context->hwnd,GWL_EXSTYLE,newExStyle) ||
	   !SetWindowPos(context->hwnd,NULL,target.left,target.top,target.right-target.left,target.bottom-target.top,
	                 SWP_FRAMECHANGED|SWP_NOZORDER|SWP_NOACTIVATE)){
		setWindowStyle(context->hwnd,GWL_STYLE,style);
		setWindowStyle(context->hwnd,GWL_EXSTYLE,exStyle);
		SetWindowPos(context->hwnd,NULL,before.left,before.top,before.right-before.left,before.bottom-before.top,
		             SWP_FRAMECHANGED|SWP_NOZORDER|SWP_NOACTIVATE);

		return 0;
	}
	if(enabled){
		context->savedWindowRect=before;context->savedClientRect=savedClient;
		context->savedStyle=style;context->savedExStyle=exStyle;
	}
	context->borderless=enabled;

	return 1;
}
int bmx_d9_window_mode(D9Window *state,int enabled){return d9_window_mode(state,enabled);}
void bmx_d9_window_geometry(HWND hwnd,int *w,int *h,int *x,int *y){
 RECT r={0};POINT p={0};GetClientRect(hwnd,&r);ClientToScreen(hwnd,&p);
 *w=r.right;*h=r.bottom;*x=p.x;*y=p.y;
}

static UINT d9_window_dpi(HWND hwnd){
 typedef UINT (WINAPI *WindowDpi)(HWND);
 WindowDpi getDpi=(WindowDpi)GetProcAddress(GetModuleHandleW(L"user32.dll"),"GetDpiForWindow");
 UINT dpi=getDpi?getDpi(hwnd):96;return dpi?dpi:96;
}
int bmx_d9_initial_pixels(int value){
 typedef UINT (WINAPI *SystemDpi)(void);
 SystemDpi getDpi=(SystemDpi)GetProcAddress(GetModuleHandleW(L"user32.dll"),"GetDpiForSystem");
 UINT dpi=getDpi?getDpi():96;return MulDiv(value,dpi?dpi:96,96);
}
int bmx_d9_window_logical(HWND hwnd,int value){return MulDiv(value,96,d9_window_dpi(hwnd));}
int bmx_d9_window_resize(HWND hwnd,int width,int height,int logicalSize){
 UINT dpi=logicalSize?d9_window_dpi(hwnd):96;
 RECT rect={0,0,MulDiv(width,dpi,96),MulDiv(height,dpi,96)};
 if(width<=0 || height<=0)return 0;
 if(!AdjustWindowRectEx(&rect,(DWORD)GetWindowLongPtr(hwnd,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtr(hwnd,GWL_EXSTYLE)))return 0;
 return SetWindowPos(hwnd,NULL,0,0,rect.right-rect.left,rect.bottom-rect.top,SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE)!=0;
}
int bmx_d9_window_position(HWND hwnd,int x,int y){
 RECT rect={0,0,0,0};
 if(!AdjustWindowRectEx(&rect,(DWORD)GetWindowLongPtr(hwnd,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtr(hwnd,GWL_EXSTYLE)))return 0;
 return SetWindowPos(hwnd,NULL,x+rect.left,y+rect.top,0,0,SWP_NOSIZE|SWP_NOZORDER|SWP_NOACTIVATE)!=0;
}

int bmx_d9_window_on_adapter(HWND hwnd,HMONITOR adapter){
 return MonitorFromWindow(hwnd,MONITOR_DEFAULTTONEAREST)==adapter;
}
