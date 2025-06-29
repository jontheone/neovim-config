#include <iostream>
#include <filesystem>
#include <sys/stat.h>
#include <cstring>
#include <string>

int main()
{
    namespace fs = std::filesystem;
    const fs::path dir { "/home/jonpute/Documents/wikis/wiki/assuntos" };
    
    for (const auto& entry : fs::directory_iterator(dir)) {
        struct stat File;
        
        if (stat(entry.path(), &File) == 0) {
            std::cout << File.st_ino << std::endl;
        } else {
            std::cout << "Failed to get inode" << std::endl;
        }
    }

    return 0;
}
