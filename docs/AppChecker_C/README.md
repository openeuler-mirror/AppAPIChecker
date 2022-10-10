# 二进制应用兼容性检查工具

## 工具简介  

    检查应用包内elf文件调用的库文件及包内库文件是否存在兼容问题

### 工具功能

    1. 检查包内库文件是否全不为L1L2等级的库
    2. 检查包内elf文件依赖的库文件是否全为L1L2等级的库

## 部署说明
### 环境要求

    python >= 3.7

## 使用说明
### 运行命令

    python3 AppChecker_C/appchecker_c.py

### 参数说明

    usage: appchecker_c.py [-h] -f FILES [FILES ...] -t STANDARD -s STDFILE

    optional arguments:
    	-h, --help            				show this help message and exit
		-f FILES [FILES ...], --files FILES [FILES ...]
                            				输入待测文件列表
		-t STANDARD, --standard STANDARD
                            				输入评估待测包使用的标准 desktop/server
    	-s STDFILE, --stdfile STDFILE
                            				输入使用标准文件路径


## 常见问题

    1. 测试完成后，报告生成在运行目录下，展示文件的测试结果，报告以json格式展示；结果一栏中：PASS代表该检查项通过测试；WARNING代表检查项存在兼容性问题，具体原因见info内容；
    2. 测试完成后，日志记录在/logs文件夹下，正常日志记录在checker_info.log中，错误日志记录在/logs/checker_error.log中
