#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "modyaml.h"
#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>


int print(lua_State *L, char* messages)
{
    lua_getglobal(L, "print");
    lua_pushstring(L, messages);
    lua_call(L, 1, 0);
    return 1;
}

int SpecificDeletion(Files* files, const char* header) 
{
    for (int i = 0; i < files->nfiles; i++) {
        RemoveHeader(files->files[i], header);
    }
    return CHANGED_SUCCESS;
}

int SpecificAlteration(Files* files, const char* header_name, Header* header)
{
    for (int i = 0; i < files->nfiles; i++) {
        ChangeHeader(files->files[i], header_name, header);
    }
    return CHANGED_SUCCESS;
}

int SpecificAddition(Files* files, Yaml* yaml)
{
    for (int i = 0; i < files->nfiles; i++) {
        AddHeaders(files->files[i], yaml);
    }
    return CHANGED_SUCCESS;
}

int RecursiveDeletion(const char* dir, const char* header)
{
    char buffer[BUFFER_SIZE];
    sprintf(buffer, "find %s -maxdepth 5 -name '*.md'", dir);
    FILE* output = popen(buffer, "r");
    while (fgets(buffer, BUFFER_SIZE, output) != NULL) {
        buffer[strlen(buffer)-1] = buffer[strlen(buffer)];
        RemoveHeader(buffer, header);
    }
    return CHANGED_SUCCESS;
}

int RecursiveAddition(const char* dir, Yaml* yaml)
{
    char buffer[BUFFER_SIZE];
    sprintf(buffer, "find %s -maxdepth 5 -name '*.md'", dir);
    FILE* output = popen(buffer, "r");
    while (fgets(buffer, BUFFER_SIZE, output) != NULL) {
        buffer[strlen(buffer)-1] = buffer[strlen(buffer)];
        AddHeaders(buffer, yaml);
    }
    return CHANGED_SUCCESS;
}

int RecursiveAlteration(const char* dir, const char* header_name, Header* header) 
{
    char buffer[BUFFER_SIZE];
    sprintf(buffer, "find %s -maxdepth 5 -name '*.md'", dir);
    FILE* output = popen(buffer, "r");
    while (fgets(buffer, BUFFER_SIZE, output) != NULL) {
        buffer[strlen(buffer)-1] = buffer[strlen(buffer)];
        ChangeHeader(buffer, header_name, header);
    }
    return CHANGED_SUCCESS;
}

int ChangeYaml(const char* filepath, Yaml* yaml) 
{
    char buffer[BUFFER_SIZE];
    FILE* file = fopen(filepath, "r");
    if (!file) {
        return CHANGED_INVALID_FILE;
    }
    FILE* file_tmp = tmpfile();
    if (!CheckYaml(file)) {
        fclose(file);
        fclose(file_tmp);
        return CHANGED_NO_YAML;
    }
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        if (strcmp(buffer, "---\n") == 0) {
            break;
        } 
    }
    fputs("---\n", file_tmp);
    for (int i = 0; i < yaml->nheaders; i++) {
        Header *data = &yaml->headers[i];
        if ((data->data) && (data->header)) {
            sprintf(buffer, "%s: %s\n", data->header, data->data);
            fputs(buffer, file_tmp);
        }
    }
    fputs("---\n", file_tmp);
    if (feof(file)) {
        file = fopen(filepath, "w");
        rewind(file_tmp);
        while (fgets(buffer, BUFFER_SIZE, file_tmp) != NULL) {
            fputs(buffer, file);
        }
        fclose(file);
        fclose(file_tmp);
        return CHANGED_SUCCESS;
    }

    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        fputs(buffer, file_tmp);
    }
    fclose(file);
    file = fopen(filepath, "w");
    rewind(file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file_tmp) != NULL) {
        fputs(buffer, file);
    }
    fclose(file);
    fclose(file_tmp);
    return CHANGED_SUCCESS;
}

