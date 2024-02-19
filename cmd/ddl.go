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

var ddlDir string
var saveHistry bool

// ddlCmd represents the ddl command
var ddlCmd = &cobra.Command{
	Use:   "ddl",
	Short: "output ddl from savedata.yaml",
	Long:  "output ddl from savedata.yaml",
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

		// INFO: ddlの生成
		fileCount, err := monad.CreateDdl(ddlDir, *elements, saveHistry)
		if err != nil {
			return err
		}

		fmt.Printf("%d ddl files created", fileCount)
		if saveHistry {
			fmt.Println("(added history insert function.)")
		}
		fmt.Println("\n***command[ddl] completed.")
		return nil
	},
}

func init() {
	ddlCmd.Flags().StringVarP(&ddlDir, "ddl-dir", "O", "./out", "output directory.")
	ddlCmd.Flags().BoolVarP(&saveHistry, "save-history", "H", false, "create history insert function by option flag.")
}
