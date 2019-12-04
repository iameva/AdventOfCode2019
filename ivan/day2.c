#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

FILE* read_input() {
    char filename[] = "data/day2.txt";
    return fopen(filename, "r");
}

int fill_int_array(char *arr, int *result) {
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
    return k;
}

void replace_start_state(int *state) {
    state[1] = 12;
    state[2] = 2;
}

void perform_algorithmz(int *data, int len) {
    int opcode_offset = 4;
    int i;

    for(i=0; i<len; i+=opcode_offset) {
        int opcode = data[i];
        if(opcode==99){
            return;
        }
        int first_pos = data[i+1];
        int second_pos = data[i+2];
        int first = data[first_pos];
        int second = data[second_pos];
        int pos = data[i+3];
        int res;
        if(opcode==1){
            res = first + second;
        }
        else{
            res = first * second;

        }
        data[pos] = res;
    }
    return;
}

int main(void) {
    FILE *fptr = read_input();
    char buffer[1000];
    int parsed_int_buffer[1000] = {};
    int len;

    while(fgets(buffer, 1000, fptr) != NULL){
        len = fill_int_array(buffer, parsed_int_buffer);
    }
    replace_start_state(parsed_int_buffer);

    //now we have the starting int array, perform ze algorithmz
    perform_algorithmz(parsed_int_buffer, len);
     printf("our final result is: %i\n", parsed_int_buffer[0]);
    fclose(fptr);
    return 0;
}
