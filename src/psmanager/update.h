#ifndef UPDATE_H
#define UPDATE_H
#include <sys/stat.h>
#include <libpq-fe.h>
#include <cstring>
#include "ErrorLogging.h"
#include "yamlread.h"

struct File {
    char* path;
    int inode {0};
    int time {0};
    char* title {NULL};
    yaml_s yaml;

    File(char* file, const char* wiki) : path{file}, yaml{collectyaml(file)} {
        if (memcmp(file, wiki, strlen(wiki)) == 0) {
            path = &file[strlen(wiki)+1];
        }
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

    File(char* file, char* yamlstring) : path{file}, yaml{collectyamlstring(yamlstring)} {
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


void InsertRow(PGconn* db, File &file, ErrorLogging &err);
void UpdateRow(PGconn* db, File &file, ErrorLogging &err);
bool CheckExistance(PGconn* db,const char* query);
bool CheckExistance(PGconn* db,const char* query, PGresult* &res);
int Update(const char* wiki, bool force = false);

#endif
