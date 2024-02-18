/*
Copyright © 2024 Teruaki Sato <andrea.pirlo.0529@gmail.com>
*/
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	version     string
	releaseDate string
)
var savedataPath string
var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "define-table",
	Short: "backend service for monad manage tool.",
	Long:  "backend service for monad manage tool.",
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute(ver string, date string) {
	version = ver
	releaseDate = date

	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// サブコマンドの追加
	rootCmd.AddCommand(versionCmd)
	rootCmd.AddCommand(saveCmd)
	rootCmd.AddCommand(loadCmd)
	rootCmd.AddCommand(loadElementsCmd)
	rootCmd.AddCommand(convertCmd)

	// TODO:cofigファイルの定義(viper)は未整備
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.define-monad.yaml)")
	// INFO:フラグ値を変数にBind
	rootCmd.PersistentFlags().StringVarP(&savedataPath, "save-data", "D", "./save_data.yaml", "save-data path")
}

// initConfig reads in config file and ENV variables if set.
// TODO:cofigファイルの定義(viper)は未整備
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		// Search config in home directory with name ".define-table" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigType("yaml")
		viper.SetConfigName(".define-table")
	}

	viper.AutomaticEnv() // read in environment variables that match

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}
