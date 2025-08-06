#include "ErrorLogging.h"
#include "update.h"
#include <libpq-fe.h>


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
        } else {
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
                return 1;
                break;
            case S_FAILURE:
                return 1;
                break;
            case S_WARNINGS:
                return 1;
                break;
            default:
                return 1;
                break;
        }
    }

    int luaopen_lib_psmanager(lua_State *L)
    {
        luaL_reg functions[] {
            {"CheckDatabase", CheckDatabase},
            {NULL, NULL}
        };
        luaL_register(L, "psmanager", functions);
        return 1;
    }
    
}
