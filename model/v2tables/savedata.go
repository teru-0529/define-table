package v2tables

import (
	"fmt"
	"os"

	"github.com/teru-0529/define-table/v3/model/tables"
	"gopkg.in/yaml.v3"
)

type Data struct {
	Table Table `yaml:"ddl"`
}

type Table struct {
	TableNameJp string           `yaml:"table_name_jp"`
	TableNameEn string           `yaml:"table_name_en"`
	IsMaster    bool             `yaml:"is_master"`
	Fields      []Field          `yaml:"fielsd"`
	PrimaryKey  []string         `yaml:"primary_key"`
	Unique      UniqueConstraint `yaml:"unique"`
}

type Field struct {
	Name    string  `yaml:"name"`
	NotNull string  `yaml:"not_null"`
	Default *string `yaml:"default"`
}

type UniqueConstraint struct {
	Exists      bool         `yaml:"exists"`
	Constraints []Constraint `yaml:"constraints"`
}

type Constraint struct {
	Constraint []string `yaml:"constraint"`
}

func New(path string) ([]Data, error) {
	// INFO: read
	file, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("cannot read file: %s", err.Error())
	}

	// INFO: unmarchal
	var ddls []Data
	err = yaml.Unmarshal([]byte(file), &ddls)
	if err != nil {
		return nil, err
	}

	return ddls, nil
}

func (data *Data) Convert() tables.Table {
	table := tables.Table{}
	table.NameJp = data.Table.TableNameJp
	table.NameEn = data.Table.TableNameEn
	table.IsMaster = data.Table.IsMaster
	for _, field := range data.Table.Fields {
		table.Fields = append(table.Fields, field.Convert())
	}
	table.Constraint.PraimaryKey = data.Table.PrimaryKey
	for i, fields := range data.Table.Unique.Constraints {
		table.Constraint.Uniques = append(table.Constraint.Uniques, tables.Fields{
			Name:   fmt.Sprintf("%s_unique_%d", table.NameEn, (i + 1)),
			Fields: fields.Constraint,
		})
	}
	return table
}

func (field *Field) Convert() tables.Field {
	return tables.Field{
		Name:     field.Name,
		Nullable: field.NotNull != "1",
		Default:  field.Default,
	}
}
