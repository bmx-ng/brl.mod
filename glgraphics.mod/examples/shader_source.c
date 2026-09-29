#include "pub.mod/glew.mod/GL/glew.h"

/* Preserve the nested const-qualified string type required by glShaderSource. */
void bmx_glExampleShaderSource(int shader,const char *source){
	glShaderSource((GLuint)shader,1,&source,NULL);
}
