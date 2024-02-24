package tables

import (
	"fmt"
	"strings"

	"github.com/samber/lo"
)

// toExcel
func (savedata *SaveData) ToExcel() []string {
	return lo.Map(savedata.Tables, func(item Table, index int) string { return item.toExcel() })
}

func (table *Table) toExcel() string {
	// ヘッダー情報（テーブル名、マスタ有無）
	head := fmt.Sprintf("%s\t%s\t%s", table.NameJp, table.NameEn, lo.Ternary(table.IsMaster, "○", "-"))

	// フィールド情報
	fields := []string{}
	for _, field := range table.Fields {
		fields = append(fields, fmt.Sprintf(
			"%s\t%s\t%s",
			field.Name,
			lo.Ternary(field.Nullable, "", "1"),
			lo.Ternary(lo.IsNil(field.Default), "", *field.Default)),
		)
	}
	fieldStr := strings.Join(fields, "*2*")

	// PK情報
	pkStr := strings.Join(table.Constraint.PraimaryKey, "\t")

	// Unique情報
	unique := []string{}
	for _, item := range table.Constraint.Uniques {
		unique = append(unique, strings.Join(item.Fields, "\t"))
	}
	uniqueStr := strings.Join(unique, "*2*")

	// FK情報
	foreignKey := []string{}
	for _, item := range table.Constraint.ForeignKeys {
		fkFields := []string{}
		for _, field := range item.Fields {
			fkFields = append(fkFields, fmt.Sprintf(
				"%s\t%s",
				field.ThisField,
				field.RefField,
			))
		}
		fk := fmt.Sprintf(
			"%s*3*%s*3*%s*3*%s",
			item.RefTable,
			lo.Ternary(lo.IsNil(item.DeleteOption), "", *item.DeleteOption),
			lo.Ternary(lo.IsNil(item.UpdateOption), "", *item.UpdateOption),
			strings.Join(fkFields, "*4*"),
		)
		foreignKey = append(foreignKey, fk)
	}
	fkStr := strings.Join(foreignKey, "*2*")

	// Index情報
	index := []string{}
	for _, item := range table.Indexes {
		idxFields := []string{}
		for _, field := range item.Fields {
			idxFields = append(idxFields, fmt.Sprintf(
				"%s\t%s",
				field.Field,
				lo.Ternary(field.Asc, "", "-1"),
			))
		}
		idx := fmt.Sprintf(
			"%s*3*%s",
			lo.Ternary(item.Unique, "1", ""),
			strings.Join(idxFields, "*4*"),
		)
		index = append(index, idx)
	}
	indexStr := strings.Join(index, "*2*")

	return strings.Join([]string{head, fieldStr, pkStr, uniqueStr, fkStr, indexStr}, "*1*")
}
