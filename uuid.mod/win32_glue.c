/*
 Copyright (c) 2015-2025 Bruce A Henderson
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the author nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
# include <windows.h>

void uuid_generate(char * buf) {
    UUID uuid;
    UuidCreate(&uuid);
    memcpy(buf, &uuid, 16);
}

void uuid_unparse_upper( char * buf, char * out ) {
    UUID * uuid = (UUID *)buf;
    sprintf( out,
             "%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X",
             uuid->Data1, uuid->Data2, uuid->Data3,
             uuid->Data4[0], uuid->Data4[1], uuid->Data4[2],
             uuid->Data4[3], uuid->Data4[4], uuid->Data4[5],
             uuid->Data4[6], uuid->Data4[7] );
}

void uuid_unparse( char * buf, char * out ) {
    UUID * uuid = (UUID *)buf;
    sprintf( out,
             "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
             uuid->Data1, uuid->Data2, uuid->Data3,
             uuid->Data4[0], uuid->Data4[1], uuid->Data4[2],
             uuid->Data4[3], uuid->Data4[4], uuid->Data4[5],
             uuid->Data4[6], uuid->Data4[7] );
}
