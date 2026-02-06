#ifndef C_CODE_H
#define C_CODE_H

#include <stdlib.h>

typedef struct {
    const char* key;
    const char* val;
} kv;

// Go callback prototype (implemented in Go)
extern void go_receive_kv(kv* arr, int n);

// Functions implemented in the C source file
char* c_allocated_string();
void c_send_kv();

#endif // C_CODE_H
