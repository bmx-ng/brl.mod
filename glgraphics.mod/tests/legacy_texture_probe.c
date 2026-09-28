#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <stdio.h>
int main(void){
 Display *d=XOpenDisplay(NULL);if(!d)return 2;
 int attrib[]={GLX_RGBA,GLX_DOUBLEBUFFER,None};XVisualInfo *v=glXChooseVisual(d,DefaultScreen(d),attrib);if(!v)return 3;
 XSetWindowAttributes a={0};a.event_mask=StructureNotifyMask;a.colormap=XCreateColormap(d,RootWindow(d,v->screen),v->visual,AllocNone);
 Window w=XCreateWindow(d,RootWindow(d,v->screen),20,20,128,128,0,v->depth,InputOutput,v->visual,CWColormap|CWEventMask,&a);
 XMapWindow(d,w);XEvent event;do{XNextEvent(d,&event);}while(event.type!=MapNotify);
 GLXContext c=glXCreateContext(d,v,NULL,True);glXMakeCurrent(d,w,c);
 glViewport(0,0,128,128);glMatrixMode(GL_PROJECTION);glLoadIdentity();glOrtho(0,128,128,0,-1,1);
 glMatrixMode(GL_MODELVIEW);glLoadIdentity();glClearColor(0,0,0,1);glClear(GL_COLOR_BUFFER_BIT);
 glXSwapBuffers(d,w);glClear(GL_COLOR_BUFFER_BIT);glXSwapBuffers(d,w);glClear(GL_COLOR_BUFFER_BIT);
 glColor4f(0,1,0,1);glBegin(GL_QUADS);glVertex2f(30,30);glVertex2f(38,30);glVertex2f(38,38);glVertex2f(30,38);glEnd();
 unsigned char primitive[4];glReadPixels(33,94,1,1,GL_RGBA,GL_UNSIGNED_BYTE,primitive);
 printf("primitive=%u,%u,%u\n",primitive[0],primitive[1],primitive[2]);
 GLuint t;glGenTextures(1,&t);glBindTexture(GL_TEXTURE_2D,t);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 unsigned char pixels[8*8*4];for(int i=0;i<64;i++){pixels[i*4]=255;pixels[i*4+1]=pixels[i*4+2]=0;pixels[i*4+3]=255;}
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,8,8,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
 glEnable(GL_TEXTURE_2D);glColor4f(1,1,1,1);
 glBegin(GL_QUADS);
 glTexCoord2f(0,0);glVertex2f(10,10);glTexCoord2f(1,0);glVertex2f(18,10);
 glTexCoord2f(1,1);glVertex2f(18,18);glTexCoord2f(0,1);glVertex2f(10,18);glEnd();
 unsigned char pixel[4]={0};glReadPixels(13,114,1,1,GL_RGBA,GL_UNSIGNED_BYTE,pixel);
 printf("%s: pixel=%u,%u,%u,%u error=%u\n",glGetString(GL_RENDERER),pixel[0],pixel[1],pixel[2],pixel[3],glGetError());
 glXMakeCurrent(d,None,NULL);glXDestroyContext(d,c);XDestroyWindow(d,w);XCloseDisplay(d);
 return pixel[0]==255 && pixel[1]==0 && pixel[2]==0 ? 0:1;
}
