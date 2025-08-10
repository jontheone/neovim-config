#include <iostream>
#include "yamlread.h"
#include "ErrorLogging.h"
#include "update.h"

int main()
{
    const char path[] = "/home/jonputer/Documents/wikis/wiki";
    char filepath[] = "/home/jonputer/Documents/wikis/wiki/seila.md";
    File node {filepath, path};
    return 0;
}