int CheckYaml(FILE* stream) 
{
    char buffer[BUFFER_SIZE];
    fgets(buffer, BUFFER_SIZE, stream);
    if (strcmp(buffer, "---\n") == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}


int AddHeaders(const char* filepath, Yaml* yaml) {
    char buffer[BUFFER_SIZE];
    FILE* file = fopen(filepath, "r");
    if (!file) {
        return CHANGED_INVALID_FILE;
    }
    if (!CheckYaml(file)) {
        fclose(file);
        return CHANGED_NO_YAML;
    }
    FILE* file_tmp = tmpfile();
    fputs("---\n", file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        if (strcmp(buffer, "---\n") == 0) {
            break;
        }
        fputs(buffer, file_tmp);
    }
    for (int i = 0; i < yaml->nheaders; i++) {
        Header* header = &yaml->headers[i];
        if ((header->header) && (header->data)) {
            sprintf(buffer, "%s: %s\n", header->header, header->data);
            fputs(buffer, file_tmp);
        }
    }
    sprintf(buffer, "---\n");
    fputs(buffer, file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        fputs(buffer, file_tmp);
    }
    file = freopen(filepath, "w", file);
    rewind(file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file_tmp) != NULL) {
        fputs(buffer, file);
    }
    fclose(file);
    fclose(file_tmp);
    return CHANGED_SUCCESS;
}

int RemoveHeader(const char* filepath, const char* header) {
    int changed = FALSE;
    FILE* file = fopen(filepath, "r");
    if (!file) {
        return CHANGED_INVALID_FILE;
    }
    if (!CheckYaml(file)) {
        fclose(file);
        return CHANGED_NO_YAML;
    }
    char buffer[BUFFER_SIZE];
    FILE* file_tmp = tmpfile();
    fputs("---\n", file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        if (strcmp(buffer, "---\n") == 0) {
            fputs(buffer, file_tmp);
            break;
        }
        if (CheckHeader(buffer, header)) {
            changed = TRUE;
            continue;
        }
        fputs(buffer, file_tmp);
    }
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        fputs(buffer, file_tmp);
    }
    rewind(file_tmp);
    file = freopen(filepath, "w", file);
    while (fgets(buffer, BUFFER_SIZE, file_tmp) != NULL) {
        fputs(buffer, file);
    }
    fclose(file);
    fclose(file_tmp);
    if (changed) {
        return CHANGED_SUCCESS;
    } else {
        return CHANGED_FAILURE;
    }
}

char* StartOfHeader(char* line) 
{
    int spacespan = strspn(line, " ");
    return line + spacespan;
}
char* EndOfHeader(char* line) 
{
    char* colon = strchr(line, ':');
    char* EndOfHeader;
    for (int i = colon - line - 1; i >= 0; i--) {
        if (line[i] != ' ') {
            EndOfHeader = &line[i];
            break;
        }
    }
    return EndOfHeader;
    return line;
}


int ChangeHeader(const char* filepath, const char* header_name, Header* header)
{
    if (!header->header) {
        return CHANGED_FAILURE;
    }
    FILE* file = fopen(filepath, "r");
    if (!file) {
        return CHANGED_INVALID_FILE;
    }
    if (!CheckYaml(file)) {
        fclose(file);
        return CHANGED_NO_YAML;
    }
    char buffer[BUFFER_SIZE];
    FILE* file_tmp = tmpfile();
    fputs("---\n", file_tmp);
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        if (strcmp(buffer, "---\n") == 0) {
            fputs(buffer, file_tmp);
            break;
        }
        if (CheckHeader(buffer, header_name)) {
            sprintf(buffer, "%s: %s\n", header->header, header->data ? header->data : "");
        }
        fputs(buffer, file_tmp);
    }
    while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
        fputs(buffer, file_tmp);
    }
    rewind(file_tmp);
    file = freopen(filepath, "w", file);
    while (fgets(buffer, BUFFER_SIZE, file_tmp) != NULL) {
        fputs(buffer, file);
    }
    fclose(file);
    fclose(file_tmp);
    return CHANGED_SUCCESS;
}

