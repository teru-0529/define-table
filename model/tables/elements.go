package tables

import (
	"fmt"
	"slices"
	"strings"

	"github.com/samber/lo"
	"github.com/teru-0529/define-monad/v3/model/elements"
)

type Elements struct {
	eMap   map[string]Element
	EArray []Element
}

type Element struct {
	NameJp       string
	NameEn       string
	DbModel      string
	Constraint   string
	MustNotNull  bool
	IsDefaultStr bool
	IsEnum       bool
	Description  string
	IsOrigin     bool
	OriginName   string
}

func NewElements(path string) (*Elements, error) {

	// INFO: save-data(elements)の読込み
	monad, err := elements.New(path)
	if err != nil {
		return nil, err
	}

	result := Elements{}
	result.eMap = map[string]Element{}
	result.EArray = []Element{}

	for _, item := range monad.Elements {
		element := Element{
			NameJp:       item.NameJp,
			NameEn:       elements.SnakeCase(item.NameEn),
			DbModel:      dbModel(item),
			Constraint:   constraint(item, item.NameEn),
			MustNotNull:  mustNotNull(item),
			IsDefaultStr: isDefaultStr(item),
			IsEnum:       item.Domain == elements.ENUM,
			Description:  item.Description,
			IsOrigin:     true,
			OriginName:   item.NameJp,
		}
		result.eMap[element.NameJp] = element
		result.EArray = append(result.EArray, element)
	}

	for _, item := range monad.DeliveElements {
		element := Element{
			NameJp:       item.NameJp,
			NameEn:       elements.SnakeCase(item.NameEn),
			DbModel:      dbModel(*item.Ref),
			Constraint:   constraint(*item.Ref, item.NameEn),
			MustNotNull:  mustNotNull(*item.Ref),
			IsDefaultStr: isDefaultStr(*item.Ref),
			IsEnum:       item.Ref.Domain == elements.ENUM,
			Description:  item.Description,
			IsOrigin:     false,
			OriginName:   item.Ref.NameJp,
		}
		result.eMap[element.NameJp] = element
		result.EArray = append(result.EArray, element)
	}

	return &result, nil
}

// toTableElements
func (elements *Elements) ToExcel() []string {
	result := []string{}
	for _, element := range elements.EArray {
		result = append(result, element.toExcel())
	}
	return result
}

// toTableElements
func (element *Element) toExcel() string {
	ary := []string{
		element.NameJp,
		element.NameEn,
		element.DbModel,
		element.Constraint,
		lo.Ternary(element.MustNotNull, "true", "false"),
		element.Description,
		lo.Ternary(element.IsOrigin, "0", "1"),
		element.OriginName,
	}
	return strings.Join(ary, "\t")
}

// nameJp → nameEn
func (elements *Elements) NameEn(nameJp string) string {
	element, ok := elements.eMap[nameJp]
	if !ok {
		return "N/A"
	}
	return element.NameEn
}

// nameJp → ddlField
func (elements *Elements) DDLField(field Field, schema string) string {
	element, ok := elements.eMap[field.Name]
	if !ok {
		return "N/A"
	}
	result := []string{element.NameEn}
	if element.IsEnum {
		result = append(result, fmt.Sprintf("%s.%s", schema, element.DbModel))
	} else {
		result = append(result, element.DbModel)
	}
	if !field.Nullable {
		result = append(result, "NOT NULL")
	}
	if field.Default != nil {
		if element.IsDefaultStr {
			result = append(result, fmt.Sprintf("DEFAULT '%s'", *field.Default))
		} else {
			// ["]を[']に変更
			result = append(result, fmt.Sprintf("DEFAULT %s", strings.ReplaceAll(*field.Default, "\"", "'")))
		}
	}
	if element.Constraint != "" {
		result = append(result, fmt.Sprintf("check %s", element.Constraint))
	}

	return strings.Join(result, " ")
}

// nameJp → mdField
func (elements *Elements) MdField(field Field) string {
	element, ok := elements.eMap[field.Name]
	if !ok {
		return "N/A"
	}
	default_ := ""
	if field.Default != nil {
		default_ = *field.Default
	}
	return fmt.Sprintf(
		"%s(%s) | %s | %t | %s | %s",
		element.NameJp,
		element.NameEn,
		element.DbModel,
		!field.Nullable,
		default_,
		element.Constraint,
	)
}

// db制約
func dbModel(element elements.Element) string {
	if element.Domain == elements.SEQUENCE {
		return "serial"
	} else if element.Domain == elements.BOOL {
		return "boolean"
	} else if element.Domain == elements.INTEGER {
		return "integer"
	} else if element.Domain == elements.NUMBER {
		return "numeric"
	} else if element.Domain == elements.TEXT {
		return "text"
	} else if element.Domain == elements.UUID {
		return "uuid"
	} else if element.Domain == elements.DATE {
		return "date"
	} else if element.Domain == elements.DATETIME {
		return "timestamp"
	} else if element.Domain == elements.TIME {
		return "varchar(5)"
	} else if element.Domain == elements.ENUM {
		return elements.SnakeCase(element.NameEn)
	} else {
		return fmt.Sprintf("varchar(%d)", *element.MaxDigits)
	}
}

// field制約
func constraint(element elements.Element, nameEn string) string {
	nameEnSnake := elements.SnakeCase(nameEn)
	if element.RegEx != nil {
		// 正規表現が設定されている
		return fmt.Sprintf("(%s ~* '%s')", nameEnSnake, *element.RegEx)
	} else if element.MinDigits != nil && element.MaxDigits != nil && *element.MinDigits == *element.MaxDigits {
		// 最小桁数/最大桁数が等しい
		return fmt.Sprintf("(LENGTH(%s) = %d)", nameEnSnake, *element.MinDigits)
	} else if element.MinDigits != nil {
		// 最小桁数が設定されている
		return fmt.Sprintf("(LENGTH(%s) >= %d)", nameEnSnake, *element.MinDigits)
	} else if element.MinValue != nil && element.MaxValue != nil {
		// 最小値・最大値の両方が設定されている
		return fmt.Sprintf("(%d <= %s AND %s <= %d)", *element.MinValue, nameEnSnake, nameEnSnake, *element.MaxValue)
	} else if element.MinValue != nil {
		// 最小値が設定されている
		return fmt.Sprintf("(%s >= %d)", nameEnSnake, *element.MinValue)
	} else if element.MaxValue != nil {
		// 最大値が設定されている
		return fmt.Sprintf("(%s <= %d)", nameEnSnake, *element.MaxValue)
	}
	return ""
}

// NotNullを強制するかどうか
func mustNotNull(element elements.Element) bool {
	return slices.Contains(
		[]elements.Dom{elements.ENUM, elements.BOOL},
		element.Domain,
	)
}

// デフォルト値が文字列扱いかどうか
func isDefaultStr(element elements.Element) bool {
	return slices.Contains(
		[]elements.Dom{elements.ID, elements.ENUM, elements.CODE, elements.STRING, elements.TEXT, elements.TIME},
		element.Domain,
	)
}
