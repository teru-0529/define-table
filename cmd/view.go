/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
	"github.com/teru-0529/define-table/v3/model/tables"
)

var outDir string

// viewCmd represents the view command
var viewCmd = &cobra.Command{
	Use:   "view",
	Short: "Generate md table data for sphinx from savedata.",
	Long:  "Generate md table data for sphinx from savedata.",
	RunE: func(cmd *cobra.Command, args []string) error {

		// INFO: save-dataの読込み
		monad, err := tables.New(savedataPath)
		if err != nil {
			return err
		}

		// INFO: save-data(elements)の読込み
		elements, err := tables.NewElements(elementsPath)
		if err != nil {
			return err
		}

		fmt.Printf("input yaml file: [%s]\n", filepath.ToSlash(filepath.Clean(savedataPath)))
		fmt.Printf("input elements file: [%s]\n", filepath.ToSlash(filepath.Clean(elementsPath)))

		// INFO: mdの生成
		err = monad.CreateMd(outDir, *elements)
		if err != nil {
			return err
		}

		fmt.Println("***command[view] completed.")
		return nil
	},
}

func init() {
	viewCmd.Flags().StringVarP(&outDir, "out-dir", "O", "./view", "output directory.")
}
