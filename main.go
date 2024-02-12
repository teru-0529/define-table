/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package main

import "github.com/teru-0529/define-table/v3/cmd"

var (
	version = "dev"
	date    = "unknown"
)

func main() {
	cmd.Execute(version, date)
}
