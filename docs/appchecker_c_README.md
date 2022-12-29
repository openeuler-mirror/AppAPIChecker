# ELF文件兼容性检查工具

## 工具简介  

    检查应用包内elf文件调用的库文件及包内库文件是否存在兼容问题

### 工具功能

    1. 检查包内库文件是否全不为L1L2等级的库
    2. 检查包内elf文件依赖的库文件是否全为L1L2等级的库

## 部署说明
### 环境要求

    python >= 3.8

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

## 结果说明
    {
        "result": "warning",    ——整体结果  
        "data": [               ——详细测试数据
            {
                "name": "xxx",      ——elf文件名称
                "result": "pass",   ——此文件依赖库检查结果
                "detail": [         ——此文件依赖库具体检查结果
                    {
                        "item": "libpthread.so.0",  ——依赖库名
                        "level": "L1",              ——依赖库标准等级
                        "result": "pass",           ——依赖库检查结果
                        "info": ""                  ——结果提示信息
                    },
                    ……
                ]
            },
            ……
            {
                "name": "other",                    ——此部分为包内elf文件检查结果
                "result": "pass",                   ——包内elf文件总体检查结果
                "detail": [                         ——包内各elf文件检查结果
                    {
                        "item": "eclipse_11600.so", ——包内elf文件名
                        "level": "none",
                        "result": "pass",
                        "info": ""
                    },
                    ……
                ]
            }
        ]
    }
