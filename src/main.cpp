#include <stdlib.h>

int main()
{
    for (int i = 0; i < 1000; i++) {
        system("ls > /dev/null");
    }
    return 0;
}
