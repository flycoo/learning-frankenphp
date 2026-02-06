package demopkgimport
package main

import (
    "fmt"
    "github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"
)

func main() {
    fmt.Println("demo-pkg-import: calling demo-pkg lib ->", lib.Hello("demo-pkg-import"))
}
