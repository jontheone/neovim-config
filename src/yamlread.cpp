#include <cstring>
#include <stdlib.h>
#include <stdio.h>
#include "yamlread.h"
#include <new>

int matchheader(char* buffer, yaml_s &yaml)
{
    if (buffer[strlen(buffer)-1] == '\n') {
        buffer[strlen(buffer)-1] = buffer[strlen(buffer)];
    }
    int padding = strspn(buffer, " ");
    char *data = &buffer[padding];
    //std::cout << data << std::endl;
    int colon_pos {};
    int stringend = -1;
    for (int i = 0; i<strlen(data); i++) {
        if (data[i] == ':') {
            stringend = i-1;
            colon_pos = i;
            break;
        }
    }
    if (stringend == -1 || data[0] == ' ') {
        return 0;
    }
    for (int i = stringend; i >= 0; i--) {
        if (data[i] != ' ') {
            stringend = i;
            break;
        }
    } 
    yaml.headers[yaml.nheaders].alloc_if_needed_header(stringend+1);
    strncpy(yaml.headers[yaml.nheaders].header, data, stringend+1);
    strcat(yaml.headers[yaml.nheaders].header, "");
    data = &buffer[colon_pos];
    padding = strspn(data+1, " ") + 1;
    if (strlen(data) == padding) {
        return 1;
    }
    data = &data[padding];
    stringend = strlen(data);
    for (int i = stringend-1; i >= 0; i--) {
        if (data[i] != ' ') {
            stringend = i;
            break;
        }
    }
    if (data[0] == '[' && data[stringend] == ']') {
        yaml.headers[yaml.nheaders].type = T_LIST;
        data[0] = '{';
        data[stringend] = '}';
        yaml.headers[yaml.nheaders].alloc_if_needed_data(strlen(data));
        strncpy(yaml.headers[yaml.nheaders].data, data, stringend+1);
        strcat(yaml.headers[yaml.nheaders].data, "");
    } else {
        yaml.headers[yaml.nheaders].type = T_LINE;
        yaml.headers[yaml.nheaders].alloc_if_needed_data(strlen(data));
        strncpy(yaml.headers[yaml.nheaders].data, data, stringend+1);
        strcat(yaml.headers[yaml.nheaders].data, "");
    }
    return 2;
}

yaml_s collectyaml(char* filepath)
{
    yaml_s yaml {};
    char buffer[200];
    FILE* file = fopen(filepath, "r");
    if (file == NULL)  {
        yaml.yamlstatus = YAML_INVALID_FILE;
        return yaml;
    }
    fgets(buffer, 200, file);
    if (strcmp(buffer, "---\n") != 0) yaml.yamlstatus = YAML_EMPTY;
    int i = 0;
    while (fgets(buffer, 200, file) != NULL) {
        yaml.alloc_if_needed();
        if (yaml.headers[yaml.nheaders].type == 0) {
            new (&yaml.headers[yaml.nheaders]) header_s();
        }
        if (strcmp(buffer, "---\n") == 0) {
            break;
        } 
        matchheader(buffer, yaml);
        if (yaml.yamlstatus == YAML_FAILURE)
            break;
        yaml.nheaders++;
    }
    fclose(file);
    return yaml;
}

int readlines(char* buffer, int bufferlen, char* &yaml)
{
    int stringend = 0;
    for (int i = 0; i<strlen(yaml); i++)
    {
        if (yaml[i] == '\n' || yaml[i+1] == '\0') {
            stringend = i;
            break;
        }
    }
    if (stringend == 0)
        return 1;
    strncpy(buffer, yaml, stringend+1);
    buffer[stringend+1] = '\0';
    yaml = &yaml[stringend+1];
    return 0;
}

yaml_s collectyamlstring(char* yamlstring)
{
    yaml_s yaml {};
    char buffer[200] = {0};
    if (strcmp(yamlstring, "") == 0) {
        yaml.yamlstatus = YAML_EMPTY;
        return yaml;
    }
    int i = 0;
    while (readlines(buffer, 200, yamlstring) != 1) {
        yaml.alloc_if_needed();
        if (yaml.headers[yaml.nheaders].type == 0) {
            new (&yaml.headers[yaml.nheaders]) header_s();
        }
        if (strcmp(buffer, "---\n") == 0) {
            break;
        } 
        matchheader(buffer, yaml);
        if (yaml.yamlstatus == YAML_FAILURE)
            break;
        yaml.nheaders++;
    }
    std::cout << "seila" << std::endl;
    return yaml;
}
