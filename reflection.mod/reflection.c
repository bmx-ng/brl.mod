
#include <brl.mod/blitz.mod/blitz.h>
//#include <cstdarg>



void* bbRefObjectFieldPtr(BBObject* obj, size_t offset) {
	return (char*)obj + offset;
}

void* bbRefArrayElementPtr(size_t sz, BBArray* array, int index) {
	return (char*)BBARRAYDATA(array, array->dims) + sz * index;
}

void* bbRefArrayClass() {
	return &bbArrayClass;
}

void* bbRefStringClass() {
	return &bbStringClass;
}

void* bbRefObjectClass() {
	return &bbObjectClass;
}

int bbRefArrayLength(BBArray* array, int dim) {
	return array->scales[((dim <= array->dims) ? dim : 0)];
}

int bbRefArrayDimensions(BBArray* array) {
	return array->dims;
}

BBClass* bbRefClassSuper(BBClass* clas) {
	return clas->super;
}

BBDebugScope* bbRefClassDebugScope(BBClass* clas) {
	return clas->debug_scope;
}

const char* bbRefClassDebugScopeName(BBClass* clas) {
	return clas->debug_scope->name;
}

const char* bbDebugScopeName(BBDebugScope* scope) {
	return scope->name;
}

BBDebugDecl* bbDebugScopeDecl(BBDebugScope* scope) {
	return scope->decls;
}

BBDebugDecl* bbRefClassDebugDecl(BBClass* clas) {
	return clas->debug_scope->decls;
}

int bbDebugDeclKind(BBDebugDecl* decl) {
	return decl->kind;
}

const char* bbDebugDeclName(BBDebugDecl* decl) {
	return decl->name;
}

const char* bbDebugDeclType(BBDebugDecl* decl) {
	return decl->type_tag;
}

BBString* bbDebugDeclConstValue(BBDebugDecl* decl) {
	return decl->const_value;
}

size_t bbDebugDeclFieldOffset(BBDebugDecl* decl) {
	return decl->field_offset;
}

void* bbDebugDeclVarAddress(BBDebugDecl* decl) {
	return decl->var_address;
}

void* bbDebugDeclFuncPtr(BBDebugDecl* decl) {
	return decl->func_ptr;
}

size_t bbDebugDeclStructSize(BBDebugDecl* decl) {
	return decl->struct_size;
}

void* bbDebugDeclReflectionWrapper(BBDebugDecl* decl) {
	return decl->reflection_wrapper;
}

BBDebugDecl* bbDebugDeclNext(BBDebugDecl* decl) {
	return decl + 1;
}

//Note: arrDims must be 1D int array...
BBArray* bbRefArrayCreate(const char* type, BBArray* arrDims) {
//	assert(arrDims->dims == 1);
//	assert(arrDims->type[0] == 'i');
	
	int dims = arrDims->scales[0];
	int* lens = (int*)BBARRAYDATA(arrDims, 1);
	
	return bbArrayNewEx(type, dims, lens);
}

BBString* bbRefArrayTypeTag(BBArray* array) {
	return bbStringFromCString(array->type);
}

BBObject* bbRefGetObject(BBObject** p) {
	return* p;
}

void bbRefPushObject(BBObject** p, BBObject* t) {
	*p = t;
}

void bbRefInitObject(BBObject** p, BBObject* t) {
	*p = t;
}

void bbRefAssignObject(BBObject** p, BBObject* t) {
	*p = t;
}

BBClass* bbRefGetObjectClass(BBObject* p) {
	return p->clas;
}

BBClass* bbRefGetSuperClass(BBClass* clas) {
	return clas->super;
}

BBString* bbStringFromRef(void* ref) {
	return (BBString*)ref;
}

BBArray* bbRefArrayNull() {
	return &bbEmptyArray;
}

const char* bbInterfaceName(BBInterface* ifc) {
	return ifc->clas->debug_scope->name;
}

BBClass* bbInterfaceClass(BBInterface* ifc) {
	return ifc->clas;
}

int bbObjectImplementsInterfaces(BBClass* clas) {
	return clas->itable != 0;
}

int bbObjectImplementedCount(BBClass* clas) {
	return clas->itable->ifc_size;
}

BBInterface* bbObjectImplementedInterface(BBClass* clas, int index) {
	return clas->itable->ifc_offsets[index].ifc;
}



#ifdef __x86_64__

static BBDebugScope debugScopeInt128 = {
	BBDEBUGSCOPE_USERSTRUCT,
	"Int128",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.struct_size = sizeof(BBINT128),
			(void (*)(void**))0
		}
	}
};
static BBDebugScope debugScopeFloat64 = {
	BBDEBUGSCOPE_USERSTRUCT,
	"Float64",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.struct_size = sizeof(BBFLOAT64),
			(void (*)(void**))0
		}
	}
};
static BBDebugScope debugScopeFloat128 = {
	BBDEBUGSCOPE_USERSTRUCT,
	"Float128",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.struct_size = sizeof(BBFLOAT128),
			(void (*)(void**))0
		}
	}
};
static BBDebugScope debugScopeDouble128 = {
	BBDEBUGSCOPE_USERSTRUCT,
	"Double128",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.struct_size = sizeof(BBDOUBLE128),
			(void (*)(void**))0
		}
	}
};

BBDebugScope* debugScopePtrInt128 = &debugScopeInt128;
BBDebugScope* debugScopePtrFloat64 = &debugScopeFloat64;
BBDebugScope* debugScopePtrFloat128 = &debugScopeFloat128;
BBDebugScope* debugScopePtrDouble128 = &debugScopeDouble128;

#endif


