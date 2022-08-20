package generator

import (
	"regexp"
	"strings"
)

// 移除注释
func removeComment(rawStr string) string {

	/// 是否处于字符串
	isInStr := false

	/// 是否处于单行注释
	isInSingleComment := false

	/// 是否处于多行注释
	multipleDepth := 0

	/// 非注释文本
	chars := []rune{}

	for i, c := range rawStr {

		/// 单行注释 \n结尾
		if isInSingleComment && c == '\n' {
			isInSingleComment = false
		}

		/// 当前没有处于字符串和注释中 判断是否是单行注释开头
		if !isInStr && !isInSingleComment && multipleDepth == 0 {
			isInSingleComment = (c == '/' && rawStr[i+1] == '/')
		}

		/// 当前没有处于字符串和单行注释中 判断是否是多行注释开头
		if !isInStr && !isInSingleComment && c == '/' && rawStr[i+1] == '*' {
			multipleDepth += 1
		}

		/// 当前没有处于注释中，判断是否进入字符串
		if !isInSingleComment && multipleDepth == 0 && ((c == '"' && i == 0) || (c == '"' && i > 0 && rawStr[i-1] != '\\')) {
			isInStr = !isInStr
		}

		/// 没有处于注释中 可加入字符
		if !isInSingleComment && multipleDepth == 0 {
			chars = append(chars, c)
		}

		/// 判断当前是否处于多行注释并判断是否是结尾
		if multipleDepth > 0 && c == '/' && rawStr[i-1] == '*' {
			multipleDepth -= 1
		}

	}

	return string(chars)
}

// 提取语言keys
func fetchLocalizedKeys(rawStr string) []string {

	getQuotationStrs := func(rawStr string) []string {
		isInStr := false
		strs := []string{}
		chars := []rune{}
		for i, c := range rawStr {

			if (c == '"' && i == 0) || (c == '"' && i > 0 && rawStr[i-1] != '\\') {
				isInStr = !isInStr
			}

			if isInStr {
				chars = append(chars, c)
			} else if len(chars) > 0 {
				strs = append(strs, string(chars[1:]))
				chars = chars[len(chars):]
			}
		}
		return strs
	}

	/// 匹配 "xxxxx".localized()
	pattern := regexp.MustCompile(`(?:"{3}[\s\S]*?"{3}|".*?")\s*\.\s*?localized.*?\(`)

	/// 匹配 "xxxxx"
	pattern_str := regexp.MustCompile(`(?:"{3}[\s\S]*?"{3}|".*?")\s*\.`)

	keys := []string{}
	for _, segment := range pattern.FindAllString(rawStr, -1) {
		ret := pattern_str.FindAllString(segment, -1)

		key := ret[len(ret)-1]
		key = strings.TrimSpace(key)
		if strings.HasPrefix(key, `"""`) {
			/// 多行文本 分行去掉第一行和最后一行
			lines := strings.Split(key, "\n")
			key = strings.Join(lines[1:len(lines)-1], "\n")
		} else {
			/// 单行文本 提取字符串 防止类似 "13123", buttons: "Downloading".localized( 的文本
			ret = getQuotationStrs(key)
			key = ret[len(ret)-1]
		}
		key = escapeString(key)
		keys = append(keys, key)
	}
	return keys
}

/// 转义引号
func escapeString(str string) string {
	chars := []rune{}
	for i, c := range str {
		if (c == '"' && i == 0) || (c == '"' && i > 0 && str[i-1] != '\\') {
			chars = append(chars, '\\')
		}
		chars = append(chars, c)
	}
	return string(chars)
}
