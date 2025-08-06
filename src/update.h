#ifndef UPDATE_H
#define UPDATE_H
#include <sys/stat.h>
#include "ErrorLogging.h"
#include "yamlread.h"

struct File {
    char* path;
    int inode {0};
    int time {0};
    char* title {NULL};
    yaml_s yaml;

    File(char* file) : path{file}, yaml{collectyaml(file)} {
        struct stat file_stat;
        int ret = stat(file, &file_stat);
        if (ret == 0) {
            inode = file_stat.st_ino;
            time = file_stat.st_mtime;
        }
        for (int i=0; i<yaml.nheaders; i++) {
            if (strcmp(yaml.headers[i].header, "title") == 0) {
                title = yaml.headers[i].data;
                break;
            }
        }
    }
};


int Update(const char* wiki);
int ForceUpdate(const char* wiki);
int UpdateFile(const char* file);
int UpdateFileNoWrite(const char* file, const char* yaml);
int UpdateInode(const char* file);

#endif
