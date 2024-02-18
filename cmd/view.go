/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
)

var outDir string

// viewCmd represents the view command
var viewCmd = &cobra.Command{
	Use:   "view",
	Short: "Generate md table data for sphinx from savedata.",
	Long:  "Generate md table data for sphinx from savedata.",
	RunE: func(cmd *cobra.Command, args []string) error {
		outfile := "dummy.md"

		fmt.Printf("input yaml file: [%s]\n", filepath.ToSlash(filepath.Clean(savedataPath)))
		fmt.Printf("input elements file: [%s]\n", filepath.ToSlash(filepath.Clean(elementsPath)))
		fmt.Printf("output md file: [%s]\n", filepath.ToSlash(outfile))
		fmt.Println("***command[view] completed.")
		return nil
	},
}

func init() {
	viewCmd.Flags().StringVarP(&outDir, "out-dir", "O", "./view", "output directory.")
}
