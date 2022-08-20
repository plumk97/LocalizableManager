package generator

import (
	"io/fs"
	"io/ioutil"
	"log"
	"path/filepath"
	"sort"
	"strings"

	"github.com/tealeg/xlsx/v3"
)

type void struct{}

/// 生成xlsx表格文件
func GenerateXLSX(modules []string, codeDirs []string, languageDirs []string, xlsxPath string) {

	/// 生成表格
	wb := xlsx.NewFile()

	/// 提取所有模块现有语言包
	nowLanguageDict := map[string]map[string]string{}
	for i := range modules {

		/// 提取现有的语言包
		for k, v := range fetchLanguageDirKeys(languageDirs[i]) {

			if m, isOk := nowLanguageDict[k]; isOk {
				/// 存在则合并
				for k1, v1 := range v {
					m[k1] = v1
				}
				nowLanguageDict[k] = m
			} else {
				/// 不存在则直接赋值
				nowLanguageDict[k] = v
			}
		}
	}

	/// 获取现有的语言种类
	languageKinds := make([]string, 0, len(nowLanguageDict))
	for k := range nowLanguageDict {
		languageKinds = append(languageKinds, k)
	}
	sort.Strings(languageKinds)

	for i, module := range modules {

		/// 提取代码目录中的key
		codeKeys := fetchCodeDirKeys(codeDirs[i])
		if len(codeKeys) <= 0 {
			continue
		}

		/// 添加一张表
		sh, err := wb.AddSheet(module)
		if err != nil {
			log.Panic(err)
		}

		/// 生成头部
		row := sh.AddRow()

		// row.Sheet.SetColAutoWidth()
		row.AddCell().SetValue("keys")
		for _, kind := range languageKinds {
			row.AddCell().SetValue(kind)
		}

		/// 生成
		for _, key := range codeKeys {
			row := sh.AddRow()
			row.AddCell().SetValue(key)

			for _, kind := range languageKinds {
				if value, isOk := nowLanguageDict[kind][key]; isOk {
					row.AddCell().SetValue(value)
				} else {
					row.AddCell().SetValue("")
				}
			}
		}
	}

	/// 保存表格
	if err := wb.Save(xlsxPath); err != nil {
		log.Panic(err)
	}
}

/// 提取代码目录中的key
func fetchCodeDirKeys(codeDir string) []string {

	keySet := map[string]void{}
	filepath.Walk(codeDir, func(path string, info fs.FileInfo, err error) error {

		if strings.HasSuffix(path, ".swift") {
			if bs, err := ioutil.ReadFile(path); err == nil {
				rawStr := string(bs)
				rawStr = removeComment(rawStr)
				for _, key := range fetchLocalizedKeys(rawStr) {
					keySet[key] = void{}
				}
			}
		}
		return nil
	})

	keys := make([]string, 0, len(keySet))
	for k := range keySet {
		keys = append(keys, k)
	}
	return keys
}

/// 提取现有的语言key-value 返回 { en: {}, kr: {} }
func fetchLanguageDirKeys(languageDir string) map[string]map[string]string {

	languageDict := map[string]map[string]string{}

	filepath.Walk(languageDir, func(path string, info fs.FileInfo, err error) error {

		if strings.HasSuffix(path, ".lproj") {

			languageName := strings.ReplaceAll(info.Name(), ".lproj", "")
			if bs, err := ioutil.ReadFile(path + "/Localizable.strings"); err == nil {
				rawStr := string(bs)
				lines := strings.Split(rawStr, ";\n")

				kvs := map[string]string{}
				for _, line := range lines {
					coms := strings.Split(line, "=")
					if len(coms) != 2 {
						continue
					}

					key := strings.TrimSpace(coms[0])
					/// 去除前后引号
					key = key[1 : len(key)-1]

					value := strings.TrimSpace(coms[1])
					/// 去除前后引号
					value = value[1 : len(value)-1]

					kvs[key] = value
				}

				languageDict[languageName] = kvs
			}
		}
		return nil
	})

	return languageDict
}
