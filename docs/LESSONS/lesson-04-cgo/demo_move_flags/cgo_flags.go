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

func main() {
	fmt.Println("Demo (cgo flags in cgo_flags.go):")
	C.c_send_kv()

	cstr := C.c_allocated_string()
	if cstr == nil {
		fmt.Println("C allocation failed")
		return
	}
	goStr := C.GoString(cstr)
	fmt.Printf("C allocated: %s\n", goStr)
	C.free(unsafe.Pointer(cstr))
}
