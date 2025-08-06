#ifndef ERRORLOGGIN_H
#define ERRORLOGGIN_H
#include <stdio.h>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <iostream>


enum StatusLevels {
    S_FAILURE = -1,
    S_SUCCESS,
    S_WARNINGS ,
};


struct ErrorLogging {
    int returnstatus {S_SUCCESS};
    FILE* errlogs {NULL};
    std::stringstream message;

    ErrorLogging() {
        int ret = system("[ -f $HOME/.local/share/nvim/postgreslogs ];"); 
        std::string HOME = getenv("HOME");
        HOME += "/.local/share/nvim/postgreslogs";
        if (ret != 0) {
            system(HOME.c_str());
        }
        errlogs = fopen(HOME.c_str(), "a");
    }

    void clearMessage() {
        message.str("");
    }

    ~ErrorLogging() {
        fclose(errlogs);
    }
};

void yamlErrorMessage(ErrorLogging &err, int code);
void yamlErrorMessage(ErrorLogging &err, int code, char* filepath);
void LogErr(ErrorLogging &err, const char* action) ;
void LogErr(ErrorLogging &err, const char* action, int status);

#endif
