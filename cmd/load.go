/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// loadCmd represents the load command
var loadCmd = &cobra.Command{
	Use:   "load",
	Short: "Read savedata from yaml and set excel sheet.",
	Long:  "Read savedata from yaml and set excel sheet.",
	RunE: func(cmd *cobra.Command, args []string) error {
		fmt.Println("load called")
		return nil
	},
}

func init() {
}
