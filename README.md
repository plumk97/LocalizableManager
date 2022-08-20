# LocalizableManager

语言包管理工具只支持Swift, 运行前需先编译golang工程

生成表格流程：

1. 提取代码中带`.localized`方法带字符串
2. 以字符串为key生成xlsx表格

生成语言包流程:

1. 选取xlsx表格
2. 第一列为语言key并且第一行固定字符串`key`，后续列为对应的语言翻译，后续列第一行为语言包缩写例如`en`
3. 生成语言包到指定目录
