/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/teru-0529/define-table/v3/model/tables"
	"golang.org/x/text/encoding/japanese"
	"golang.org/x/text/transform"
)

// loadCmd represents the load command
var loadCmd = &cobra.Command{
	Use:   "load",
	Short: "Read savedata from yaml and set excel sheet.",
	Long:  "Read savedata from yaml and set excel sheet.",
	RunE: func(cmd *cobra.Command, args []string) error {

		monad, err := tables.New(savedataPath)
		if err != nil {
			return err
		}

		enc := japanese.ShiftJIS.NewEncoder()

		for _, rec := range monad.ToExcel() {
			// sjisに変換
			sjis, _, _ := transform.String(enc, rec)
			fmt.Println(sjis)
		}
		return nil
	},
}

func init() {
}
