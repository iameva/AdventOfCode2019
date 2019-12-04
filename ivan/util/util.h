#ifndef UTIL_H
#define UTIL_H

typedef struct StringSlice {
  int len;
  char** items;
} StringSlice;

typedef struct IntSlice {
  int len;
  int* items;
} IntSlice;

StringSlice read_file_as_lines(char* filename);
void free_string_slice(StringSlice slice);
  
IntSlice read_file_as_ints(char* filename);
#endif
