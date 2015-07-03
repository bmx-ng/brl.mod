
#ifndef BLITZ_OBJECT_H
#define BLITZ_OBJECT_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULL (&bbNullObject)

#define BBNULLOBJECT (&bbNullObject)

struct BBClass{
	//extends BBGCPool
	BBClass*	super;
	void		(*free)( BBObject *o );
	
	BBDebugScope*debug_scope;

	int		instance_size;

	void		(*ctor)( BBObject *o );
	void		(*dtor)( BBObject *o );
	
	BBString*	(*ToString)( BBObject *x );
	int		(*Compare)( BBObject *x,BBObject *y );
	BBObject*	(*SendMessage)( BBObject *m,BBObject *s );

	BBINTERFACEOFFSETS ifc_offsets;
	void * ifc_vtable;
	int ifc_size;

	void*	vfns[32];
};

struct BBObject{
	//extends BBGCMem
	BBClass*	clas;
	//int		refs;
};

struct BBInterface {
	const char *name;
};

struct BBInterfaceOffsets {
    BBINTERFACE ifc;
    int offset;
};

extern	BBClass bbObjectClass;
extern	BBObject bbNullObject;

BBObject*	bbObjectNew( BBClass *t );
BBObject*	bbObjectAtomicNew( BBClass *t );
void		bbObjectFree( BBObject *o );

void		bbObjectCtor( BBObject *o );
void		bbObjectDtor( BBObject *o );

BBString*	bbObjectToString( BBObject *o );
int		bbObjectCompare( BBObject *x,BBObject *y );
BBObject*	bbObjectSendMessage( BBObject *m,BBObject *s );
void		bbObjectReserved();

BBObject*	bbObjectDowncast( BBObject *o,BBClass *t );

void		bbObjectRegisterType( BBClass *clas );
BBClass**	bbObjectRegisteredTypes( int *count );

BBObject * bbInterfaceDowncast(BBOBJECT o, BBINTERFACE ifc);
void * bbObjectInterface(BBOBJECT o, BBINTERFACE ifc);

#ifdef __cplusplus
}
#endif

#endif
