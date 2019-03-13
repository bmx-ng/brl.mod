
#include "blitz.h"

#define REG_GROW 256

static BBClass **reg_base=NULL,**reg_put=NULL,**reg_end=NULL;
static BBInterface **ireg_base=NULL,**ireg_put=NULL,**ireg_end=NULL;
static BBDebugScope **sreg_base=NULL,**sreg_put=NULL,**sreg_end=NULL;

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"Object",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.var_address=(void*)0,
			(void (*)(void**))0
		}
	}
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
	0              //obj_size
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

BBObject *bbObjectNewNC( BBClass *clas ){
	int flags=( clas->dtor!=bbObjectDtor ) ? BBGC_FINALIZE : 0;
	BBObject *o=(BBObject*)bbGCAllocObject( clas->instance_size,clas,flags );
	return o;
}

BBObject *bbObjectAtomicNewNC( BBClass *clas ){
	int flags=( clas->dtor!=bbObjectDtor ) ? BBGC_FINALIZE | BBGC_ATOMIC : BBGC_ATOMIC;
	BBObject *o=(BBObject*)bbGCAllocObject( clas->instance_size,clas,flags );
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

	while (superclas) {
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
	}

	return &bbNullObject;
}

void * bbObjectInterface(BBOBJECT o, BBINTERFACE ifc) {
	int i;

	BBCLASS superclas = o->clas;

	while (superclas) {
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
	}

	return &bbNullObject;
}

static struct avl_root *struct_root = 0;

int struct_node_compare(const void *x, const void *y) {

        struct struct_node * node_x = (struct struct_node *)x;
        struct struct_node * node_y = (struct struct_node *)y;

        return strcmp(node_x->scope->name, node_y->scope->name);
}

void bbObjectRegisterStruct( BBDebugScope *p ) {
	struct struct_node * node = (struct struct_node *)malloc(sizeof(struct struct_node));
	node->scope = p;
	
	struct struct_node * old_node = (struct struct_node *)avl_map(&node->link, struct_node_compare, &struct_root);
	if (&node->link != &old_node->link) {
		// this object already exists here...
		// delete the new node, since we don't need it
		// note : should never happen as structs should only ever be registered once.
		free(node);
	}
	
	if( sreg_put==sreg_end ){
		int len=sreg_put-sreg_base,new_len=len+REG_GROW;
		sreg_base=(BBDebugScope**)bbMemExtend( sreg_base,len*sizeof(BBDebugScope*),new_len*sizeof(BBDebugScope*) );
		sreg_end=sreg_base+new_len;
		sreg_put=sreg_base+len;
	}
	*sreg_put++=p;
}

BBDebugScope **bbObjectRegisteredStructs( int *count ) {
	*count = sreg_put-sreg_base;
	return sreg_base;
}

BBDebugScope * bbObjectStructInfo( char * name ) {
	// create something to look up
	struct struct_node node;
	BBDebugScope scope;
	scope.name = name;
	node.scope = &scope;
	
	struct struct_node * found = (struct struct_node *)tree_search(&node, struct_node_compare, struct_root);

	if (found) {
		return found->scope;
	}
	
	return 0;
}

BBObject * bbNullObjectTest( BBObject *o ) {
	if (o == &bbNullObject) brl_blitz_NullObjectError();
	return o;
}

static struct avl_root *enum_root = 0;

int enum_node_compare(const void *x, const void *y) {

        struct enum_node * node_x = (struct enum_node *)x;
        struct enum_node * node_y = (struct enum_node *)y;

        return strcmp(node_x->scope->name, node_y->scope->name);
}

void bbObjectRegisterEnum( BBDebugScope *p ) {
	struct enum_node * node = (struct enum_node *)malloc(sizeof(struct enum_node));
	node->scope = p;
	
	struct enum_node * old_node = (struct enum_node *)avl_map(&node->link, enum_node_compare, &enum_root);
	if (&node->link != &old_node->link) {
		// this object already exists here...
		// delete the new node, since we don't need it
		// note : should never happen as structs should only ever be registered once.
		free(node);
	}
}

BBDebugScope * bbObjectEnumInfo( char * name ) {
	// create something to look up
	struct enum_node node;
	BBDebugScope scope;
	scope.name = name;
	node.scope = &scope;
	
	struct enum_node * found = (struct enum_node *)tree_search(&node, enum_node_compare, enum_root);

	if (found) {
		return found->scope;
	}
	
	return 0;
}