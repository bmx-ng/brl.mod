/* Shared validation for opt-in desktop OpenGL context requests. */
#ifndef BB_GL_CONTEXT_REQUEST_H
#define BB_GL_CONTEXT_REQUEST_H
#include <stdio.h>

static int bbGLContextMatches(int major,int minor,int profile){
	const char *version=(const char*)glGetString(GL_VERSION);
	int actualMajor=0,actualMinor=0;
	GLint mask=0;
	if(!version || sscanf(version,"%d.%d",&actualMajor,&actualMinor)!=2)return 0;
	if(actualMajor<major || (actualMajor==major && actualMinor<minor))return 0;
	if(profile){
		if(actualMajor<3 || (actualMajor==3 && actualMinor<2))return 0;
		glGetIntegerv(0x9126,&mask); /* GL_CONTEXT_PROFILE_MASK */
		if(!(mask & profile))return 0;
	}
	return 1;
}
#endif
