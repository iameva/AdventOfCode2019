#include <stdio.h>
#include "util.h"

int main() {
  StringSlice strings = read_file_as_lines("test-large.txt");
  for (int i = 0; i < strings.len; i++) {
    printf("%s\n", strings.items[i]);
  }

  IntSlice nums = read_file_as_ints("test-larg.txt");
  int sum = 0;
  for(int i = 0; i < nums.len; i++) {
    sum += nums.items[i];
  }
  printf("sum: %d\n", sum);
}
