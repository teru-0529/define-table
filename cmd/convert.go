/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"path/filepath"

	"github.com/spf13/cobra"
	"github.com/teru-0529/define-table/v3/model/tables"
	"github.com/teru-0529/define-table/v3/model/v2tables"
)

var v2Savedata string
var v3Savedata string

// convertCmd represents the convert command
var convertCmd = &cobra.Command{
	Use:   "convert",
	Short: "savedata convert from v2.",
	Long:  "savedata convert from v2.",
	RunE: func(cmd *cobra.Command, args []string) error {
		v2Monad, err := v2tables.New(v2Savedata)
		if err != nil {
			return err
		}

		v3Monad := tables.SaveData{}
		v3Monad.Version = "convert"
		for _, table := range v2Monad {
			v3Monad.Tables = append(v3Monad.Tables, table.Convert())
		}

		err = v3Monad.Write(v3Savedata)
		if err != nil {
			return err
		}

		fmt.Printf("convert from v2 savedata file: [%s]\n", filepath.ToSlash(v2Savedata))
		fmt.Printf("convert to v3 savedata file: [%s]\n", filepath.ToSlash(v3Savedata))
		fmt.Println("***command[convert] completed.")
		return nil
	},
}

func init() {
	convertCmd.Flags().StringVarP(&v2Savedata, "v2-data", "", "", "input old v2 format savedata.")
	convertCmd.Flags().StringVarP(&v3Savedata, "v3-data", "", "", "output new v3 format savedata.")

	convertCmd.MarkFlagRequired("v2-data")
	convertCmd.MarkFlagRequired("v3-data")
}
