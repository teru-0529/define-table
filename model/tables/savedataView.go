package tables

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/samber/lo"
	"github.com/teru-0529/define-monad/v3/store"
)

// ddl生成
func (savedata *SaveData) CreateMd(viewDir string, elements Elements) error {

	// INFO: Fileの取得
	path := filepath.Join(viewDir, fmt.Sprintf("%s.md", savedata.Schema.NameEn))
	file, cleanup, err := store.NewFile(path)
	if err != nil {
		return err
	}
	defer cleanup()

	// INFO: header書き込み
	file.WriteString("# テーブル定義\n\n----------\n")

	// INFO: テーブル単位での処理
	for tableNo, table := range savedata.Tables {
		table.createMd(*file, tableNo+1, elements)
	}

	fmt.Printf("output md file: [%s]\n", filepath.ToSlash(path))
	return nil
}

// mdの書き込み
func (table *Table) createMd(file os.File, tableNo int, elements Elements) error {

	// INFO: テーブル名
	file.WriteString(fmt.Sprintf("\n## #%d %s(%s)\n", tableNo, table.NameJp, table.NameEn))

	// INFO: フィールド
	file.WriteString("\n### Fields\n")
	file.WriteString("\n| # | 名称 | データ型 | NOT NULL | 初期値 | 制約 |\n")
	file.WriteString("| -- | -- | -- | -- | -- | -- |\n")
	for no, field := range table.Fields {
		file.WriteString(fmt.Sprintf("| %d | %s |\n", no+1, elements.MdField(field)))
	}

	// INFO: 制約
	file.WriteString("\n### Constraints\n")
	// INFO: PK
	file.WriteString("\n#### Primary Key\n\n")
	for _, field := range table.Constraint.PraimaryKey {
		file.WriteString(fmt.Sprintf("* %s(%s)\n", field, elements.NameEn(field)))
	}

	// INFO: ユニーク
	if len(table.Constraint.Uniques) > 0 {
		file.WriteString("\n#### Uniques\n")
		for _, unique := range table.Constraint.Uniques {
			file.WriteString(fmt.Sprintf("\n#### %s\n\n", unique.Name))
			for _, field := range unique.Fields {
				file.WriteString(fmt.Sprintf("* %s(%s)\n", field, elements.NameEn(field)))
			}
		}
	}

	// INFO:TODO: FK
	if len(table.Constraint.ForeignKeys) > 0 {
		file.WriteString("\n#### Foreign Keys\n")
	}

	// INFO: インデックス
	if len(table.Indexes) > 0 {
		file.WriteString("\n### Indexes\n")
		for _, index := range table.Indexes {
			file.WriteString(fmt.Sprintf("\n#### %s\n\n", index.Name))
			if index.Unique {
				file.WriteString("* Unique Index\n\n")
			}
			file.WriteString("| # | フィールド | ASC/DESC |\n")
			file.WriteString("| -- | -- | -- |\n")
			for no, field := range index.Fields {
				file.WriteString(fmt.Sprintf(
					"| %d | %s(%s) | %s |\n",
					no+1,
					field.Field,
					elements.NameEn(field.Field),
					lo.Ternary(field.Asc, "ASC", "DESC"),
				))
			}
		}
	}

	file.WriteString("\n----------\n")

	return nil
}
