
#ifndef BLITZ_HANDLE_H
#define BLITZ_HANDLE_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

size_t		bbHandleFromObject( BBObject *o );
BBObject*   bbHandleToObject( size_t handle );
void		bbHandleRelease( size_t handle );

#ifdef __cplusplus
}
#endif

#endif


