#include <stdlib.h>
#include "ErrorLogging.h"
#include <libpq-fe.h>
#include <cstring>
#include <stdio.h>
#include <string>
#include "update.h"
#include "yamlread.h"


bool CheckExistance(PGconn* db,const char* query)
{
    ErrorLogging err {};
    PGresult* res = PQexec(db, query);
    switch (PQresultStatus(res))
    {
        case PGRES_TUPLES_OK:
            if (PQntuples(res) > 0) {
                return true;
            } else {
                return false;
            }
            break;
        case PGRES_FATAL_ERROR:
            err.message << PQresultErrorMessage(res);
            LogErr(err, query);
            return false;
            break;
        default:
            err.message << PQresultErrorMessage(res);
            LogErr(err, query);
            return false;
            break;
    }
}

bool CheckExistance(PGconn* db,const char* query, PGresult* &res)
{
    ErrorLogging err {};
    res = PQexec(db, query);
    switch (PQresultStatus(res))
    {
        case PGRES_TUPLES_OK:
            if (PQntuples(res) > 0) {
                return true;
            } else {
                return false;
            }
            break;
        case PGRES_FATAL_ERROR:
            err.message << PQresultErrorMessage(res);
            LogErr(err, query);
            return false;
            break;
        default:
            err.message << PQresultErrorMessage(res);
            LogErr(err, query);
            return false;
            break;
    }
}

bool NullifyRow(PGconn* db, File &file, ErrorLogging &err)
{
    char buffer[300];
    sprintf(buffer, "SELECT column_name from information_schema.columns where table_name = 'wiki' and is_nullable = 'YES'");
    PGresult* res = PQexec(db, buffer);
    for (int i = 0; i < PQntuples(res); i++) {
        sprintf(buffer, "update wiki set %s = NULL where path = '%s'", PQgetvalue(res, i, 0), file.path);
        PGresult* RetCommand = PQexec(db, buffer);
        if (PQresultStatus(RetCommand) != PGRES_COMMAND_OK) {
            PQclear(RetCommand);
            err.message << PQresultErrorMessage(RetCommand);
            LogErr(err, buffer);
            return false;
        }
        PQclear(RetCommand);
    }
    PQclear(res);
    return true;
}

// TODO: essa funçãob
void RemoveSpaces(char* str)
{
    for (int i = 0; i<strlen(str); i++) {
        if (str[i] == ' ') {
            str[i] = '_';
        }
    }
}

void UpdateRow(PGconn* db, File &file, ErrorLogging &err)
{
    if (!NullifyRow(db, file, err)) {
        err.message << "Could not nullify the row with file: " << file.path << "\n";
        char message[] = "Tried nullifying the row";
        LogErr(err, message);
        return;
    }
    char buffer[300];
    sprintf(buffer, "UPDATE wiki SET inode = %d, lastwrote = %d where path = '%s'", file.inode, file.time, file.path);
    PGresult* res = PQexec(db, buffer);
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        err.message << PQresultErrorMessage(res);
        LogErr(err, buffer);
        return;
    }
    PQclear(res);
    for (int i = 0; i<file.yaml.nheaders; i++) {
        header_s &yaml = file.yaml.headers[i];
        if (yaml.type == T_NULL) {
            continue;
        } 
        RemoveSpaces(yaml.header);
        sprintf(buffer, "UPDATE wiki SET %s = '%s' where path = '%s'", yaml.header, yaml.data, file.path);
        PGresult *UpdateRes = PQexec(db, buffer);
        if (PQresultStatus(UpdateRes) != PGRES_COMMAND_OK) {
            char secondary_buffer[120];
            sprintf(secondary_buffer, "SELECT column_name FROM information_schema.columns WHERE column_name = '%s' AND table_name = 'wiki'", yaml.header);
            if (!CheckExistance(db, secondary_buffer)) {
                sprintf(secondary_buffer, "ALTER TABLE wiki ADD %s varchar(70)", yaml.header);
                PGresult* alterquery = PQexec(db, secondary_buffer);
                if (PQresultStatus(alterquery) != PGRES_COMMAND_OK) {
                    err.message << PQresultErrorMessage(alterquery);
                    LogErr(err, buffer);
                    PQclear(alterquery);
                    continue;
                }
                PQclear(alterquery);
                PQclear(UpdateRes);
                UpdateRes = PQexec(db, buffer);
                if (PQresultStatus(UpdateRes) != PGRES_COMMAND_OK) {
                    err.message << PQresultErrorMessage(alterquery);
                    LogErr(err, buffer);
                }
                PQclear(UpdateRes);
                continue;
            }
            err.message << PQresultErrorMessage(UpdateRes);
            LogErr(err, buffer);
        }
        PQclear(UpdateRes);
    }
}


