
#include "blitz.h"

#define REG_GROW 256

static BBClass **reg_base,**reg_put,**reg_end;
static BBClass **ireg_base,**ireg_put,**ireg_end;

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"Object",
	BBDEBUGDECL_END
};

BBClass bbObjectClass={
	0,				//super
	bbObjectFree,   //free
	&debugScope,	//debug_scope
	8,				//instance_size
	
	bbObjectCtor,
	bbObjectDtor,
	bbObjectToString,
	bbObjectCompare,
	bbObjectSendMessage,
	0,             //interface
	0,             //extra
	0,             //reserved
};

BBObject bbNullObject={
	0			//clas
	//BBGC_MANYREFS	//refs
};

BBObject *bbObjectNew( BBClass *clas ){
	int flags=( clas->dtor!=bbObjectDtor ) ? BBGC_FINALIZE : 0;
	BBObject *o=(BBObject*)bbGCAllocObject( clas->instance_size,clas,flags );
	clas->ctor( o );
	return o;
}

BBObject *bbObjectAtomicNew( BBClass *clas ){
	int flags=( clas->dtor!=bbObjectDtor ) ? BBGC_FINALIZE | BBGC_ATOMIC : BBGC_ATOMIC;
	BBObject *o=(BBObject*)bbGCAllocObject( clas->instance_size,clas,flags );
	clas->ctor( o );
	return o;
}

void bbObjectFree( BBObject *o ){
	BBClass *clas=o->clas;

#ifdef BB_GC_RC

	if( o==&bbNullObject ){
		//o->refs=BBGC_MANYREFS;
		return;
	}

	clas->dtor( o );
	bbGCDeallocObject( o,clas->instance_size );

#else

	clas->dtor( o );

#endif
}

void bbObjectCtor( BBObject *o ){
	o->clas=&bbObjectClass;
}

void bbObjectDtor( BBObject *o ){
	o->clas=0;
}

BBString *bbObjectToString( BBObject *o ){
	char buf[32];
	sprintf( buf,"%p",o );
	return bbStringFromCString( buf );
}

int bbObjectCompare( BBObject *x,BBObject *y ){
	return (char*)x-(char*)y;
}

BBObject *bbObjectSendMessage( BBObject * o, BBObject *m,BBObject *s ){
	return &bbNullObject;
}

void bbObjectReserved(){
	bbExThrowCString( "Illegal call to reserved method" );
}

BBObject *bbObjectDowncast( BBObject *o,BBClass *t ){
	BBClass *p=o->clas;
	while( p && p!=t ) p=p->super;
	return p ? o : (t==&bbStringClass) ? &bbEmptyString : (t==&bbArrayClass) ? &bbEmptyArray : &bbNullObject;
}

void bbObjectRegisterType( BBClass *clas ){
	if( reg_put==reg_end ){
		int len=reg_put-reg_base,new_len=len+REG_GROW;
		reg_base=(BBClass**)bbMemExtend( reg_base,len*sizeof(BBClass*),new_len*sizeof(BBClass*) );
		reg_end=reg_base+new_len;
		reg_put=reg_base+len;
	}
	*reg_put++=clas;
}

BBClass **bbObjectRegisteredTypes( int *count ){
	*count=reg_put-reg_base;
	return reg_base;
}

void bbObjectRegisterInterface( BBInterface * ifc ){
	if( ireg_put==ireg_end ){
		int len=ireg_put-ireg_base,new_len=len+REG_GROW;
		ireg_base=(BBInterface**)bbMemExtend( ireg_base,len*sizeof(BBInterface*),new_len*sizeof(BBInterface*) );
		ireg_end=ireg_base+new_len;
		ireg_put=ireg_base+len;
	}
	*ireg_put++=ifc;
}

BBInterface **bbObjectRegisteredInterfaces( int *count ){
	*count=ireg_put-ireg_base;
	return ireg_base;
}

BBObject * bbInterfaceDowncast(BBOBJECT o, BBINTERFACE ifc) {
	int i;

	BBCLASS superclas = o->clas;

	do {
		BBCLASS clas = superclas;
		superclas = clas->super;

		BBINTERFACETABLE table = clas->itable;
		if (table) {
			BBINTERFACEOFFSETS offsets = table->ifc_offsets;
			for (i = table->ifc_size; i; i--) {
				if (offsets->ifc == ifc) {
					return o;
				}
				offsets++;
			}
		}
	} while (superclas);

	return &bbNullObject;
}

void * bbObjectInterface(BBOBJECT o, BBINTERFACE ifc) {
	int i;

	BBCLASS superclas = o->clas;

	do {
		BBCLASS clas = superclas;
		superclas = clas->super;

		BBINTERFACETABLE table = clas->itable;
		if (table) {
			BBINTERFACEOFFSETS offsets = table->ifc_offsets;
			for (i = table->ifc_size; i; i--) {
				if (offsets->ifc == ifc) {
					return (char*) table->ifc_vtable + offsets->offset;
				}
				offsets++;
			}
		}
	} while (superclas);

	return &bbNullObject;
}
