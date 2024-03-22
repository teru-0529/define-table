package tables

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/samber/lo"
	"github.com/teru-0529/define-monad/v3/store"
)

const DDL_FILE_SUFFIX = "10"
const AFTER_DDL_FILE_SUFFIX = "11"
const AUDIT_IDENTIFY_LENGTH = 58

// ddl生成
func (savedata *SaveData) CreateDdl(ddlDir string, elements Elements, saveHistry bool) (int, error) {

	// INFO: テーブル単位で処理
	for tableNo, table := range savedata.Tables {
		// INFO: DDLの生成
		table.createDdl(tableNo+1, ddlDir, elements, savedata.Schema, saveHistry)

		// INFO: 外部キー用DDLの生成
		if len(table.Constraint.ForeignKeys) > 0 {
			table.createAfterDdl(tableNo+1, ddlDir, elements, savedata.Schema, *savedata)
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
		fields = append(fields, "  "+elements.DDLField(field, schema.NameEn))
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

	// INFO: index書き込み
	if len(table.Indexes) > 0 {
		file.WriteString("\n-- create index")
		for _, index := range table.Indexes {
			file.WriteString(fmt.Sprintf(
				"\nCREATE %sINDEX %s ON %s.%s (\n",
				lo.Ternary(index.Unique, "UNIQUE ", ""),
				index.Name,
				schema.NameEn,
				table.NameEn,
			))
			items := []string{}
			for _, field := range index.Fields {
				items = append(items, fmt.Sprintf(
					"  %s%s",
					elements.NameEn(field.Field),
					lo.Ternary(field.Asc, "", " DESC"),
				))
			}
			file.WriteString(strings.Join(items, ",\n"))
			file.WriteString("\n);\n")
		}
	}

	// INFO: 更新日時設定Trigger書き込み
	file.WriteString("\n-- Create 'set_update_at' Trigger\n")
	file.WriteString("CREATE TRIGGER set_updated_at\n")
	file.WriteString("  BEFORE UPDATE\n")
	file.WriteString(fmt.Sprintf("  ON %s.%s\n", schema.NameEn, table.NameEn))
	file.WriteString("  FOR EACH ROW\nEXECUTE PROCEDURE set_updated_at();\n")

	// INFO: 履歴登録Function/Trigger書き込み
	if saveHistory {
		file.WriteString("\n-- Create 'append_history' Function\n")
		file.WriteString(fmt.Sprintf("DROP FUNCTION IF EXISTS %s.%s_audit();\n", schema.NameEn, table.NameEn))
		file.WriteString(fmt.Sprintf("CREATE OR REPLACE FUNCTION %s.%s_audit() RETURNS TRIGGER AS $$\n", schema.NameEn, table.NameEn))
		file.WriteString("BEGIN\n  IF (TG_OP = 'DELETE') THEN\n")
		file.WriteString("    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)\n")
		file.WriteString(fmt.Sprintf("    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', %s;\n", table.keyStr("OLD", elements)))

		file.WriteString("  ELSIF (TG_OP = 'UPDATE') THEN\n")
		file.WriteString("    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)\n")
		file.WriteString(fmt.Sprintf("    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', %s;\n", table.keyStr("NEW", elements)))

		file.WriteString("  ELSIF (TG_OP = 'INSERT') THEN\n")
		file.WriteString("    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)\n")
		file.WriteString(fmt.Sprintf("    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', %s;\n", table.keyStr("NEW", elements)))

		file.WriteString("  END IF;\n  RETURN null;\nEND;\n$$ LANGUAGE plpgsql;\n")

		file.WriteString("\n-- Create 'audit' Trigger\n")
		file.WriteString("CREATE TRIGGER audit\n")
		file.WriteString("  AFTER INSERT OR UPDATE OR DELETE\n")
		file.WriteString(fmt.Sprintf("  ON %s.%s\n", schema.NameEn, table.NameEn))
		file.WriteString(fmt.Sprintf("  FOR EACH ROW\nEXECUTE PROCEDURE %s.%s_audit();\n", schema.NameEn, table.NameEn))
	}

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

func (table *Table) keyStr(prefix string, elements Elements) string {
	keys := []string{}
	for _, pk := range table.Constraint.PraimaryKey {
		keys = append(keys, fmt.Sprintf("%s.%s", prefix, elements.NameEn(pk)))
	}
	return strings.Join(keys, " || '-' || ")
}

// ddlの書き込み
func (table *Table) createAfterDdl(tableNo int, ddlDir string, elements Elements, schema Schema, sData SaveData) error {

	// INFO: Fileの取得
	path := filepath.Join(ddlDir, fmt.Sprintf("%s_%s_%s.sql", AFTER_DDL_FILE_SUFFIX, schema.NameEn, table.NameEn))
	file, cleanup, err := store.NewFile(path)
	if err != nil {
		return err
	}
	defer cleanup()

	// INFO: header書き込み
	file.WriteString("-- operation_afert_create_tables\n\n")
	file.WriteString(fmt.Sprintf("-- %d.%s(%s)\n\n", tableNo, table.NameJp, table.NameEn))

	// INFO: FK書き込み
	file.WriteString("-- Set FK Constraint")
	for _, fk := range table.Constraint.ForeignKeys {
		file.WriteString(fmt.Sprintf(
			"\nALTER TABLE %s.%s DROP CONSTRAINT IF EXISTS %s;\n",
			schema.NameEn,
			table.NameEn,
			fk.Name,
		))
		file.WriteString(fmt.Sprintf(
			"ALTER TABLE %s.%s ADD CONSTRAINT %s FOREIGN KEY (\n",
			schema.NameEn,
			table.NameEn,
			fk.Name,
		))
		// 自身のフィールド
		items := []string{}
		for _, field := range fk.Fields {
			items = append(items, "  "+elements.NameEn(field.ThisField))
		}
		file.WriteString(strings.Join(items, ",\n"))
		file.WriteString(fmt.Sprintf(
			"\n) REFERENCES %s.%s (\n",
			schema.NameEn,
			sData.getNameEn(fk.RefTable),
		))
		// 参照元のフィールド
		items = []string{}
		for _, field := range fk.Fields {
			items = append(items, "  "+elements.NameEn(field.RefField))
		}
		file.WriteString(strings.Join(items, ",\n"))
		// オプション有無
		deleteOption := ""
		if fk.DeleteOption != nil {
			deleteOption = fmt.Sprintf(" ON DELETE %s", *fk.DeleteOption)
		}
		updateOption := ""
		if fk.UpdateOption != nil {
			updateOption = fmt.Sprintf(" ON UPDATE %s", *fk.UpdateOption)
		}
		// if
		file.WriteString(fmt.Sprintf(
			"\n)%s%s;\n",
			deleteOption,
			updateOption,
		))
	}
	return nil
}
