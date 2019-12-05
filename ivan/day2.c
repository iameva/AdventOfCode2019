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

void replace_start_state(int *state, int noun, int verb) {
    state[1] = noun;
    state[2] = verb;
}

void perform_pt1_algorithmz(int *data, int len) {
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

void copy_int_array(int *to_full, int *src, int len) {
    int i = 0;
    while(i<=len){
      to_full[i] = src[i];
      i++;
    }
}

int main(void) {
    FILE *fptr = read_input();
    char buffer[1000];
    int parsed_int_buffer[1000] = {};
    int len;

    while(fgets(buffer, 1000, fptr) != NULL){
        len = fill_int_array(buffer, parsed_int_buffer);
    }

    int ints[1000];
    copy_int_array(ints, parsed_int_buffer, 1000);

    replace_start_state(ints, 12, 2);
    //now we have the starting int array, perform ze algorithmz
    perform_pt1_algorithmz(ints, len);
    printf("our final result for part 1 is: %i\n", ints[0]);

    int i;
    int j;
    int MOON_LANDING = 19690720;
    for(i=0; i<=99; i++){
        for(j=0; j<=99; j++){
            copy_int_array(ints, parsed_int_buffer, 1000);
            replace_start_state(ints, i, j);
            perform_pt1_algorithmz(ints, len);
            if(ints[0] == MOON_LANDING){
                printf("result found! noun is %i and verb is %i\n", i, j);
                printf("answer for part2 is: %i\n", (100*i)+j);
                break;
            }
        }
        if(ints[0] == MOON_LANDING) {
            break;
        }
    }

    fclose(fptr);
    return 0;
}
