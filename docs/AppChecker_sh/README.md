# sh文件兼容性检查工具

## 工具简介  

    检查sh文件是否存在兼容问题，


## 工具功能
    
    支持deb包安装依赖检查
    1. 检查sh文件内引用的命令是否符合标准
    2. 检查sh文件是否符合基础规范


## 部署说明
### 环境要求

    python >= 3.7

### 配置要求

    运行前请确保使用dpkg管理的系统在sources.list中配置好deb-src

## 使用说明
### 运行命令

    python3 AppChecker_Pkg/appchecker_pkg.py

### 参数说明

    usage: appchecker_sh.py [-h] -f FILE [FILE ...] -t TYPE [-c CMDLIST_PATH]

    optional arguments:
        -h, --help                      show this help message and exit
        -f FILE [FILE ...], --file FILE [FILE ...]
                                       输入待测文件
        -t TYPE, --type TYPE           
                                       输入操作系统类型 desktop/server
        -c CMDLIST_PATH, --cmdlist CMDLIST_PATH
                                       指定cmdlist文本文件的路径


## 测试方法

    1.获取应用的安装依赖列表
        deb包使用 dpkg -f $deb Pre-Depends 和 dpkg -f $deb Depends 获取依赖列表
    2.遍历依赖库集合
        当依赖库没有版本要求或等级为L1L2且版本符合标准时通过测试，否则给予Warning提示 


## 常见问题

    1. 测试完成后，报告生成在运行目录下，展示文件的测试结果，报告以json格式展示；结果一栏中：PASS代表该检查项通过测试；WARNING代表检查项存在兼容性问题，具体原因见info内容；
    2. 测试完成后，日志记录在/logs文件夹下，正常日志记录在checker_info.log中，错误日志记录在/logs/checker_error.log中

## 附加说明
    引用了LSB的appchecker sh检查工具，如有侵权请及时联系本项目维护人删除