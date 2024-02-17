package tables

import (
	"fmt"
	"os"
	"time"

	"github.com/teru-0529/define-monad/v3/store"
	"gopkg.in/yaml.v3"
)

type SaveData struct {
	DataType string    `yaml:"data_type"`
	Version  string    `yaml:"version"`
	CreateAt time.Time `yaml:"create_at"`
	Tables   []Table   `yaml:"tables"`
}

type Table struct {
	NameJp     string     `yaml:"name_jp"`
	NameEn     string     `yaml:"name_en"`
	IsMaster   bool       `yaml:"is_master"`
	Fields     []Field    `yaml:"fields"`
	Constraint Constraint `yaml:"constraint"`
	Indexes    []Fields   `yaml:"indexes"`
}

type Field struct {
	Name     string  `yaml:"name"`
	Nullable bool    `yaml:"nullable"`
	Default  *string `yaml:"default"`
}

type Constraint struct {
	PraimaryKey []string     `yaml:"primary_key"`
	Uniques     []Fields     `yaml:"uniques"`
	ForeignKeys []ForeignKey `yaml:"foreign_keys"`
}

type Fields struct {
	Name   string   `yaml:"name"`
	Fields []string `yaml:"fields"`
}

type ForeignKey struct {
	Name         string         `yaml:"name"`
	RefTable     string         `yaml:"reference_table"`
	DeleteOption *string        `yaml:"delete_option"`
	UpdateOption *string        `yaml:"update_option"`
	Fields       []ForeignField `yaml:"fields"`
}

type ForeignField struct {
	ThisField string `yaml:"this"`
	RefField  string `yaml:"ref"`
}

func New(path string) (*SaveData, error) {
	// INFO: read
	file, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("cannot read file: %s", err.Error())
	}

	// INFO: unmarchal
	var ddls SaveData
	err = yaml.Unmarshal([]byte(file), &ddls)
	if err != nil {
		return nil, err
	}

	return &ddls, nil
}

// yamlファイルの書き込み
func (savedata *SaveData) Write(path string) error {

	savedata.DataType = "define_tables"

	// INFO: taimusutampの取得
	layout := time.RFC3339
	t, _ := time.Parse(layout, time.Now().Format(layout))
	savedata.CreateAt = t

	// INFO: Encoderの取得
	encoder, cleanup, err := store.NewYamlEncorder(path)
	if err != nil {
		return err
	}
	defer cleanup()
	err = encoder.Encode(&savedata)
	if err != nil {
		return err
	}

	return nil
}
