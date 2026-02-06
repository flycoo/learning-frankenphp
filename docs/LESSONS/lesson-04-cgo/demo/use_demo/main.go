package main

import (
	"fmt"

	"github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"
)

func main() {
	fmt.Println("use_demo: calling demo-pkg lib ->", lib.Hello("use_demo"))
}
