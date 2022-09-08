# AppAPIChecker

#### 介绍
检查应用调用的运行库（包括自包含的库）及详细接口调用是否符合标准要求，包括二进制应用、Python应用、Perl应用、Java应用、Shell应用。
Software API compliance (compatibility) check tool.

#### 软件架构
软件架构说明
AppAPIChecker  
├── AppChecker_C  
│   ├── appchecker_c.py  
│   └── appchecker_pkg.py  
├── AppChecker_Java  
├── AppChecker_Perl  
├── AppChecker_Python  
├── AppChecker_sh  
├── config  
├── docs  
│   ├── README.md  
│   └── 模块对接方式.md  
├── LibScan  
├── logs  
├── report  
├── SourceScan  
├── utils  
│   ├── csv.py  
│   ├── json_formatter.py  
│   ├── logger.py  
│   ├── myjson.py  
│   └── utils.py  
├── workspace  
├── checker.py  
├── manage.py  
├── README.en.md  
├── README.md  
└── requirements.txt  

#### 安装教程

1.  下载本项目并解压
2.  进入到项目目录内
3.  按使用说明执行启动脚本即可

#### 使用说明

1.  环境要求：  
python >= 3.8
2.  python manage.py
3.  参数说明  
usage: manage.py [-h] -t TYPE -m PKGMT [-l LEVEL] -p PACKAGE_PATH [-j LIBLIST_PATH] [-o SOLIST_PATH] [-a LIBSCAN] [-i INTERFACESCAN] [-v]   
optional arguments:
  -h, --help           
     show this help message and exit  
  -t TYPE, --type TYPE  
  输入操作系统类型 desktop/server  
  -m PKGMT, --pkgmanager PKGMT  
                        输入当前系统包管理工具 apt/rpm  
  -l LEVEL, --level LEVEL  
                        选择比较的库的级别。值为 1、2、3、12、123、3；1只检查1级库，2只检查2级库，3只检查3级库，123 检查所有库  
  -p PACKAGE_PATH, --path PACKAGE_PATH    
                        输入待测包路径  
  -j LIBLIST_PATH, --liblist LIBLIST_PATH    
                        指定liblist.json配置文件的路径  
  -o SOLIST_PATH, --solist SOLIST_PATH   
                        指定solist.json配置文件的路径  
  -a LIBSCAN, --current LIBSCAN  
                        检查本地库的版本是否符合满足应用要求 yes/no  
  -i INTERFACESCAN, --interface INTERFACESCAN  
                        应用程序接口级检查 yes/no  
  -v, --version         show program's version number and exit  


#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request


#### 特技

1.  使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md。
2.  Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3.  你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4.  [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5.  Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6.  Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
