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

	return strings.Join([]string{head, fieldStr, pkStr, uniqueStr}, "*1*")
}
