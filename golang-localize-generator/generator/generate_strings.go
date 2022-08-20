package generator

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/tealeg/xlsx/v3"
)

// 生成语言包文件
func GenerateStrings(modules []string, codeDirs []string, languageDirs []string, xlsxPath string) {

	wb, err := xlsx.OpenFile(xlsxPath)
	if err != nil {
		log.Panic(err)
	}

	for i, module := range modules {
		languageDir := languageDirs[i]
		if sh, isOk := wb.Sheet[module]; isOk {

			/// 提取表格内容 生成map
			set := generateLanguageMap(sh)
			if set == nil {
				break
			}

			/// 获取语言种类
			languageSet := *set
			kinds := make([]string, 0, len(languageSet))
			for k := range languageSet {
				kinds = append(kinds, k)
			}

			/// 生成strings
			for _, kind := range kinds {
				content := generateStrings(languageSet[kind])

				/// 语言目录路径
				languageKindDir := languageDir + fmt.Sprintf("/%s.lproj", kind)
				if _, err := os.Stat(languageKindDir); os.IsNotExist(err) {
					if err := os.Mkdir(languageKindDir, os.ModePerm); err != nil {
						log.Panic(err)
					}
				}

				/// 语言strings文件路径
				languagePath := languageDir + fmt.Sprintf("/%s.lproj/Localizable.strings", kind)
				if err := ioutil.WriteFile(languagePath, []byte(content), os.ModePerm); err != nil {
					log.Panic(err)
				}
			}
		}
	}
}

/// 根据表生成语言map
func generateLanguageMap(sh *xlsx.Sheet) *map[string]map[string]string {

	maxRow := sh.MaxRow
	maxCol := sh.MaxCol

	languageSet := map[string]map[string]string{}

	for i := 0; i < maxRow; i++ {
		row, err := sh.Row(i)
		if err != nil {
			return nil
		}

		key := ""
		for j := 0; j < maxCol; j++ {
			value := row.GetCell(j).String()

			if i == 0 {

				/// 判断第一个cell是否值为keys
				if j == 0 && value != "keys" {
					return nil
				}

				/// 提取语言种类
				if j > 0 && len(value) > 0 {
					languageSet[value] = map[string]string{}
				}
			} else {

				if j == 0 {
					/// 第一列为key
					key = value
				} else {
					/// 取当前列 语言种类
					if cell, err := sh.Cell(0, j); err != nil {
						log.Panic(err)
						continue
					} else {
						kind := cell.Value
						if len(kind) <= 0 {
							break
						}
						if set, isOk := languageSet[kind]; isOk {
							set[key] = value
						}
					}
				}
			}
		}
	}
	return &languageSet
}

/// 生成strings文件内容
func generateStrings(kvs map[string]string) string {

	content := ""
	for key, value := range kvs {

		v := escapeString(value)

		/// 无value 不加入
		if len(v) <= 0 {
			continue
		}

		content += fmt.Sprintf(`"%s" = "%s";`, escapeString(key), v)
		content += "\n"
	}

	return content
}