int CheckHeader(char* line, const char* header) 
{
    char* beggining = StartOfHeader(line);
    char* ending = EndOfHeader(line);
    char* compare = (char*)calloc(strlen(header)+1, sizeof(char));
    strncpy(compare, beggining, (ending - beggining)+1);
    if (strcmp(compare, header) == 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}



 int lua_SpecificDeletion(lua_State *L)
{
    const char* header = luaL_checkstring(L, 1);
    luaL_checktype(L, -1, LUA_TTABLE);
    int size = lua_objlen(L, -1);
    const char** files = (const char**)calloc(size, sizeof(char*));
    for (int i = 0; i < size; i++) {
        lua_rawgeti(L, -1, i+1);
        files[i] = lua_tostring(L, -1);
        lua_pop(L, 1);
    }
    int ret = SpecificDeletion(&(Files){size, files}, header);
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}

int lua_SpecificAlteration(lua_State *L) 
{
    const char* header_name = luaL_checkstring(L, 1);
    luaL_checktype(L, -2, LUA_TTABLE);
    luaL_checktype(L, -1, LUA_TTABLE);
    lua_getfield(L, -2, "header");
    const char* header = lua_tostring(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, -2, "data");
    const char* data = lua_tostring(L, -1);
    lua_pop(L, 1);
    int size = lua_objlen(L, -1);
    const char** files = (const char**)calloc(size, sizeof(char*));
    for (int i = 0; i < size; i++) {
        lua_rawgeti(L, -1, i+1);
        files[i] = lua_tostring(L, -1);
        lua_pop(L, 1);
    }
    int ret = SpecificAlteration(&(Files){size, files}, header_name, &(Header){header, data});
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}


int lua_SpecificAddition(lua_State *L) {
    luaL_checktype(L, -2, LUA_TTABLE);
    luaL_checktype(L, -1, LUA_TTABLE);
    int nheaders = lua_objlen(L, -2);
    Header hd[HEADER_SIZE];
    Header* headers;
    if (HEADER_SIZE > nheaders) {
        headers = (Header*)calloc(nheaders, sizeof(Header));
    } else {
        headers = hd;
    }
    for (int i = 0; i < nheaders; i++) {
        lua_rawgeti(L, -2, i+1);
        lua_getfield(L, -1, "header");
        headers[i].header = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "data");
        headers[i].data = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pop(L, 1);
    }
    int size = lua_objlen(L, -1);
    const char** files = (const char**)calloc(size, sizeof(char*));
    for (int i = 0; i < size; i++) {
        lua_rawgeti(L, -1, i+1);
        files[i] = lua_tostring(L, -1);
        lua_pop(L, 1);
    }
    int ret = SpecificAddition(&(Files){size, files}, &(Yaml){nheaders, headers});
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}


int lua_RecursiveDeletion(lua_State *L)
{
    const char* dir = luaL_checkstring(L, 1);
    const char* header = luaL_checkstring(L, 2);
    int ret = RecursiveDeletion(dir, header);
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
    return 1;
}

int lua_RecursiveAlteration(lua_State *L)
{
    const char* dir = luaL_checkstring(L, 1);
    const char* header_name = luaL_checkstring(L, 2);
    luaL_checktype(L, -1, LUA_TTABLE);
    const char* hd;
    const char* data;
    lua_getfield(L, -1, "header");
    hd = lua_tostring(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, -1, "data");
    data = lua_tostring(L, -1);
    lua_pop(L, 1);
    if (!(hd && data)) {
        print(L, "Invalid parameters");
        lua_pushinteger(L, 1);
        return 1;
    }
    int ret = RecursiveAlteration(dir, header_name, &(Header){hd, data});
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
    return 1;
}
int lua_RecursiveAddition(lua_State *L)
{
    const char* dir = luaL_checkstring(L, 1);
    luaL_checktype(L, -1, LUA_TTABLE);
    Yaml yaml;
    Header headers[HEADER_SIZE];
    yaml.headers = headers;
    int sizearr = lua_objlen(L, -1);
    yaml.nheaders = sizearr;
    int isHeap = FALSE;
    if (sizearr > HEADER_SIZE) {
        yaml.headers = (Header*)calloc(sizearr, sizeof(Header));
        isHeap = TRUE;
    }
    for (int i = 0; i < sizearr; i++) {
        lua_rawgeti(L, -1, i+1);
        lua_getfield(L, -1, "header");
        if (lua_isnil(L, -1)) {
            lua_pushnumber(L, 1);
            return 1;
        }
        const char* header = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "data");
        if (lua_isnil(L, -1)) {
            lua_pushinteger(L, 1);
            return 1;
        }
        const char* data = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pop(L, 1);
        yaml.headers[i].data = data;
        yaml.headers[i].header = header;
    }
    int ret = RecursiveAddition(dir, &yaml);
    if (isHeap) {
        free(yaml.headers);
    }
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
    return 1;
}

int lua_ChangeHeader(lua_State *L)
{
    const char* filepath = luaL_checkstring(L, 1);
    const char* Header_name = luaL_checkstring(L, 2);
    luaL_checktype(L, -1, LUA_TTABLE);
    const char* hd;
    const char* data;
    lua_getfield(L, -1, "header");
    hd = lua_tostring(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, -1, "data");
    data = lua_tostring(L, -1);
    lua_pop(L, 1);
    if (!(data && hd)) {
        print(L, "Wrong set of arguments for the function");
        lua_pushinteger(L, 1);
        return 1;
    }
    int ret = ChangeHeader(filepath, Header_name, &(Header){hd, data});
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}

