#include <iostream>
#include "yamlread.h"
#include "ErrorLogging.h"
#include "update.h"

int main()
{
    char path[] = "/home/jonputer/Documents/wikis/wiki";
    int ret = Update(path);
    switch(ret)
    {
        case S_SUCCESS:
            std::cout << "success" << std::endl;
            break;
        case S_FAILURE:
            std::cout << "failure" << std::endl;
            break;
        case S_WARNINGS:
            std::cout << "warnings" << std::endl;
            break;
        default:
            break;
    }

}
