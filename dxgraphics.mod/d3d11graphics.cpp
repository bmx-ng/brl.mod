#include <windows.h>
#include <d3d11.h>
#include <dxgi1_2.h>
#include <cstdio>
#include <vector>
#include <algorithm>
// Pub.Direct3D11's optional runtime entry point, not a static d3d11.dll import.
extern "C" HRESULT bmx_d3d11_CreateDevice(IDXGIAdapter *,int,HMODULE,UINT,const D3D_FEATURE_LEVEL *,UINT,UINT,ID3D11Device **,D3D_FEATURE_LEVEL *,ID3D11DeviceContext **);
extern "C" HRESULT bmx_dxgi_CreateDXGIFactory1(const GUID *,void **);
struct DX11Display {IDXGIAdapter *adapter;IDXGIOutput *output;DXGI_OUTPUT_DESC desc;std::vector<DXGI_MODE_DESC> modes;};
struct DX11Displays {IDXGIFactory2 *factory=nullptr;std::vector<DX11Display> items;~DX11Displays(){for(auto &d:items){d.output->Release();d.adapter->Release();}if(factory)factory->Release();}};
static DX11Displays *dx11Displays(){
 auto list=new DX11Displays();
 if(FAILED(bmx_dxgi_CreateDXGIFactory1(&__uuidof(IDXGIFactory2),(void **)&list->factory))){delete list;return nullptr;}
 for(UINT a=0;;++a){
  IDXGIAdapter *adapter=nullptr;if(list->factory->EnumAdapters(a,&adapter)!=S_OK)break;
  for(UINT o=0;;++o){
   IDXGIOutput *output=nullptr;if(adapter->EnumOutputs(o,&output)!=S_OK)break;
   DX11Display d={};d.adapter=adapter;d.output=output;
   if(SUCCEEDED(output->GetDesc(&d.desc))&&d.desc.AttachedToDesktop){
    for(int retry=0;retry<3;++retry){
     UINT count=0;HRESULT hr=output->GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM,0,&count,nullptr);
     if(FAILED(hr))break;
     d.modes.resize(count);hr=output->GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM,0,&count,d.modes.data());
     if(SUCCEEDED(hr)){d.modes.resize(count);break;}
     d.modes.clear();if(hr!=DXGI_ERROR_MORE_DATA)break;
    }
    adapter->AddRef();list->items.push_back(d);
   }else output->Release();
  }
  adapter->Release();
 }
 HMONITOR primary=MonitorFromPoint(POINT{0,0},MONITOR_DEFAULTTOPRIMARY);
 for(size_t i=0;i<list->items.size();++i)if(list->items[i].desc.Monitor==primary){std::swap(list->items[0],list->items[i]);break;}
 return list;
}
static int dx11Hz(const DXGI_MODE_DESC &m){return m.RefreshRate.Denominator?int((m.RefreshRate.Numerator+m.RefreshRate.Denominator/2)/m.RefreshRate.Denominator):0;}

