/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
)

var excelPath string

// saveCmd represents the save command
var saveCmd = &cobra.Command{
	Use:   "save",
	Short: "Get savedata from excel sheet and write yaml.",
	Long:  "Get savedata from excel sheet and write yaml.",
	RunE: func(cmd *cobra.Command, args []string) error {

		// monad, err := tables.FromExcel(excelPath)
		// if err != nil {
		// 	return err
		// }

		// monad.Version = version
		// monad.Write(savedataPath)

		fmt.Printf("input excel file: [%s]\n", filepath.ToSlash(filepath.Clean(excelPath)))
		fmt.Printf("output yaml file: [%s]\n", filepath.ToSlash(filepath.Clean(savedataPath)))
		fmt.Println("***command[save] completed.")
		return nil
	},
}

func init() {
	saveCmd.Flags().StringVarP(&excelPath, "excel-data", "E", "./define-table.xlsm", "ui-excel path")
}
