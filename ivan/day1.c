#include <stdio.h>
#include <stdlib.h>


int calc_fuel_rqrt(int mass) {
    return (mass/3)-2;
}

int calc_total_fuel(FILE *fptr) {
    char buffer[100];
    int total = 0;

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
    return total;
}

int calc_fuel_iterative(FILE *fptr) {
    char buffer[100];
    int total = 0;

    if(fptr == NULL) {
        printf("couldn't read data file \n");
        exit(0);
    }
    /*struggled with some of the input. reading the file via fgetc() is MUCH? more difficult than using fgets */
    while(fgets(buffer, 100, fptr) != NULL){
        int value = atoi(buffer);
        int local = 0;
        int fuel_rqrd = calc_fuel_rqrt(value);
        while(fuel_rqrd > 0) {
            local+=fuel_rqrd;
            fuel_rqrd=calc_fuel_rqrt(fuel_rqrd);
        }
        total+=local;
    }
    return total;
}

int main(void) {
    FILE *fptr;

    char filename[] = "data/day1.txt";
    fptr = fopen(filename, "r");

    int fuel_non_recurs = calc_total_fuel(fptr);
    fseek(fptr, 0, 0);

    int fuel_recurs = calc_fuel_iterative(fptr);
    fclose(fptr);

    printf("total fuel required for part 1 is: %i\n", fuel_non_recurs);
    printf("total fuel required for part 2 is: %i\n", fuel_recurs);
    return 0;
}

