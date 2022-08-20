package main

import (
	"errors"
	"localize-generator/generator"
	"log"
	"os"
	"strings"

	"github.com/urfave/cli/v2"
)

func main() {

	app := &cli.App{
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:        "type",
				Aliases:     []string{"t"},
				Usage:       "指定生成类型 [xlsx|strings]",
				Value:       "xlsx",
				DefaultText: "xlsx",
			},
			&cli.StringFlag{
				Name:     "module",
				Usage:    "指定模块名, 以','分割",
				Required: true,
			},
			&cli.StringFlag{
				Name:     "code_dir",
				Usage:    "指定代码目录, 以','分割",
				Required: true,
			},
			&cli.StringFlag{
				Name:     "language_dir",
				Usage:    "指定语言包目录, 以','分割",
				Required: true,
			},
			&cli.StringFlag{
				Name:    "xlsx",
				Aliases: []string{"x"},
				Usage:   "指定xlsx文件路径",
			},
		},
		Action: func(c *cli.Context) error {

			generateType := c.String("type")
			modules := strings.Split(c.String("module"), ",")
			codeDirs := strings.Split(c.String("code_dir"), ",")
			languageDirs := strings.Split(c.String("language_dir"), ",")
			xlsxPath := c.String("xlsx")

			switch generateType {
			case "xlsx":
				generator.GenerateXLSX(modules, codeDirs, languageDirs, xlsxPath)

			case "strings":
				generator.GenerateStrings(modules, codeDirs, languageDirs, xlsxPath)

			default:
				return errors.New("type 指定错误")
			}

			return nil
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
