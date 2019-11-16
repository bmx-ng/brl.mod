
#include <brl.mod/blitz.mod/blitz.h>
//#include <cstdarg>

void *bbRefFieldPtr( BBObject *obj,int index ){
	return (char*)obj+index;
}

void *bbRefMethodPtr( BBObject *obj,int index ){
	return *( (void**) ((char*)obj->clas+index) );
}

void *bbRefArrayElementPtr( int sz,BBArray *array,int index ){
	return (char*)BBARRAYDATA( array,array->dims )+sz*index;
}

void * bbRefArrayClass(){
	return &bbArrayClass;
}

void * bbRefStringClass(){
	return &bbStringClass;
}

void * bbRefObjectClass(){
	return &bbObjectClass;
}

int bbRefArrayLength( BBArray *array, int dim ){
	return array->scales[((dim <= array->dims)? dim : 0)];
}

int bbRefArrayDimensions( BBArray *array ){
	return array->dims;
}

BBClass * bbRefClassSuper( BBClass* clas ){
	return clas->super;
}

BBDebugScope * bbRefClassDebugScope( BBClass* clas ){
	return clas->debug_scope;
}

const char * bbRefClassDebugScopeName( BBClass* clas ){
	return clas->debug_scope->name;
}

BBDebugDecl * bbRefClassDebugDecl( BBClass* clas ){
	return clas->debug_scope->decls;
}

int bbDebugDeclKind( BBDebugDecl * decl ){
	return decl->kind;
}

const char * bbDebugDeclName( BBDebugDecl * decl ){
	return decl->name;
}

const char * bbDebugDeclType( BBDebugDecl * decl ){
	return decl->type_tag;
}

BBString * bbDebugDeclConstValue( BBDebugDecl * decl ){
	return decl->const_value;
}

int bbDebugDeclFieldOffset( BBDebugDecl * decl ){
	return decl->field_offset;
}

void * bbDebugDeclVarAddress( BBDebugDecl * decl ){
	return decl->var_address;
}

BBDebugDecl * bbDebugDeclNext( BBDebugDecl * decl ){
	return decl + 1;
}

//Note: arrDims must be 1D int array...
BBArray *bbRefArrayCreate( const char *type,BBArray *arrDims ){
//	assert( arrDims->dims==1 );
//	assert( arrDims->type[0]=='i' );
	
	int dims=arrDims->scales[0];
	int *lens=(int*)BBARRAYDATA( arrDims,1 );
	
	return bbArrayNewEx( type,dims,lens );
}

BBString *bbRefArrayTypeTag( BBArray *array ){
	return bbStringFromCString( array->type );
}

BBObject *bbRefGetObject( BBObject **p ){
	return *p;
}

void bbRefPushObject( BBObject **p,BBObject *t ){
	*p=t;
}

void bbRefInitObject( BBObject **p,BBObject *t ){
	*p=t;
}

void bbRefAssignObject( BBObject **p,BBObject *t ){
	*p=t;
}

BBClass *bbRefGetObjectClass( BBObject *p ){
	return p->clas;
}

BBClass *bbRefGetSuperClass( BBClass *clas ){
	return clas->super;
}

BBString * bbStringFromRef(void * ref) {
	return (BBString*)ref;
}

BBArray * bbRefArrayNull() {
	return &bbEmptyArray;
}

const char * bbInterfaceName(BBInterface * ifc) {
	return ifc->clas->debug_scope->name;
}

BBClass * bbInterfaceClass(BBInterface * ifc) {
	return ifc->clas;
}

int bbObjectImplementsInterfaces(BBClass *clas) {
	return clas->itable != 0;
}

int bbObjectImplementedCount(BBClass *clas) {
	return clas->itable->ifc_size;
}

BBInterface * bbObjectImplementedInterface(BBClass * clas, int index) {
	return clas->itable->ifc_offsets[index].ifc;
}

