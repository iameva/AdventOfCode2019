#include <stdio.h>
#include <stdlib.h>


int calc_fuel_rqrt(int mass) {
    return (mass/3)-2;
}

int calc_total_fuel() {
    FILE *fptr;
    char filename[14] = "data/day1.txt";
    char buffer[100];
    int total = 0;

    fptr = fopen(filename, "r");
    if(fptr == NULL) {
        printf("couldn't read data file \n");
        exit(0);
    }

    /*struggled with some of the input. reading the file via fgetc() is MUCH? more difficult than using fgets */
    while(fgets(buffer, 100, fptr) != NULL){
        int value = atoi(buffer);
        int fuel_rqrd = calc_fuel_rqrt(value);
        total+=fuel_rqrd;
    }
    fclose(fptr);
    return total;

}

int main(void) {
    int total = calc_total_fuel();
    printf("total fuel required for part 1 is: %i\n", total);
    return 0;
}

