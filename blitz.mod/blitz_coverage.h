#ifndef BLITZ_COVERAGE_H
#define BLITZ_COVERAGE_H

#ifdef BMX_COVERAGE

#include "hashmap/hashmap.h"

typedef struct {
    const char* file;
    int line;
    int count;
} BBCoverageLineExecInfo;

typedef struct {
    const char* file;
    const char* func;
    int line;
    int count;
} BBCoverageFuncExecInfo;

typedef struct {
    const char* func;
    int line;
} BBCoverageFunctionInfo;

typedef struct {
    const char* filename;
    const int* coverage_lines;
    size_t coverage_lines_count;
    void* line_map;
    const BBCoverageFunctionInfo* coverage_functions;
    size_t coverage_functions_count;
    void* func_map;
} BBCoverageFileInfo;

extern BBString * bbCoverageOutputFileName;

void bbCoverageStartup();
void bbCoverageRegisterFile(BBCoverageFileInfo * coverage_files);
void bbCoverageUpdateLineInfo(const char* file, int line);
void bbCoverageUpdateFunctionLineInfo(const char* file, const char* func, int line);
void bbCoverageGenerateOutput();

#endif // BMX_COVERAGE

#endif // BLITZ_COVERAGE_H
