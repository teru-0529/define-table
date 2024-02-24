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
	Schema   Schema    `yaml:"schema"`
	Tables   []Table   `yaml:"tables"`
	tMap     map[string]string
}

type Schema struct {
	NameJp string `yaml:"name_jp"`
	NameEn string `yaml:"name_en"`
}

type Table struct {
	NameJp     string     `yaml:"name_jp"`
	NameEn     string     `yaml:"name_en"`
	IsMaster   bool       `yaml:"is_master"`
	Fields     []Field    `yaml:"fields"`
	Constraint Constraint `yaml:"constraint"`
	Indexes    []Index    `yaml:"indexes"`
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

type Index struct {
	Name   string       `yaml:"name"`
	Unique bool         `yaml:"unique"`
	Fields []IndexField `yaml:"fields"`
}

type IndexField struct {
	Field string `yaml:"name"`
	Asc   bool   `yaml:"asc"`
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

	// INFO: テーブル名mapの生成
	ddls.tMap = map[string]string{}
	for _, table := range ddls.Tables {
		ddls.tMap[table.NameJp] = table.NameEn
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

// nameJp → nameEn
func (savedata SaveData) getNameEn(nameJp string) string {
	nameEn, ok := savedata.tMap[nameJp]
	if !ok {
		return "N/A"
	}
	return nameEn
}
