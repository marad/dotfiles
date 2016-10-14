#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main() {
    setuid(0);
    system("echo 2 > /sys/module/hid_apple/parameters/fnmode");
    return 0;
}
