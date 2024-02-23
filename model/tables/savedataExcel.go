package tables

import (
	"fmt"

	"github.com/samber/lo"
	"github.com/xuri/excelize/v2"
)

const SHT_INDEX = "一覧"
const SHT_TEMPLATE = "テンプレート"

func FromExcel(fileName string) (*SaveData, error) {

	savedata := SaveData{}

	// INFO: ファイルの読み込み
	f, err := excelize.OpenFile(fileName)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	savedata.Schema.NameJp = getValue(f, SHT_TEMPLATE, 1, 2)
	savedata.Schema.NameEn = getValue(f, SHT_TEMPLATE, 1, 3)

	for i := 2; i < 102; i++ {
		tableJp := getValue(f, SHT_INDEX, i, 3)
		if tableJp != "" {
			table := createTable(f, tableJp)
			savedata.Tables = append(savedata.Tables, table)
		}
	}
	return &savedata, nil
}

func createTable(f *excelize.File, sht string) Table {
	tableEn := getValue(f, sht, 2, 3)
	isMaster := getValue(f, sht, 2, 6) == "○"
	table := Table{NameJp: sht, NameEn: tableEn, IsMaster: isMaster}

	// フィールド
	for i := 6; i < 106; i++ {
		fieldName := getValue(f, sht, i, 2)
		if fieldName != "" {
			nullable := getValue(f, sht, i, 5) == ""
			def := getValue(f, sht, i, 6)
			defPointer := lo.Ternary(def == "", nil, &def)
			field := Field{Name: fieldName, Nullable: nullable, Default: defPointer}
			table.Fields = append(table.Fields, field)
		}
	}

	// PK
	for i := 12; i < 17; i++ {
		pkField := getValue(f, sht, 8, i)
		if pkField != "" {
			table.Constraint.PraimaryKey = append(table.Constraint.PraimaryKey, pkField)
		}
	}

	// ユニーク制約
	no := 0
	for i := 13; i < 23; i++ {
		concat := getValue(f, sht, i, 18)
		if concat != "" {
			no += 1
			unique := Fields{Name: fmt.Sprintf("%s_unique_%d", tableEn, no)}
			for j := 12; j < 17; j++ {
				field := getValue(f, sht, i, j)
				if field != "" {
					unique.Fields = append(unique.Fields, field)
				}
			}
			table.Constraint.Uniques = append(table.Constraint.Uniques, unique)
		}
	}

	// FK制約
	no = 0
	for _, i := range []int{27, 32, 37, 42, 47} {
		concat := getValue(f, sht, i, 19)
		if concat != "" {

			no += 1
			deleteOption := getValue(f, sht, i-1, 14)
			updateOption := getValue(f, sht, i-1, 16)
			foreignKey := ForeignKey{
				Name:         fmt.Sprintf("%s_foreignKey_%d", tableEn, no),
				RefTable:     getValue(f, sht, i-1, 12),
				DeleteOption: lo.Ternary(deleteOption == "", nil, &deleteOption),
				UpdateOption: lo.Ternary(updateOption == "", nil, &updateOption),
			}
			for j := 12; j < 17; j++ {
				field := getValue(f, sht, i+1, j)
				if field != "" {
					fkField := ForeignField{
						ThisField: field,
						RefField:  getValue(f, sht, i+2, j),
					}
					foreignKey.Fields = append(foreignKey.Fields, fkField)
				}
			}
			table.Constraint.ForeignKeys = append(table.Constraint.ForeignKeys, foreignKey)
		}
	}

	// インデックス
	no = 0
	for _, i := range []int{55, 57, 59, 61, 63} {
		concat := getValue(f, sht, i, 18)
		if concat != "" {
			no += 1
			index := Index{
				Name:   fmt.Sprintf("idx_%s_%d", tableEn, no),
				Unique: getValue(f, sht, i+1, 11) == "UNIQUE",
			}
			for j := 12; j < 17; j++ {
				field := getValue(f, sht, i, j)
				if field != "" {
					field := IndexField{Field: field, Asc: getValue(f, sht, i+1, j) != "DESC"}
					index.Fields = append(index.Fields, field)
				}
			}
			table.Indexes = append(table.Indexes, index)
		}
	}

	return table
}

func getValue(f *excelize.File, sht string, row int, col int) string {
	address, _ := excelize.CoordinatesToCellName(col, row)
	cell, _ := f.GetCellValue(sht, address)
	return cell
}
