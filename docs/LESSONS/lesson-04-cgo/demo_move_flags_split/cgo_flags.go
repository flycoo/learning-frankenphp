package main

/*
#cgo CFLAGS: -I.
#include "c_code.h"
*/
import "C"

import (
    "fmt"
    "unsafe"
)

//export go_receive_kv
func go_receive_kv(arr *C.kv, n C.int) {
    length := int(n)
    slice := (*[1 << 28]C.kv)(unsafe.Pointer(arr))[:length:length]
    for i := 0; i < length; i++ {
        key := C.GoString(slice[i].key)
        val := C.GoString(slice[i].val)
        fmt.Printf("[Go callback] %s = %s\n", key, val)
    }
}

// SendKV calls the C function that invokes the Go callback.
func SendKV() {
    C.c_send_kv()
}

// AllocatedString returns a Go string from a C-allocated buffer.
func AllocatedString() (string, error) {
    cstr := C.c_allocated_string()
    if cstr == nil {
        return "", fmt.Errorf("C allocation failed")
    }
    goStr := C.GoString(cstr)
    C.free(unsafe.Pointer(cstr))
    return goStr, nil
}