void InsertRow(PGconn* db, File &file, ErrorLogging &err)
{
    char buffer[300];
    if (file.title == NULL)
        sprintf(buffer, "INSERT INTO wiki (inode, path, lastwrote) VALUES (%d, '%s', %d)", file.inode, file.path, file.time);
    else
        sprintf(buffer, "INSERT INTO wiki (inode, path, title, lastwrote) VALUES (%d, '%s', '%s', %d)", file.inode, file.path, file.title, file.time);
    PGresult* res = PQexec(db, buffer);
    switch(PQresultStatus(res))
    {
        case PGRES_COMMAND_OK:
            UpdateRow(db, file, err);
            break;
        case PGRES_FATAL_ERROR:
            err.message << PQresultErrorMessage(res);
            LogErr(err, buffer);
            break;
        default:
            err.message << PQresultErrorMessage(res);
            LogErr(err, buffer);
            break;
    }
}



int Update(const char* wiki, bool force)
{
    ErrorLogging err {};
    PGconn* db = PQconnectdb("dbname=wiki");
    std::string command = "find " ;
    command += wiki;
    command += " -name '*.md'";
    FILE* output = popen(command.c_str(), "r");
    char filebuffer[161];
    char buffer[300];
    while (fgets(filebuffer, 161, output) != NULL) {
        filebuffer[strlen(filebuffer)-1] = filebuffer[strlen(filebuffer)];
        File node {filebuffer};
        if (node.yaml.yamlstatus != YAML_SUCCESS) {
            yamlErrorMessage(err, node.yaml.yamlstatus, filebuffer);
            char message[] = "Error while collecting the yaml";
            LogErr(err, message);
            continue;
        }
        sprintf(buffer, "SELECT inode, lastwrote FROM wiki WHERE path = '%s'", node.path);
        PGresult* res;
        if (CheckExistance(db, buffer, res)) {
            if (node.time != atoi(PQgetvalue(res, 0, PQfnumber(res, "lastwrote"))) || force) 
                UpdateRow(db, node, err);
            PQclear(res);
        } else {
            PQclear(res);
            if (node.title != NULL) {
                sprintf(buffer, "select * from wiki where title = '%s'", node.title);
                PGresult* titlequery;
                if (CheckExistance(db, buffer, titlequery)) {
                    sprintf(buffer, "UPDATE wiki SET path = '%s' WHERE title = '%s'", node.path, node.title);
                    PQexec(db, buffer);
                    if (node.time != atoi(PQgetvalue(titlequery, 0, PQfnumber(titlequery, "lastwrote"))) || force) 
                        UpdateRow(db, node, err);
                    PQclear(titlequery);
                    continue; 
                }
            }

            if (node.inode != 0) {
                sprintf(buffer, "select * from wiki where inode = %d", node.inode);
                PGresult* inodequery;
                if (CheckExistance(db, buffer, inodequery)) {
                    sprintf(buffer, "UPDATE wiki SET path = '%s' WHERE inode = %d", node.path, node.inode);
                    PQexec(db, buffer);
                    if (node.time != atoi(PQgetvalue(inodequery, 0, PQfnumber(inodequery, "lastwrote"))) || force) 
                        UpdateRow(db, node, err);
                    PQclear(inodequery);
                    continue;
                }
            }

            InsertRow(db, node, err);
        }
    }
    PQfinish(db);
    return err.returnstatus;
}
