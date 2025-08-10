#include "ErrorLogging.h"
#include "update.h"
#include "yamlread.h"
#include <libpq-fe.h>
#include <sys/stat.h>


extern "C" {
    #include "lua5.1/lua.h"
    #include "lua5.1/lauxlib.h"

    int input(lua_State *L, const char* input)
    {
        lua_getglobal(L, "vim");
        lua_pushstring(L, "fn");
        lua_gettable(L, -2);
        lua_pushstring(L, "input");
        lua_gettable(L, -2);
        lua_pushstring(L, input);
        lua_call(L, 1, 1);
        return 1;
    }

    int print(lua_State *L, const char* message)
    {
        lua_getglobal(L, "print");
        lua_pushstring(L, message);
        lua_call(L, 1, 0);
        return 1;
    }

    int CheckDatabase(lua_State *L)
    {
        ErrorLogging err {};
        const char* wiki = luaL_checkstring(L, 1);
        PGconn* db = PQconnectdb("dbname=postgres");
        PGresult* res = PQexec(db, "CREATE DATABASE wiki");
        PQfinish(db);
        db = PQconnectdb("dbname=wiki");
        PQclear(res);
        char query[] = "SELECT table_name FROM information_schema.tables WHERE table_name = 'wiki'";
        res = PQexec(db, query);
        if (PQresultStatus(res) == PGRES_TUPLES_OK && PQntuples(res) == 0) {
            char* command = (char*)calloc(strlen(wiki)+35, sizeof(char));
            sprintf(command, "[ -f %s/.wiki.sql ];", wiki);
            if (system(command) == 0) {
                sprintf(command, "psql -d wiki -f %s/.wiki.sql >> /dev/null", wiki);
                if (system(command) != 0) {
                    print(L, PQresultErrorMessage(res));
                    err.returnstatus = S_FAILURE;
                }
                free(command);
            } else {
                input(L, "Backup from wiki not found in the wiki directory, would you like to create a table from scratch [y/n]: ");
                const char* ret = lua_tostring(L, -1);
                if (strcmp(ret, "y") == 0) {
                    PQclear(res);
                    char query[] = "CREATE TABLE wiki (inode integer UNIQUE NOT NULL, path varchar(160) PRIMARY KEY, title varchar(60) UNIQUE NOT NULL, lastwrote integer NOT NULL, date Date, links varchar(70), topic varchar(70), tags TEXT[], author varchar(40))";
                    res = PQexec(db, query);
                    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
                        print(L, PQresultErrorMessage(res));
                        err.returnstatus = S_FAILURE;
                    }
                } else 
                    print(L, "Action interrupted by user");
            }
        } else if (PQresultStatus(res) == PGRES_FATAL_ERROR) {
            print(L, PQresultErrorMessage(res));
            err.returnstatus = S_FAILURE;
        }
        PQfinish(db);
        lua_pushinteger(L, err.returnstatus);
        return 1;
    }

    int Update(lua_State *L)
    {
        const char* wiki = luaL_checkstring(L, 1);
        switch(Update(wiki))
        {
            case S_SUCCESS:
                lua_pushinteger(L, S_SUCCESS);
                return 1;
                break;
            case S_FAILURE:
                lua_pushinteger(L, S_FAILURE);
                return 1;
                break;
            case S_WARNINGS:
                lua_pushinteger(L, S_WARNINGS);
                return 1;
                break;
            default:
                lua_pushinteger(L, S_FAILURE);
                return 1;
                break;
        }
    }

    int UpdateForce(lua_State *L)
    {
        const char* wiki = luaL_checkstring(L, 1);
        switch(Update(wiki, true))
        {
            case S_SUCCESS:
                lua_pushinteger(L, S_SUCCESS);
                return 1;
                break;
            case S_FAILURE:
                lua_pushinteger(L, S_FAILURE);
                return 1;
                break;
            case S_WARNINGS:
                lua_pushinteger(L, S_WARNINGS);
                return 1;
                break;
            default:
                lua_pushinteger(L, S_FAILURE);
                return 1;
                break;
        }
    }

    // TODO: test function
    int UpdateFileNoWrite(lua_State *L)
    {
        PGconn* db = PQconnectdb("dbname=wiki");
        const char* arg1 = luaL_checkstring(L, 1);
        const char* arg2 = luaL_checkstring(L, 2);
        char* path = (char*)calloc(strlen(arg1)+1, sizeof(char));
        char* yaml = (char*)calloc(strlen(arg2)+1, sizeof(char));
        strcpy(path, arg1);
        strcpy(yaml, arg2);
        char buffer[300];
        File node {path, yaml};
        ErrorLogging err {};
        if (node.yaml.yamlstatus != YAML_SUCCESS) {
            yamlErrorMessage(err, node.yaml.yamlstatus, node.path);
            print(L, err.message.str().c_str());
            free(yaml);
            free(path);
            lua_pushinteger(L, err.returnstatus);
            return 1;
        }
        sprintf(buffer, "SELECT inode, lastwrote FROM wiki WHERE path = '%s'", node.path);
        PGresult* selectres;
        if (CheckExistance(db, buffer, selectres)) {
            print(L, "reached");
            UpdateRow(db, node, err);
            PQclear(selectres);
        } else {
            PQclear(selectres);

            if (node.title != NULL) {
                sprintf(buffer, "select * from wiki where title = '%s'", node.title);
                PGresult* titlequery;
                if (CheckExistance(db, buffer, titlequery)) {
                    sprintf(buffer, "UPDATE wiki SET path = '%s' WHERE title = '%s'", node.path, node.title);
                    PQexec(db, buffer);
                    UpdateRow(db, node, err);
                    PQclear(titlequery);
                    lua_pushinteger(L, err.returnstatus);
                    free(yaml);
                    free(path);
                    return 1;
                }
            }

            if (node.inode != 0) {
                sprintf(buffer, "select * from wiki where inode = %d", node.inode);
                PGresult* inodequery;
                if (CheckExistance(db, buffer, inodequery)) {
                    sprintf(buffer, "UPDATE wiki SET path = '%s' WHERE inode = %d", node.path, node.inode);
                    PQexec(db, buffer);
                    UpdateRow(db, node, err);
                    PQclear(inodequery);
                    lua_pushinteger(L, err.returnstatus);
                    free(yaml);
                    free(path);
                    return 1;
                }
            }

            InsertRow(db, node, err);
        }
        free(yaml);
        free(path);
        lua_pushinteger(L, err.returnstatus);
        return 1;
    }


    int UpdateInodeAndTime(lua_State *L) {
        const char *path = luaL_checkstring(L, 1);
        PGconn* db = PQconnectdb("dbname=wiki");
        struct stat file_stat;
        char buffer[300];
        if (stat(path, &file_stat) == 0) {
            sprintf(buffer, "UPDATE wiki SET lastwrote = %d, inode = %d WHERE path = '%s'", (int)file_stat.st_mtime, (int)file_stat.st_ino, path);
            PGresult *res = PQexec(db, buffer);
            if (PQresultStatus(res) != PGRES_COMMAND_OK) {
                print(L, PQresultErrorMessage(res));
                lua_pushinteger(L, S_FAILURE);
                return 1;
            } 
        } else {
            sprintf(buffer, "Could not stat the file: %s", path);
            print(L, buffer);
            lua_pushinteger(L, S_FAILURE);
            return 1;
        }
        lua_pushinteger(L, S_SUCCESS);
        return 1;
    }

    // TODO: as duas funções abaixo
    int Querydb(lua_State *L);
    int QueryExpressionOnly(lua_State *L);

    int luaopen_lib_psmanager(lua_State *L)
    {
        luaL_reg functions[] {
            {"CheckDatabase", CheckDatabase},
            {"Update", Update},
            {"UpdateForce", UpdateForce},
            {"UpdateNoWrite", UpdateFileNoWrite},
            {"UpdateInodeTime", UpdateInodeAndTime},
            {NULL, NULL}
        };
        luaL_register(L, "psmanager", functions);
        return 1;
    }
}
