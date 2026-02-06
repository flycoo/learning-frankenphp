#include "c_code.h"
#include <string.h>

char* c_allocated_string() {
    const char* s = "allocated from separate C file";
    size_t len = strlen(s);
    char* p = (char*)malloc(len + 1);
    if (!p) return NULL;
    memcpy(p, s, len + 1);
    return p;
}

void c_send_kv() {
    kv arr[3];
    arr[0].key = "REMOTE_ADDR"; arr[0].val = "127.0.0.1";
    arr[1].key = "REQUEST_URI"; arr[1].val = "/index.php";
    arr[2].key = "HOST"; arr[2].val = "example.local";

    go_receive_kv(arr, 3);
}
