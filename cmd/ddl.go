/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
)

var ddlDir string
var saveHistry bool
var createrLength int16

// ddlCmd represents the ddl command
var ddlCmd = &cobra.Command{
	Use:   "ddl",
	Short: "output ddl from savedata.yaml",
	Long:  "output ddl from savedata.yaml",
	RunE: func(cmd *cobra.Command, args []string) error {
		fileCount := 3

		fmt.Printf("input yaml file: [%s]\n", filepath.ToSlash(filepath.Clean(savedataPath)))
		fmt.Printf("input elements file: [%s]\n", filepath.ToSlash(filepath.Clean(elementsPath)))
		fmt.Printf("output ddl dir: [%s]\n", filepath.ToSlash(ddlDir))
		fmt.Printf("%d ddl files created", fileCount)
		if saveHistry {
			fmt.Printf("ddl added history insert function")
		}
		fmt.Println("***command[ddl] completed.")
		return nil
	},
}

func init() {
	ddlCmd.Flags().StringVarP(&ddlDir, "ddl-dir", "O", "./ddl", "output directory.")
	ddlCmd.Flags().BoolVarP(&saveHistry, "save-history", "H", false, "create history insert function by option flag.")
	ddlCmd.Flags().Int16VarP(&createrLength, "creater-id-length", "L", 30, "createBy/updateBy field lemgth.")
}
