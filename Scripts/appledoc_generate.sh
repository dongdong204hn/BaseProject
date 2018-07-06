#!/bin/sh
# 在工程的根目录下生成doc
appledoc --create-html --ignore *.m --no-create-docset -o ../doc --project-name BaseProject --project-company song --company-id com.cn.song ../Utilities/
