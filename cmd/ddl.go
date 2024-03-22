/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
	"github.com/teru-0529/define-monad/v3/model/elements"
	"github.com/teru-0529/define-table/v3/model/tables"
)

const ENUM_FILE_NAME = "01_types.sql"

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
		elements_, err := tables.NewElements(elementsPath)
		if err != nil {
			return err
		}

		fmt.Printf("input yaml file: [%s]\n", filepath.ToSlash(filepath.Clean(savedataPath)))
		fmt.Printf("input elements file: [%s]\n", filepath.ToSlash(filepath.Clean(elementsPath)))

		// INFO: types-ddlの出力
		eMonad, err := elements.New(elementsPath)
		if err != nil {
			return err
		}
		path := filepath.Join(ddlDir, ENUM_FILE_NAME)
		eMonad.WriteTypesDdl(path, monad.Schema.NameEn)
		fmt.Printf("output ddl file: [%s]\n", filepath.ToSlash(path))

		// INFO: ddlの生成
		fileCount, err := monad.CreateDdl(ddlDir, *elements_, saveHistry)
		if err != nil {
			return err
		}

		fmt.Printf("%d ddl files created", fileCount+1)
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
