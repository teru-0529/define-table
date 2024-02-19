package tables

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/teru-0529/define-monad/v3/store"
)

const DDL_FILE_SUFFIX = "10"
const FK_DDL_FILE_SUFFIX = "11"
const AUDIT_IDENTIFY_LENGTH = 50

// ddl生成
func (savedata *SaveData) CreateDdl(ddlDir string, elements Elements, saveHistry bool) (int, error) {

	// INFO: テーブル単位で処理
	for tableNo, table := range savedata.Tables {
		table.createDdl(tableNo+1, ddlDir, elements, savedata.Schema, saveHistry)

		// INFO:TODO: 外部キー用DDLの生成
		if len(table.Constraint.ForeignKeys) > 0 {
			fmt.Println("DUMMY")
		}
	}

	return len(savedata.Tables), nil
}

// ddlの書き込み
func (table *Table) createDdl(tableNo int, ddlDir string, elements Elements, schema Schema, saveHistory bool) error {

	// INFO: Fileの取得
	path := filepath.Join(ddlDir, fmt.Sprintf("%s_%s_%s.sql", DDL_FILE_SUFFIX, schema.NameEn, table.NameEn))
	file, cleanup, err := store.NewFile(path)
	if err != nil {
		return err
	}
	defer cleanup()

	// INFO: header書き込み
	file.WriteString(fmt.Sprintf("-- is_master_table=%t\n\n", table.IsMaster))
	file.WriteString(fmt.Sprintf("-- %d.%s(%s)\n\n", tableNo, table.NameJp, table.NameEn))

	// INFO: create-table書き込み
	file.WriteString("-- Create Table\n")
	file.WriteString(fmt.Sprintf("DROP TABLE IF EXISTS %s.%s CASCADE;\n", schema.NameEn, table.NameEn))
	file.WriteString(fmt.Sprintf("CREATE TABLE %s.%s (\n", schema.NameEn, table.NameEn))
	fields := []string{}
	for _, field := range table.Fields {
		fields = append(fields, "  "+elements.DDLField(field))
	}
	fields = addAuditFields(fields)
	file.WriteString(strings.Join(fields, ",\n"))
	file.WriteString("\n);\n")

	// INFO: Comment書き込み
	file.WriteString("\n-- Set Table Comment\n")
	file.WriteString(fmt.Sprintf("COMMENT ON TABLE %s.%s IS '%s';\n", schema.NameEn, table.NameEn, table.NameJp))

	file.WriteString("\n-- Set Column Comment\n")
	for _, field := range table.Fields {
		file.WriteString(fmt.Sprintf(
			"COMMENT ON COLUMN %s.%s.%s IS '%s';\n",
			schema.NameEn,
			table.NameEn,
			elements.NameEn(field.Name),
			field.Name,
		))
	}
	file.WriteString(fmt.Sprintf("COMMENT ON COLUMN %s.%s.created_at IS '作成日時';\n", schema.NameEn, table.NameEn))
	file.WriteString(fmt.Sprintf("COMMENT ON COLUMN %s.%s.updated_at IS '更新日時';\n", schema.NameEn, table.NameEn))
	file.WriteString(fmt.Sprintf("COMMENT ON COLUMN %s.%s.created_by IS '作成者';\n", schema.NameEn, table.NameEn))
	file.WriteString(fmt.Sprintf("COMMENT ON COLUMN %s.%s.updated_by IS '更新者';\n", schema.NameEn, table.NameEn))

	// INFO: Pk書き込み
	file.WriteString("\n-- Set PK Constraint\n")
	file.WriteString(fmt.Sprintf("ALTER TABLE %s.%s ADD PRIMARY KEY (\n", schema.NameEn, table.NameEn))
	pk := []string{}
	for _, field := range table.Constraint.PraimaryKey {
		pk = append(pk, "  "+elements.NameEn(field))
	}
	file.WriteString(strings.Join(pk, ",\n"))
	file.WriteString("\n);\n")

	// INFO: unique書き込み
	if len(table.Constraint.Uniques) > 0 {
		file.WriteString("\n-- Set Unique Constraint")
		for _, unique := range table.Constraint.Uniques {
			file.WriteString(fmt.Sprintf(
				"\nALTER TABLE %s.%s ADD CONSTRAINT %s UNIQUE (\n",
				schema.NameEn,
				table.NameEn,
				unique.Name,
			))
			items := []string{}
			for _, field := range unique.Fields {
				items = append(items, "  "+elements.NameEn(field))
			}
			file.WriteString(strings.Join(items, ",\n"))
			file.WriteString("\n);\n")
		}
	}

	// INFO:TODO: index書き込み
	if len(table.Indexes) > 0 {
		fmt.Println("dummy")
	}

	// INFO: 更新日時設定Trigger書き込み
	file.WriteString("\n-- Create 'set_update_at' Trigger\n")
	file.WriteString(fmt.Sprintf("CREATE TRIGGER %s_updated\n", table.NameEn))
	file.WriteString("  BEFORE UPDATE\n")
	file.WriteString(fmt.Sprintf("  ON %s.%s\n", schema.NameEn, table.NameEn))
	file.WriteString("  FOR EACH ROW\nEXECUTE PROCEDURE set_updated_at()\n")

	// INFO:TODO: 履歴登録Trigger書き込み
	// if saveHistory {
	// 	fmt.Println("saveHistory")
	// }

	fmt.Printf("output ddl file: [%s]\n", filepath.ToSlash(path))
	return nil
}

func addAuditFields(fields []string) []string {
	fields = append(fields, "  created_at timestamp NOT NULL DEFAULT current_timestamp")
	fields = append(fields, "  updated_at timestamp NOT NULL DEFAULT current_timestamp")
	fields = append(fields, fmt.Sprintf("  created_by varchar(%d)", AUDIT_IDENTIFY_LENGTH))
	fields = append(fields, fmt.Sprintf("  updated_by varchar(%d)", AUDIT_IDENTIFY_LENGTH))
	return fields
}
