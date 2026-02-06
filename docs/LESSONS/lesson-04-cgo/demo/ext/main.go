package main

/*
#include <stdlib.h>
#include <string.h>

// Allocate a new C string and return it to Go. Caller must free.
char* c_allocated_string() {
    const char* s = "allocated from C";
    size_t len = strlen(s);
    char* p = (char*)malloc(len + 1);
    if (!p) return NULL;
    memcpy(p, s, len + 1);
    return p;
}
*/
import "C"

import (
    "fmt"
    "unsafe"
)

func main() {
    cstr := C.c_allocated_string()
    if cstr == nil {
        fmt.Println("C allocation failed")
        return
    }
    goStr := C.GoString(cstr)
    fmt.Printf("C allocated: %s\n", goStr)
    C.free(unsafe.Pointer(cstr))
}
