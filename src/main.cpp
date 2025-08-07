#include <iostream>
#include "yamlread.h"
#include "ErrorLogging.h"

int main()
{
    char yamlstring[] = "links: seila\ntags: [sim, talvez]\ntopic: music\n";
    char path[] = "/home/jonputer/seila.md";
    yaml_s yaml = collectyamlstring(yamlstring);
    for (int i = 0; i<yaml.nheaders; i++) {
        if (yaml.headers[i].type != T_NULL)
            std::cout << yaml.headers[i].header << ": " << yaml.headers[i].data << std::endl;
        else
            std::cout << "NULLED: " << yaml.headers[i].header << std::endl;
    }
    return 0;
}
