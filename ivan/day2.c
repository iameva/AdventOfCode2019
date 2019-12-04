#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

FILE* read_input() {
    char filename[] = "data/day2.txt";
    return fopen(filename, "r");
}

void fill_int_array(char *arr, int *result) {
    int i = 0;
    int j = 0;
    int k = 0;
    char buf[20];
    while(arr[i]!=NULL){
        if(isdigit(arr[i])){
            buf[j] = (int)arr[i];
            j++;
        }
        else {
          int to_int = atoi(buf);
          result[k] = to_int;
          while(j>=0) {
            buf[j] = NULL;
            j--;
          }

          j=0;
          k++;
        }
        i++;
    }
}

int main(void) {
    FILE *fptr = read_input();
    char buffer[1000];

    while(fgets(buffer, 1000, fptr) != NULL){
        int result_buffer[1000];
        fill_int_array(buffer, result_buffer);
        int i = 0;
        printf("%s", result_buffer);
//        while(results[i]!=NULL) {
//            printf("%i", results[i]);
//        }
    }
    fclose(fptr);
    return 0;
}
