package lib

// Hello returns a demo greeting from the reusable package.
func Hello(name string) string {
	if name == "" {
		name = "world"
	}
	return "Hello, " + name + " from demo-pkg"
}
