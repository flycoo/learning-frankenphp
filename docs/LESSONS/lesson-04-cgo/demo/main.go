package main

/*
#include <stdlib.h>
#include <stdio.h>

// key/value pair structure used to batch-register variables
typedef struct {
	const char* key;
	const char* val;
} kv;

// declare Go callback that will receive the array of kv pairs
extern void go_receive_kv(kv* arr, int n);

// C side: build a small array of server-like variables and call the Go callback
static void c_send_kv() {
	kv arr[3];
	arr[0].key = "REMOTE_ADDR"; arr[0].val = "127.0.0.1";
	arr[1].key = "REQUEST_URI"; arr[1].val = "/index.php";
	arr[2].key = "HOST"; arr[2].val = "example.local";

	go_receive_kv(arr, 3);
}
*/
import "C"

import (
	"fmt"
	"unsafe"
)

//export go_receive_kv
func go_receive_kv(arr *C.kv, n C.int) {
	length := int(n)
	// create a Go slice header backed by the C array
	slice := (*[1 << 28]C.kv)(unsafe.Pointer(arr))[:length:length]
	for i := 0; i < length; i++ {
		key := C.GoString(slice[i].key)
		val := C.GoString(slice[i].val)
		fmt.Printf("[Go callback] %s = %s\n", key, val)
	}
}

func main() {
	fmt.Println("Demo: C -> Go bulk registration (kv array)")
	C.c_send_kv()
}