int lua_RemoveHeader(lua_State *L) 
{
    const char* filepath = luaL_checkstring(L, 1);
    const char* header = luaL_checkstring(L, 2);
    int ret = RemoveHeader(filepath, header);
    switch(ret) 
    {
        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
    return 1;
}

int lua_AddHeaders(lua_State *L)
{
    const char* filepath = luaL_checkstring(L, 1);
    luaL_checktype(L, 2, LUA_TTABLE);
    Yaml yaml;
    Header headers[HEADER_SIZE];
    yaml.headers = headers;
    int sizearr = lua_objlen(L, -1);
    yaml.nheaders = sizearr;
    int isHeap = FALSE;
    if (sizearr > HEADER_SIZE) {
        yaml.headers = (Header*)calloc(sizearr, sizeof(Header));
        isHeap = TRUE;
    }
    for (int i = 0; i < sizearr; i++) {
        lua_rawgeti(L, -1, i+1);
        lua_getfield(L, -1, "header");
        if (lua_isnil(L, -1)) {
            lua_pushnumber(L, 1);
            return 1;
        }
        const char* header = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "data");
        if (lua_isnil(L, -1)) {
            lua_pushinteger(L, 1);
            return 1;
        }
        const char* data = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pop(L, 1);
        yaml.headers[i].data = data;
        yaml.headers[i].header = header;
    }
    int ret = AddHeaders(filepath, &yaml);
    if (isHeap) {
        free(yaml.headers);
    }
    switch(ret) 
    {

        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}


int lua_ChangeYaml(lua_State *L) 
{
    const char* filepath = luaL_checkstring(L, 1);
    luaL_checktype(L, 2, LUA_TTABLE);
    Yaml yaml;
    Header headers[HEADER_SIZE];
    yaml.headers = headers;
    int sizearr = lua_objlen(L, -1);
    yaml.nheaders = sizearr;
    int isHeap = FALSE;
    if (sizearr > HEADER_SIZE) {
        yaml.headers = (Header*)calloc(sizearr, sizeof(Header));
        isHeap = TRUE;
    }
    for (int i = 0; i < sizearr; i++) {
        lua_rawgeti(L, -1, i+1);
        lua_getfield(L, -1, "header");
        if (lua_isnil(L, -1)) {
            lua_pushnumber(L, 1);
            return 1;
        }
        const char* header = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "data");
        if (lua_isnil(L, -1)) {
            lua_pushinteger(L, 1);
            return 1;
        }
        const char* data = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pop(L, 1);
        yaml.headers[i].data = data;
        yaml.headers[i].header = header;
        //printf("%s:\t%s", header, data);
    }
    int ret = ChangeYaml(filepath, &yaml);
    if (isHeap) {
        free(yaml.headers);
    }
    switch(ret) 
    {

        case CHANGED_SUCCESS:
            lua_pushinteger(L, 0);
            return 1;
            break;
        case CHANGED_INVALID_FILE:
            print(L, "Invalid filepath");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_FAILURE:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
        case CHANGED_NO_YAML:
            print(L, "File does not cotaing yaml");
            lua_pushinteger(L, 1);
            return 1;
            break;
        default:
            print(L, "Failed to execute operation");
            lua_pushinteger(L, 1);
            return 1;
            break;
    }
}


int luaopen_lib_modyamllib(lua_State *L) {
    luaL_reg functions[] = {
        {"ChangeYaml", lua_ChangeYaml},
        {"AddHeaders", lua_AddHeaders},
        {"RemoveHeader", lua_RemoveHeader},
        {"ChangeHeader", lua_ChangeHeader},
        {"RecursiveDeletion", lua_RecursiveDeletion},
        {"RecursiveAddition", lua_RecursiveAddition},
        {"RecursiveAlteration", lua_RecursiveAlteration},
        {"SpecificDeletion", lua_SpecificDeletion},
        {"SpecificAlteration", lua_SpecificAlteration},
        {"SpecificAddition", lua_SpecificAddition},
        {NULL, NULL}
    };
    luaL_register(L, "modyaml", functions);
    return 1;
}
