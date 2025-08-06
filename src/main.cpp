#include <iostream>
#include "update.h"
#include "ErrorLogging.h"

int main()
{
    char wiki[] = "/home/jonputer/.config/nvim/teste";
    switch(Update(wiki))
    {
        case S_SUCCESS:
            std::cout << "Update was successful" << std::endl;
            break;
        case S_WARNINGS:
            std::cout << "Update successful with warnings" << std::endl;
            break;
        case S_FAILURE:
            std::cout << "Update successful with warnings" << std::endl;
            break;
    }
    return 0;
}
