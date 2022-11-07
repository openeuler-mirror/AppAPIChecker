# coding=utf-8
"""
Copyright (c) 麒麟软件有限公司 . 2018-2022 . All rights reserved.
AppAPIChecker licensed under the Mulan PSL v2.
You can use this software according to the terms and conditions of the Mulan PSL v2.
You may obtain a copy of Mulan PSL v2 at:
     http://license.coscl.org.cn/MulanPSL2
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
See the Mulan PSL v2 for more details.

@Project : AppChecker
@Time    : 2022/8/8 10:38
@Author  : wangbin
"""
import argparse
import os
import logging
import pprint
import subprocess

from AppChecker_C.appchecker_c import SoChecker
from AppChecker_pkg.appchecker_pkg import PkgChecker
from AppChecker_sh.appchecker_sh import ShChecker
from utils.utils import local_time, mkdir
from utils.logger import init_logger
from utils.utils import get_env_info
from utils.myjson import Json


# 导入各个模块的checker
# from AppChecker-C.checker import CheckerC


def init_args():
    """
    init args
    :return:
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--type", type=str, dest="type", required=True, help='输入操作系统类型 desktop/server')
    parser.add_argument("-m", "--pkgmanager", type=str, dest="pkgmt", required=True, help='输入当前系统包管理工具 dkpg/rpm')
    parser.add_argument("-l", "--level", type=str, dest="level", default='123',
                        help='选择比较的库的级别。值为 1、2、3、12、123、3；1只检查1级库，2只检查2级库，3只检查3级库，123 检查所有库')
    parser.add_argument("-p", "--path", type=str, dest="package_path", required=True, help='输入待测包路径')
    parser.add_argument("-j", "--liblist", type=str, dest="liblist_path", default='Jsons/lib_list_1.0I.json',
                        help='指定liblist.json配置文件的路径')
    parser.add_argument("-o", "--solist", type=str, dest="solist_path", help='指定solist.json配置文件的路径')
    parser.add_argument("-c", "--cmdlist", type=str, dest="cmdlist_path", help='指定cmdlist文本文件的路径')
    parser.add_argument("-a", "--current", type=str, dest="libscan", default='no', help='检查本地库的版本是否符合满足应用要求 yes/no')
    parser.add_argument("-i", "--interface", type=str, dest="interfacescan", default='no', help='应用程序接口级检查 yes/no')
    parser.add_argument("-v", "--version", action='version', version='AppChecker 1.0')
    return parser.parse_args()


def init_package(args):
    # 初始化待测包，创建work space
    package_path = os.path.abspath(args.package_path)
    if not os.path.isfile(package_path):
        raise FileExistsError(f"待测包找不到： {args.package_path}")

    # 获取包名
    get_pkg_name = {
        'dpkg': f'dpkg -f {package_path} Package',
        'rpm': f'rpm -qpi {package_path} |grep Name',
    }
    pkg_name = subprocess.getoutput(get_pkg_name.get(args.pkgmt)).split(':')[-1].strip()
    t = local_time()
    work_space = mkdir(f"workspace/{pkg_name}_{t}")
    output = mkdir(f"Output/{pkg_name}_{t}")

    # 解包到work space目录下package_temp
    target_dir = mkdir(f'{work_space}/PackageSubstance')
    extract_cmd = {
        'dpkg': f'dpkg -x {package_path} {target_dir}',
        'rpm': f'cd {target_dir}; rpm2cpio {package_path} | cpio -di',
    }
    fetch = subprocess.getoutput(extract_cmd.get(args.pkgmt))

    # 遍历package_temp判断类型
    data = {
        'package_name': pkg_name,
        'package_path': package_path,
        'work_space': work_space,
        'output': output,
        'binary': [],
        'shell': [],
        'perl': [],
        'python': [],
        'java': [],
    }
    for root, ds, fs in os.walk(target_dir):
        for f in fs:
            if not os.path.isfile(os.path.join(root, f)):
                continue
            if f.endswith('.sh'):
                fullname = os.path.abspath(os.path.join(root, f))
                data['shell'].append(fullname)
            elif f.endswith('.pl') or f.endswith('.pm'):
                fullname = os.path.abspath(os.path.join(root, f))
                data['perl'].append(fullname)
            elif f.endswith('.py'):
                fullname = os.path.abspath(os.path.join(root, f))
                data['python'].append(fullname)
            elif f.endswith('.java'):
                fullname = os.path.abspath(os.path.join(root, f))
                data['java'].append(fullname)
            else:
                fullname = os.path.abspath(os.path.join(root, f))
                fetch = subprocess.getoutput(f'file {fullname}').split()
                if 'ELF' in fetch:
                    data['binary'].append(fullname)

    # pprint.pprint(data)
    return data


def main(args):
    # 初始化logger
    init_logger()
    logger = logging.getLogger('AppChecker')

    # 开始测试流程
    logger.info('开始执行检查 .................')

    stat = dict()
    # 获取环境信息
    env_info = get_env_info()
    stat['环境信息'] = env_info

    # 待测包文件初始化
    package_detail = init_package(args)
    pprint.pprint(package_detail)

    # 分别测试
    # 测试执行demo
    # if args.get('demo') == 'yes':
    #     stat['demo'] = Checker().check().export(folder=package_detail.get('work_space')).stat()

    # 包 依赖检查
    stat['包依赖检查'] = PkgChecker(package_detail.get('package_path') or [], args.liblist_path, args.type,
                               args.pkgmt).check().export(folder=package_detail.get('output')).stat()
    # 二进制文件 库依赖 检查
    stat['二进制文件检查'] = SoChecker(package_detail.get('binary'), args.liblist_path, args.type).check().export(
        folder=package_detail.get('output')).stat() if package_detail.get('binary') else []

    # shell 文件检查
    stat['shell文件检查'] = ShChecker(args.type, args.cmdlist_path, file_list=package_detail.get('shell') or []).check(
    ).export(folder=package_detail.get('output')).stat()

    # 结果收集输出
    report = Json(f"{package_detail.get('output')}/report.json").write(stat)

    # pprint.pprint(stat)
    print('=' * 90)
    logger.info(f'测试结果为 {stat}')
    logger.info(f'测试完成， 测试报告请查看 {report}')
    logger.info(f'更多详细报告在{package_detail.get("output")}')
    logger.info(f'更多详细日志在logs目录')


if __name__ == '__main__':
    # 参数初始化
    args = init_args()

    # 测试流程
    main(args)
