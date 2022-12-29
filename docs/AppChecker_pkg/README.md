# 应用安装依赖兼容性检查工具

## 工具简介  

    检查应用包安装依赖是否存在兼容问题

## 工具功能
    
    支持deb包安装依赖检查
    1. 检查应用包安装依赖等级是否符合标准
    2. 检查应用包安装依赖版本要求是否符合标准


## 部署说明
### 环境要求

    python >= 3.7

### 配置要求

    运行前请确保使用dpkg管理的系统在sources.list中配置好deb-src

## 使用说明
### 运行命令

    python3 AppChecker_Pkg/appchecker_pkg.py

### 参数说明

    usage: appchecker_pkg.py [-h] -p PACKAGE_PATH -t STANDARD -s STDFILE -m PKGMT

    optional arguments:
        -h, --help                      show this help message and exit
        -p PACKAGE_PATH, --path PACKAGE_PATH
                                        输入待测包路径
        -t STANDARD, --standard STANDARD
                                        输入评估待测包使用的标准 desktop/server
        -s STDFILE, --stdfile STDFILE
                                        输入使用标准文件路径
        -m PKGMT, --pkgmanager PKGMT
                                        输入当前系统包管理工具 apt/rpm


## 测试方法

    1.获取应用的安装依赖列表
        deb包使用 dpkg -f $deb Pre-Depends 和 dpkg -f $deb Depends 获取依赖列表
    2.遍历依赖库集合
        当依赖库没有版本要求或等级为L1L2且版本符合标准时通过测试，否则给予Warning提示 


## 常见问题

    1. 测试完成后，报告生成在运行目录下，展示文件的测试结果，报告以json格式展示；结果一栏中：PASS代表该检查项通过测试；WARNING代表检查项存在兼容性问题，具体原因见info内容；
    2. 测试完成后，日志记录在/logs文件夹下，正常日志记录在checker_info.log中，错误日志记录在/logs/checker_error.log中

## 附加说明
    rpm包管理器在源码包打包编译过程中，会根据可执行二进制文件（ELF文件）在生成的rpm应用包中自动指明相关依赖库及对应依赖包信息。rpm包的安装依赖和运行依赖是交集关系，安装依赖中so的集合是运行依赖的子集，运行依赖的检查可以覆盖安装依赖中so的检查。

## 结果说明
    {
        "result": "warning",            ——整体结果
        "data": [                       ——详细测试数据
            {
                "item": "gtk+2.0",      ——依赖包名
                "level": "none",        ——依赖包等级
                "result": "warning",    ——依赖包检查结果
                "info": "该包为不推荐使用的包，请您使用标准中的包"  ——结果提示信息
            },
            ……
        ]
    }