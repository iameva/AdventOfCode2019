#include <stdio.h>
#include <stdlib.h>

void read_file() {
    FILE *fptr;
    char filename[14] = "data/day1.txt";
    char buffer[100];
    int pos = 0;
    char ch;
    int total = 0;

    fptr = fopen(filename, "r");
    if(fptr == NULL) {
        printf("couldn't read data file \n");
        exit(0);
    }

    while(ch != EOF){
        ch = fgetc(fptr);
        file_contents[pos] = ch;
        pos++;
    }

    int i;
    for(i=0; i<=pos; i++) {
        printf("%c", file_contents[i]);
    }

    fclose(fptr);
}

void print_buffer(char *buff)

int main(void) {
    read_file();
    return 0;
}

