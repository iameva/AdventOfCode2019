#include <stdio.h>
#include <stdlib.h>

FILE* read_input() {
    char filename[] = "data/day2.txt";
    return fopen(filename, "r");
}
int * to_int_array(char *arr[]) {
    int val[5];
    return val;
}
int main(void) {
    FILE *fptr = read_input();
    char buffer[100];

    while(fgets(buffer, 100, fptr) != NULL){
        printf("%s", buffer);
    }
    fclose(fptr);
    return 0;
}
