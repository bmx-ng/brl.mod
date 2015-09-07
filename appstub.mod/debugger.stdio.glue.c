
#include "brl.mod/blitz.mod/blitz.h"

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugScopeName(struct BBDebugScope * scope) {
	return bbStringFromCString(scope->name);
}

int bmx_debugger_DebugScopeKind(struct BBDebugScope * scope) {
	return scope->kind;
}

struct BBDebugDecl * bmx_debugger_DebugScopeDecl(struct BBDebugScope * scope) {
	return &scope->decls[0];
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugDeclName(struct BBDebugDecl * decl) {
	return bbStringFromCString(decl->name);
}

BBString * bmx_debugger_DebugDeclType(struct BBDebugDecl * decl) {
	return bbStringFromCString(decl->type_tag);
}

int bmx_debugger_DebugDeclKind(struct BBDebugDecl * decl) {
	return decl->kind;
}

struct BBDebugDecl * bmx_debugger_DebugDeclNext( struct BBDebugDecl * decl ) {
	return ((char *)decl) + sizeof(struct BBDebugDecl);
}

void * bmx_debugger_DebugDecl_VarAddress( struct BBDebugDecl * decl ) {
	return decl->var_address;
}

BBString * bmx_debugger_DebugDecl_ConstValue(struct BBDebugDecl * decl) {
	return decl->const_value;
}

void * bmx_debugger_DebugDecl_FieldOffset(struct BBDebugDecl * decl, void * inst) {
	return ((char *)inst) + decl->field_offset;
}

BBString * bmx_debugger_DebugDecl_StringFromAddress(BBString * p) {
	return p;
}

int bmx_debugger_DebugDeclTypeChar(struct BBDebugDecl * decl) {
	return decl->type_tag[0];
}

int bmx_debugger_DebugDecl_ArraySize(BBArray * array) {
	return array->scales[0];
}

BBClass * bmx_debugger_DebugDecl_clas( BBObject * inst ) {
	return inst->clas;
}

int bmx_debugger_DebugDecl_isStringClass(BBClass * clas) {
	return clas == &bbStringClass;
}

int bmx_debugger_DebugDecl_isArrayClass(BBClass * clas) {
	return clas == &bbArrayClass;
}

int bmx_debugger_DebugDecl_isBaseObject(BBClass * clas) {
	return clas->super == 0;
}

struct BBDebugDecl * bmx_debugger_DebugDecl_ArrayDecl(BBArray  * arr) {
	struct BBDebugDecl * decl = malloc(sizeof(struct BBDebugDecl));
	
	decl->kind = BBDEBUGDECL_LOCAL;
	decl->name = 0;
	decl->type_tag = arr->type;

	return decl;
}

void bmx_debugger_DebugDecl_ArrayDeclIndexedPart(struct BBDebugDecl * decl, BBArray  * arr, int index) {
	
	int size = 4;
	switch( arr->type[0] ){
		case 'b':size=1;break;
		case 's':size=2;break;
		case 'l':size=8;break;
		case 'd':size=8;break;
		case '*':size=sizeof(void*);break;
		case ':':size=sizeof(void*);break;
		case '$':size=sizeof(void*);break;
		case '[':size=sizeof(void*);break;
		case '(':size=sizeof(void*);break;
	}

	decl->var_address = ((char*)BBARRAYDATA(arr, arr->dims)) + size * index;
}

void bmx_debugger_DebugDecl_ArrayDeclFree(struct BBDebugDecl * decl) {
	free(decl);
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBString * bmx_debugger_DebugStmFile(struct BBDebugStm * stmt) {
	return bbStringFromCString(stmt->source_file);
}

int bmx_debugger_DebugStmLine(struct BBDebugStm * stmt) {
	return stmt->line_num;
}

int bmx_debugger_DebugStmChar(struct BBDebugStm * stmt) {
	return stmt->char_num;
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BBClass * bmx_debugger_DebugClassSuper(BBClass * clas) {
	return clas->super;
}

struct BBDebugScope * bmx_debugger_DebugClassScope(BBClass * clas) {
	return clas->debug_scope;
}
