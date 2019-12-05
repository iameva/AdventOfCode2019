#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "util.h"

#define STARTING_SIZE 64;

StringSlice read_file_as_lines(char* filename) {
  FILE* fp = fopen(filename, "r");
  if (fp == NULL) {
    perror(filename);
    exit(EXIT_FAILURE);
  }

  StringSlice slice = {0,malloc(sizeof(char*) * 64)};
  int capacity = STARTING_SIZE;
  
  char* line = NULL;
  size_t len = 0;
  char** slice_cursor = slice.items;
  while(getline(&line, &len, fp) != -1) {
    int line_end = strcspn(line, "\r\n");
    line[line_end] = 0; //remove line breaks.
    *slice_cursor = malloc(sizeof(char) * line_end); // alloc enough room for the new string.
    strcpy(*slice_cursor, line);

    slice_cursor++;
    slice.len++;
    if (slice.len == capacity) {
      capacity *= 2;
      char** new_list = malloc(sizeof(char*) * capacity);
      memcpy(new_list, slice.items, sizeof(char*) * slice.len);
      free(slice.items);
      slice.items = new_list;
      slice_cursor = &(new_list[slice.len]);
    }
  }
  return slice;
}

IntSlice read_file_as_ints(char* filename) {
  StringSlice strings = read_file_as_lines(filename);

  IntSlice slice = {strings.len, malloc(sizeof(int) * strings.len)};
  int *cursor = slice.items;
  for (int sIdx = 0; sIdx < strings.len; ++sIdx) {
    (*cursor) = atoi(strings.items[sIdx]);
    cursor++;
  }
  
  return slice;
}


void free_string_slice(StringSlice slice) {
  for(int i= 0 ; i < slice.len; i++) {
    free(slice.items[i]);
  }
  free(slice.items);
}
