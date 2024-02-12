/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/teru-0529/define-monad/v3/model/elements"
	"golang.org/x/text/encoding/japanese"
	"golang.org/x/text/transform"
)

var elementsFile string

// loadElementsCmd represents the loadElements command
var loadElementsCmd = &cobra.Command{
	Use:   "loadElements",
	Short: "input data from define-elements.",
	Long:  "input data from define-elements.",
	RunE: func(cmd *cobra.Command, args []string) error {

		// INFO: save-dataの読込み
		monad, err := elements.New(elementsFile)
		if err != nil {
			return err
		}

		enc := japanese.ShiftJIS.NewEncoder()

		for _, rec := range monad.TotableElements() {
			// sjisに変換
			sjis, _, _ := transform.String(enc, rec)
			fmt.Println(sjis)
		}
		return nil
	},
}

func init() {
	loadElementsCmd.Flags().StringVarP(&elementsFile, "elements-file", "I", "", "input file name.")

	loadElementsCmd.MarkFlagRequired("elements-file")
}
