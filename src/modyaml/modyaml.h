#ifndef MODYAML_H
#define MODYAML_H
#include <stdio.h>
#include <lua5.1/lua.h>

#define TRUE 1
#define FALSE 0
#define HEADER_SIZE 8
#define BUFFER_SIZE 256

typedef struct {
    int nfiles;
    const char** files;
} Files;

enum success {
    CHANGED_SUCCESS,
    CHANGED_FAILURE,
    CHANGED_NO_YAML,
    CHANGED_INVALID_FILE,
};

typedef struct {
    const char* header;
    const char* data;
} Header;

typedef struct {
    int nheaders;
    Header* headers;
} Yaml;


int CheckYaml(FILE* stream); // simple function that check for the yaml
int CheckHeader(char* line, const char* header); // Checks if the line has a valid header syntax
char* StartOfHeader(char* line); // returns a pointer to the beggining of the header segment 
char* EndOfHeader(char* line); // returns a pointer to the end of the header delimited by ':'
int ChangeYaml(const char* filepath, Yaml* yaml);
int ChangeHeader(const char* filepath, const char* header_name, Header* header);
int AddHeaders(const char* filepath, Yaml* yaml);
int RemoveHeader(const char* filepath, const char* header);
int RecursiveDeletion(const char* dir, const char* header);
int RecursiveAlteration(const char* dir, const char* header_name, Header* header);
int RecursiveAddition(const char* dir, Yaml* yaml);
int SpecificDeletion(Files* files, const char* header); 
int SpecificAlteration(Files* files, const char* header_name, Header* header);
int SpecificAddition(Files* files, Yaml* yaml); 

// Lua macros

int lua_SpecificDeletion(lua_State *L);
int lua_SpecificAlteration(lua_State *L);
int lua_SpecificAddition(lua_State *L);
int lua_RecursiveDeletion(lua_State *L);
int lua_RecursiveAlteration(lua_State *L);
int lua_RecursiveAddition(lua_State *L);
int lua_ChangeHeader(lua_State *L);
int lua_RemoveHeader(lua_State *L);
int lua_AddHeaders(lua_State *L);
int lua_ChangeYaml(lua_State *L);

#endif
