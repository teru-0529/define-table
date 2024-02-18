package tables

import (
	"fmt"

	"github.com/samber/lo"
	"github.com/xuri/excelize/v2"
)

const SHT_INDEX = "一覧"

func FromExcel(fileName string) (*SaveData, error) {

	savedata := SaveData{}

	// INFO: ファイルの読み込み
	f, err := excelize.OpenFile(fileName)
	if err != nil {
		return nil, err
	}
	defer f.Close()

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

	for i := 12; i < 17; i++ {
		pkField := getValue(f, sht, 8, i)
		if pkField != "" {
			table.Constraint.PraimaryKey = append(table.Constraint.PraimaryKey, pkField)
		}
	}

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

	return table
}

// cell, _ := f.GetCellValue(SHT_INDEX, "C3")
// fmt.Println(cell)

// // INFO: [項目]シートデータ取得
// rows, err := f.GetRows(SHT_ELEMENTS)
// if err != nil {
// 	return nil, err
// }
// for _, row := range rows[1:] { // ヘッダー行は読み飛ばす
// 	if row[0] == "" {
// 		// 空行は読み飛ばす
// 		continue
// 	}
// 	element := Element{}
// 	element.NameJp = row[0]
// 	element.NameEn = row[1]
// 	element.Domain = Dom(row[3])
// 	if row[4] != "" {
// 		element.RegEx = &row[4]
// 	}
// 	if row[5] != "" {
// 		str := strings.Replace(row[5], ",", "", -1)
// 		num, _ := strconv.Atoi(str)
// 		element.MinDigits = &num
// 	}
// 	if row[6] != "" {
// 		str := strings.Replace(row[6], ",", "", -1)
// 		num, _ := strconv.Atoi(str)
// 		element.MaxDigits = &num
// 	}
// 	if row[7] != "" {
// 		str := strings.Replace(row[7], ",", "", -1)
// 		num, _ := strconv.Atoi(str)
// 		element.MinValue = &num
// 	}
// 	if row[8] != "" {
// 		str := strings.Replace(row[8], ",", "", -1)
// 		num, _ := strconv.Atoi(str)
// 		element.MaxValue = &num
// 	}
// 	element.Example = row[9]
// 	element.Description = row[10]

// 	savedata.Elements = append(savedata.Elements, element)
// }

// // INFO: [別名]シートデータ取得
// rows, err = f.GetRows(SHT_DERIVE_ELEMENTS)
// if err != nil {
// 	return nil, err
// }
// for _, row := range rows[1:] { // ヘッダー行は読み飛ばす
// 	if row[0] == "" {
// 		// 空行は読み飛ばす
// 		continue
// 	}
// 	element := DeliveElement{}
// 	element.Origin = row[0]
// 	element.NameJp = row[1]
// 	element.NameEn = row[2]
// 	element.Description = row[4]

// 	savedata.DeliveElements = append(savedata.DeliveElements, element)
// }

// // INFO: [区分値]シートデータ取得
// rows, err = f.GetRows(SHT_SEGMENTS)
// if err != nil {
// 	return nil, err
// }
// for _, row := range rows[1:] { // ヘッダー行は読み飛ばす
// 	if row[0] == "" {
// 		// 空行は読み飛ばす
// 		continue
// 	}
// 	element := Segment{}
// 	element.Key = row[0]
// 	element.Value = row[1]
// 	element.Name = row[2]
// 	element.Description = row[3]

// 	savedata.Segments = append(savedata.Segments, element)
// }
// }

func getValue(f *excelize.File, sht string, row int, col int) string {
	address, _ := excelize.CoordinatesToCellName(col, row)
	cell, _ := f.GetCellValue(sht, address)
	return cell
}
