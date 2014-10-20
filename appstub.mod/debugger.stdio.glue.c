
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

BBString * bmx_debugger_DebugDecl_StringFromAddress(BBString ** p) {
	return *p;
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