struct DX11Window {
 HWND window;
 ID3D11Device *device;
 ID3D11DeviceContext *context;
 IDXGISwapChain1 *chain;
 ID3D11RenderTargetView *target;
 int width,height;
 IDXGIOutput *output;DXGI_MODE_DESC mode;bool fullscreen,borderless,actualFullscreen,resizePending,autoDisplay;
 LONG_PTR windowStyle;RECT windowRect;UINT windowDpi;
};
static UINT dx11Dpi(HWND window){
 auto dpi=(UINT(WINAPI *)(HWND))GetProcAddress(GetModuleHandleW(L"user32.dll"),"GetDpiForWindow");
 UINT value=dpi?dpi(window):96;return value?value:96;
}
static void dx11Physical(HWND window,RECT &r,bool toPhysical){
 auto convert=(BOOL(WINAPI *)(HWND,POINT *))GetProcAddress(GetModuleHandleW(L"user32.dll"),toPhysical?"LogicalToPhysicalPointForPerMonitorDPI":"PhysicalToLogicalPointForPerMonitorDPI");
 if(convert){convert(window,(POINT *)&r);convert(window,((POINT *)&r)+1);}
}
static void dx11SaveWindow(DX11Window *g){
 g->windowStyle=GetWindowLongPtrW(g->window,GWL_STYLE);
 GetClientRect(g->window,&g->windowRect);MapWindowPoints(g->window,nullptr,(POINT *)&g->windowRect,2);
 dx11Physical(g->window,g->windowRect,true);
}
static int dx11Logical(DX11Window *g,int pixels){return g->fullscreen?pixels:MulDiv(pixels,g->windowDpi,dx11Dpi(g->window));}
static char dx11Error[192];
static int dx11Check(HRESULT hr,const char *op){
 if(SUCCEEDED(hr))return 1;
 snprintf(dx11Error,sizeof(dx11Error),"%s failed (HRESULT 0x%08lx)",op,(unsigned long)hr);return 0;
}
static HRESULT dx11Target(DX11Window *g){
 ID3D11Texture2D *back=nullptr;
 HRESULT hr=g->chain->GetBuffer(0,__uuidof(ID3D11Texture2D),(void **)&back);
 if(SUCCEEDED(hr)){hr=g->device->CreateRenderTargetView(back,nullptr,&g->target);back->Release();}
 return hr;
}
static HRESULT dx11Mode(DX11Window *g,int width,int height,int hertz,DXGI_MODE_DESC &mode){
 UINT count=0;HRESULT hr=g->output->GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM,0,&count,nullptr);
 if(FAILED(hr))return hr;
 std::vector<DXGI_MODE_DESC> modes(count);
 hr=g->output->GetDisplayModeList(DXGI_FORMAT_R8G8B8A8_UNORM,0,&count,modes.data());if(FAILED(hr))return hr;
 bool found=false;
 for(UINT i=0;i<count;++i){auto &m=modes[i];
  if(m.Width!=(UINT)width||m.Height!=(UINT)height||(hertz&&dx11Hz(m)!=hertz))continue;
  if(!found||double(m.RefreshRate.Numerator)/m.RefreshRate.Denominator>double(mode.RefreshRate.Numerator)/mode.RefreshRate.Denominator){mode=m;found=true;}
 }
 return found?S_OK:DXGI_ERROR_NOT_FOUND;
}
static void dx11RestoreWindow(DX11Window *g){
 SetWindowLongPtrW(g->window,GWL_STYLE,g->windowStyle);
 RECT saved=g->windowRect;dx11Physical(g->window,saved,false);RECT r={0,0,saved.right-saved.left,saved.bottom-saved.top};
 AdjustWindowRectEx(&r,(DWORD)g->windowStyle,FALSE,(DWORD)GetWindowLongPtrW(g->window,GWL_EXSTYLE));
 SetWindowPos(g->window,nullptr,saved.left+r.left,saved.top+r.top,r.right-r.left,r.bottom-r.top,SWP_NOZORDER|SWP_NOACTIVATE|SWP_FRAMECHANGED);
}
extern "C" {
void *bmx_d3d11_displays(){return dx11Displays();}
void bmx_d3d11_displays_close(DX11Displays *d){delete d;}
int bmx_d3d11_display_count(DX11Displays *d){return d?(int)d->items.size():0;}
const WCHAR *bmx_d3d11_display_info(DX11Displays *d,int i,int *x,int *y,int *w,int *h){
 auto &o=d->items[i].desc;auto &r=o.DesktopCoordinates;*x=r.left;*y=r.top;*w=r.right-r.left;*h=r.bottom-r.top;return o.DeviceName;
}
int bmx_d3d11_mode_count(DX11Displays *d,int i){return (int)d->items[i].modes.size();}
void bmx_d3d11_mode_info(DX11Displays *d,int i,int m,int *w,int *h,int *hz){auto &mode=d->items[i].modes[m];*w=mode.Width;*h=mode.Height;*hz=dx11Hz(mode);}
int bmx_d3d11_ready(DX11Window *g);
int bmx_d3d11_fullscreen(DX11Window *g,int enabled,int w,int h,int hz){
 if(!g)return dx11Check(E_POINTER,"Fullscreen device");
 if(enabled){
  if(g->autoDisplay&&!g->fullscreen){
   IDXGIOutput *output=nullptr;
   if(!dx11Check(g->chain->GetContainingOutput(&output),"Fullscreen output"))return 0;
   g->output->Release();g->output=output;
  }
  DXGI_MODE_DESC mode={};HRESULT hr=dx11Mode(g,w,h,hz,mode);
  if(!dx11Check(hr,"Requested fullscreen display mode"))return 0;
  if(!g->fullscreen&&!g->borderless){dx11SaveWindow(g);}
  hr=g->chain->SetFullscreenState(TRUE,g->output);
  if(hr!=S_OK){snprintf(dx11Error,sizeof(dx11Error),"Enter exclusive fullscreen failed (HRESULT 0x%08lx, foreground=%d, visible=%d, minimized=%d, enabled=%d)",(unsigned long)(FAILED(hr)?hr:DXGI_ERROR_NOT_CURRENTLY_AVAILABLE),GetForegroundWindow()==g->window,IsWindowVisible(g->window)!=0,IsIconic(g->window)!=0,IsWindowEnabled(g->window)!=0);return 0;}
  hr=g->chain->ResizeTarget(&mode);
  if(FAILED(hr)){g->chain->SetFullscreenState(FALSE,nullptr);dx11RestoreWindow(g);g->fullscreen=false;g->borderless=false;g->resizePending=true;return dx11Check(hr,"Set fullscreen mode");}
  g->mode=mode;g->fullscreen=true;g->borderless=false;
 }else{
  HRESULT hr=g->chain->SetFullscreenState(FALSE,nullptr);
  if(!dx11Check(hr,"Leave exclusive fullscreen"))return 0;
  if(g->fullscreen||g->borderless)dx11RestoreWindow(g);
  g->fullscreen=false;g->borderless=false;
 }
 g->resizePending=true;
 return bmx_d3d11_ready(g)>=0;
}
// Borderless uses desktop composition; it never requests a display mode.
int bmx_d3d11_borderless(DX11Window *g,int enabled){
 if(!g)return dx11Check(E_POINTER,"Borderless device");
 if(!enabled)return g->borderless?bmx_d3d11_fullscreen(g,0,0,0,0):1;
 if(g->borderless)return 1;
 if(g->autoDisplay&&!g->fullscreen){
  IDXGIOutput *output=nullptr;
  if(!dx11Check(g->chain->GetContainingOutput(&output),"Borderless output"))return 0;
  g->output->Release();g->output=output;
 }
 DXGI_OUTPUT_DESC desc={};
 if(!dx11Check(g->output->GetDesc(&desc),"Borderless display"))return 0;
 if(!g->fullscreen)dx11SaveWindow(g);
 if(!dx11Check(g->chain->SetFullscreenState(FALSE,nullptr),"Leave exclusive for borderless"))return 0;
 g->fullscreen=false;
 // Query after leaving exclusive, when the desktop mode has been restored.
 MONITORINFO monitor={};monitor.cbSize=sizeof(monitor);
 if(!GetMonitorInfoW(desc.Monitor,&monitor)){
  HRESULT error=HRESULT_FROM_WIN32(GetLastError());dx11RestoreWindow(g);g->resizePending=true;
  return dx11Check(error,"Borderless monitor bounds");
 }
 RECT r=monitor.rcMonitor;
 SetWindowLongPtrW(g->window,GWL_STYLE,(g->windowStyle&~(WS_OVERLAPPEDWINDOW))|WS_POPUP);
 if(!SetWindowPos(g->window,nullptr,r.left,r.top,r.right-r.left,r.bottom-r.top,SWP_NOZORDER|SWP_NOACTIVATE|SWP_FRAMECHANGED)){
  HRESULT error=HRESULT_FROM_WIN32(GetLastError());dx11RestoreWindow(g);g->resizePending=true;
  return dx11Check(error,"Borderless window bounds");
 }
 g->borderless=true;g->resizePending=true;
 return bmx_d3d11_ready(g)>=0;
}
int bmx_d3d11_recover_fullscreen(DX11Window *g,int w,int h,int hz){
 if(!dx11Check(dx11Mode(g,w,h,hz,g->mode),"Recover fullscreen mode"))return 0;
 dx11SaveWindow(g);
 g->fullscreen=true;g->resizePending=true;
 // Reacquire exclusive ownership on the next Ready when foreground and available.
 return 1;
}
const char *bmx_d3d11_error(){return dx11Error;}
void bmx_d3d11_close(DX11Window *g){
 if(!g)return;
 if(g->chain)g->chain->SetFullscreenState(FALSE,nullptr);
 if(g->fullscreen||g->borderless)dx11RestoreWindow(g);
 if(g->output)g->output->Release();
 if(g->context)g->context->ClearState();
 if(g->target)g->target->Release();
 if(g->chain)g->chain->Release();
 // Flush after releasing the chain so deferred destruction finishes before
 // another flip-model swap chain is created for the same HWND.
 if(g->context){g->context->Flush();g->context->Release();}
 if(g->device)g->device->Release();
 delete g;
}
void *bmx_d3d11_open(HWND window,int width,int height,int display,int windowDpi){
 DX11Window *g=new DX11Window();g->window=window;g->windowDpi=windowDpi;g->width=width;g->height=height;g->autoDisplay=display<0;
 auto displays=dx11Displays();
 if(!displays||displays->items.empty()){delete displays;delete g;dx11Check(DXGI_ERROR_NOT_FOUND,"No attached DXGI displays");return nullptr;}
 if(display<0){
  HMONITOR monitor=MonitorFromWindow(window,MONITOR_DEFAULTTOPRIMARY);display=0;
  for(size_t i=0;i<displays->items.size();++i)if(displays->items[i].desc.Monitor==monitor){display=(int)i;break;}
 }
 if(display>=(int)displays->items.size()){delete displays;delete g;dx11Check(E_INVALIDARG,"Display index");return nullptr;}
 auto &selected=displays->items[display];g->output=selected.output;g->output->AddRef();
 D3D_FEATURE_LEVEL levels[]={D3D_FEATURE_LEVEL_11_0,D3D_FEATURE_LEVEL_10_1,D3D_FEATURE_LEVEL_10_0};
 HRESULT hr=bmx_d3d11_CreateDevice(selected.adapter,D3D_DRIVER_TYPE_UNKNOWN,nullptr,0,levels,3,D3D11_SDK_VERSION,&g->device,nullptr,&g->context);
 if(!dx11Check(hr,"Create display D3D11 device (feature level 10.0+)")){delete displays;bmx_d3d11_close(g);return nullptr;}
 auto factory=displays->factory;
 DXGI_SWAP_CHAIN_DESC1 d={};d.Width=width;d.Height=height;d.Format=DXGI_FORMAT_R8G8B8A8_UNORM;
 d.SampleDesc.Count=1;d.BufferUsage=DXGI_USAGE_RENDER_TARGET_OUTPUT;d.BufferCount=2;
 d.Flags=DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;
 d.SwapEffect=DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;d.AlphaMode=DXGI_ALPHA_MODE_IGNORE;
 if(SUCCEEDED(hr))hr=factory->CreateSwapChainForHwnd(g->device,window,&d,nullptr,nullptr,&g->chain);
 if(SUCCEEDED(hr))hr=factory->MakeWindowAssociation(window,DXGI_MWA_NO_ALT_ENTER);
 delete displays;
 if(SUCCEEDED(hr))hr=dx11Target(g);
 if(!dx11Check(hr,"Create windowed DXGI swap chain")){bmx_d3d11_close(g);return nullptr;}
 return g;
}
int bmx_d3d11_ready(DX11Window *g){
 if(!g)return 0;
 if(!dx11Check(g->device->GetDeviceRemovedReason(),"Device removed"))return -1;
 if(IsIconic(g->window))return 0;
 BOOL full=FALSE;HRESULT state=g->chain->GetFullscreenState(&full,nullptr);
 if(!dx11Check(state,"Get fullscreen state"))return -1;
 if(bool(full)!=g->actualFullscreen){g->actualFullscreen=full!=FALSE;g->resizePending=true;}
 if(g->fullscreen&&!full){
  if(GetForegroundWindow()!=g->window)return 0;
  state=g->chain->SetFullscreenState(TRUE,g->output);
  if(state==DXGI_ERROR_NOT_CURRENTLY_AVAILABLE||state==DXGI_STATUS_MODE_CHANGE_IN_PROGRESS||state==DXGI_ERROR_MODE_CHANGE_IN_PROGRESS)return 0;
  if(!dx11Check(state,"Restore fullscreen"))return -1;
  if(!dx11Check(g->chain->ResizeTarget(&g->mode),"Restore display mode"))return -1;
  g->actualFullscreen=true;g->resizePending=true;
 }
 RECT r;GetClientRect(g->window,&r);
 if(r.right<=0||r.bottom<=0)return 0;
 r.right=dx11Logical(g,r.right);r.bottom=dx11Logical(g,r.bottom);
 if(g->resizePending||r.right!=g->width||r.bottom!=g->height){
  g->context->OMSetRenderTargets(0,nullptr,nullptr);
  if(g->target){g->target->Release();g->target=nullptr;}
  HRESULT hr=g->chain->ResizeBuffers(0,r.right,r.bottom,DXGI_FORMAT_UNKNOWN,DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
  if(!dx11Check(hr,"ResizeBuffers"))return -1;
  g->width=r.right;g->height=r.bottom;g->resizePending=false;
 }
 if(!g->target&&!dx11Check(dx11Target(g),"Create resized backbuffer view"))return -1;
 return 1;
}
int bmx_d3d11_present(DX11Window *g,int sync){
 int ready=bmx_d3d11_ready(g);if(ready<=0)return ready;
 HRESULT hr=g->chain->Present(sync?1:0,0);
 if(hr==DXGI_STATUS_OCCLUDED||hr==DXGI_STATUS_MODE_CHANGE_IN_PROGRESS||hr==DXGI_ERROR_MODE_CHANGE_IN_PROGRESS)return 0;
 return dx11Check(hr,"Present")?1:-1;
}
int bmx_d3d11_resize(DX11Window *g,int w,int h){
 if(g->borderless)return dx11Check(E_INVALIDARG,"Leave borderless before resizing the window");
 if(g->fullscreen)return bmx_d3d11_fullscreen(g,1,w,h,0);
 if(w<=0||h<=0)return dx11Check(E_INVALIDARG,"Resize dimensions");
 w=MulDiv(w,dx11Dpi(g->window),g->windowDpi);h=MulDiv(h,dx11Dpi(g->window),g->windowDpi);
 RECT r={0,0,w,h};AdjustWindowRectEx(&r,(DWORD)GetWindowLongPtrW(g->window,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtrW(g->window,GWL_EXSTYLE));
 if(!SetWindowPos(g->window,nullptr,0,0,r.right-r.left,r.bottom-r.top,SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE))return dx11Check(HRESULT_FROM_WIN32(GetLastError()),"Resize window");
 return bmx_d3d11_ready(g)>=0;
}
int bmx_d3d11_position(DX11Window *g,int x,int y){
 if(g->fullscreen||g->borderless)return dx11Check(E_INVALIDARG,"Cannot position fullscreen window");
 RECT r={0,0,0,0};AdjustWindowRectEx(&r,(DWORD)GetWindowLongPtrW(g->window,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtrW(g->window,GWL_EXSTYLE));
 return SetWindowPos(g->window,nullptr,x+r.left,y+r.top,0,0,SWP_NOSIZE|SWP_NOZORDER|SWP_NOACTIVATE)?1:dx11Check(HRESULT_FROM_WIN32(GetLastError()),"Position window");
}
int bmx_d3d11_size_initial_window(HWND window,int width,int height,int centerX,int centerY){
 UINT dpi=dx11Dpi(window);
 RECT old;GetWindowRect(window,&old);
 POINT origin={0,0};ClientToScreen(window,&origin);
 RECT r={0,0,MulDiv(width,dpi,96),MulDiv(height,dpi,96)};
 AdjustWindowRectEx(&r,(DWORD)GetWindowLongPtrW(window,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtrW(window,GWL_EXSTYLE));
 int w=r.right-r.left,h=r.bottom-r.top;
 int x=centerX?(old.left+old.right-w)/2:origin.x+r.left;
 int y=centerY?(old.top+old.bottom-h)/2:origin.y+r.top;
 return SetWindowPos(window,nullptr,x,y,w,h,SWP_NOZORDER|SWP_NOACTIVATE)?1:dx11Check(HRESULT_FROM_WIN32(GetLastError()),"Initial logical window size");
}
int bmx_d3d11_window_dpi(HWND window){return dx11Dpi(window);}
int bmx_d3d11_is_borderless(DX11Window *g){return g&&g->borderless;}
int bmx_d3d11_is_fullscreen(DX11Window *g){return g&&g->fullscreen;}
int bmx_d3d11_hertz(DX11Window *g){return g&&g->fullscreen?dx11Hz(g->mode):0;}
HRESULT bmx_d3d11_status(DX11Window *g){return g?g->device->GetDeviceRemovedReason():DXGI_ERROR_DEVICE_REMOVED;}
ID3D11Device *bmx_d3d11_device(DX11Window *g){return g->device;}
ID3D11DeviceContext *bmx_d3d11_context(DX11Window *g){return g->context;}
ID3D11RenderTargetView *bmx_d3d11_target(DX11Window *g){return g->target;}
}
