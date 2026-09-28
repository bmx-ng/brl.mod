#include <windows.h>
#include <initguid.h>
#include <ddraw.h>
#include <d3d.h>
#include <cstdio>

struct DX7Window {
 HMODULE library;
 HWND hwnd;
 IDirectDraw7 *dd;
 IDirect3D7 *api;
 IDirect3DDevice7 *device;
 IDirectDrawSurface7 *primary,*back;
 IDirectDrawClipper *clipper;
 int width,height,generation;
};
static char dx7Error[192];
static int dx7Fail(HRESULT hr,const char *operation){
 snprintf(dx7Error,sizeof(dx7Error),"%s failed (HRESULT 0x%08lx)",operation,(unsigned long)hr);return -1;
}
extern "C" {
const char *bmx_d3d7_error(){return dx7Error;}
void bmx_d3d7_close(DX7Window *g){
 if(!g)return;
 if(g->device){g->device->SetTexture(0,NULL);g->device->Release();}
 if(g->back)g->back->Release();
 if(g->primary)g->primary->Release();
 if(g->clipper)g->clipper->Release();
 if(g->api)g->api->Release();
 if(g->dd)g->dd->Release();
 if(g->library)FreeLibrary(g->library);
 delete g;
}
void *bmx_d3d7_open(HWND hwnd,int width,int height){
 DX7Window *g=new DX7Window();g->hwnd=hwnd;g->width=width;g->height=height;g->generation=1;
 g->library=LoadLibraryW(L"ddraw.dll");
 typedef HRESULT (WINAPI *CreateDD)(GUID *,void **,REFIID,IUnknown *);
 CreateDD create=g->library?(CreateDD)GetProcAddress(g->library,"DirectDrawCreateEx"):NULL;
 if(!create){dx7Fail(E_NOINTERFACE,"Load DirectDraw7");bmx_d3d7_close(g);return NULL;}
 const char *stage="DirectDrawCreateEx";
 HRESULT hr=create(NULL,(void **)&g->dd,IID_IDirectDraw7,NULL);
 if(SUCCEEDED(hr)){stage="SetCooperativeLevel";hr=g->dd->SetCooperativeLevel(hwnd,DDSCL_NORMAL|DDSCL_FPUPRESERVE);}
 if(SUCCEEDED(hr)){stage="QueryInterface IDirect3D7";hr=g->dd->QueryInterface(IID_IDirect3D7,(void **)&g->api);}
 DDSURFACEDESC2 desc={};desc.dwSize=sizeof(desc);desc.dwFlags=DDSD_CAPS;desc.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE;
 if(SUCCEEDED(hr)){stage="Create primary surface";hr=g->dd->CreateSurface(&desc,&g->primary,NULL);}
 desc.dwFlags=DDSD_CAPS|DDSD_WIDTH|DDSD_HEIGHT;desc.dwWidth=width;desc.dwHeight=height;
 desc.ddsCaps.dwCaps=DDSCAPS_OFFSCREENPLAIN|DDSCAPS_3DDEVICE;
 if(SUCCEEDED(hr)){stage="Create backbuffer";hr=g->dd->CreateSurface(&desc,&g->back,NULL);}
 if(SUCCEEDED(hr)){stage="CreateClipper";hr=g->dd->CreateClipper(0,&g->clipper,NULL);}
 if(SUCCEEDED(hr)){stage="Clipper window";hr=g->clipper->SetHWnd(0,hwnd);}
 if(SUCCEEDED(hr)){stage="SetClipper";hr=g->primary->SetClipper(g->clipper);}
 if(SUCCEEDED(hr)){
  stage="CreateDevice HAL";
  hr=g->api->CreateDevice(IID_IDirect3DTnLHalDevice,g->back,&g->device);
  if(FAILED(hr))hr=g->api->CreateDevice(IID_IDirect3DHALDevice,g->back,&g->device);
 }
 if(FAILED(hr)){dx7Fail(hr,stage);bmx_d3d7_close(g);return NULL;}
 return g;
}
int bmx_d3d7_ready(DX7Window *g){
 if(!g||IsIconic(g->hwnd))return 0;
 HRESULT hr=g->dd->TestCooperativeLevel();
 if(hr==DDERR_NOEXCLUSIVEMODE||hr==DDERR_EXCLUSIVEMODEALREADYSET)return 0;
 if(FAILED(hr))return dx7Fail(hr,"TestCooperativeLevel");
 if(g->primary->IsLost()==DDERR_SURFACELOST||g->back->IsLost()==DDERR_SURFACELOST){
  hr=g->dd->RestoreAllSurfaces();
  if(hr==DDERR_SURFACELOST||hr==DDERR_NOEXCLUSIVEMODE)return 0;
  if(FAILED(hr))return dx7Fail(hr,"RestoreAllSurfaces");
  ++g->generation;
 }
 return 1;
}
int bmx_d3d7_present(DX7Window *g,int sync){
 int ready=bmx_d3d7_ready(g);if(ready<=0)return ready;
 // Finish queued rendering before waiting for vblank, as in BRL's original driver.
 DDSURFACEDESC2 desc={};desc.dwSize=sizeof(desc);
 HRESULT hr=g->back->Lock(NULL,&desc,DDLOCK_WAIT|DDLOCK_READONLY,NULL);
 if(SUCCEEDED(hr))hr=g->back->Unlock(NULL);
 if(hr==DDERR_SURFACELOST)return 0;
 if(FAILED(hr))return dx7Fail(hr,"Finish rendering");
 if(sync){hr=g->dd->WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN,NULL);if(FAILED(hr))return dx7Fail(hr,"WaitForVerticalBlank");}
 POINT p={0,0};ClientToScreen(g->hwnd,&p);
 RECT src={0,0,g->width,g->height},dst={p.x,p.y,p.x+g->width,p.y+g->height};
 hr=g->primary->Blt(&dst,g->back,&src,DDBLT_WAIT,NULL);
 if(hr==DDERR_SURFACELOST)return 0;
 return FAILED(hr)?dx7Fail(hr,"Present"):1;
}
int bmx_d3d7_generation(DX7Window *g){return g?g->generation:0;}
void *bmx_d3d7_dd(DX7Window *g){return g?g->dd:NULL;}
void *bmx_d3d7_device(DX7Window *g){return g?g->device:NULL;}
void *bmx_d3d7_surface(DX7Window *g){return g?g->back:NULL;}
}
