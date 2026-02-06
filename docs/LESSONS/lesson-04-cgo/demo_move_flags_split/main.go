package main

import "fmt"

func main() {
    fmt.Println("Demo (split): main in main.go, cgo in cgo_flags.go")
    SendKV()

    s, err := AllocatedString()
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Printf("C allocated: %s\n", s)
}
