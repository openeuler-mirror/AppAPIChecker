# coding=utf-8
"""
@Project : AppChecker
@Time    : 2022/8/11 14:30
@Author  : wangchunli
"""
import logging
import mimetypes
import os
import re
import subprocess

from checker import Checker
from utils.logger import init_logger
from utils import json_formatter


def _version_compare(version1: str, version2: str):
    """
    比较两个版本的大小
    :param version1:
    :param version2:
    :return:
        1: version1 > version2
        0: version1 = version2
        -1: version1 < version2
    """
    if version1 == version2:
        return 0
    else:
        max_version = subprocess.getoutput(r'echo "{} {}" | tr \' \' \'\n\' | sort -V | tr \'\n\' \' \' | awk \'{{'
                                           r'print $1}}\''.format(version1, version2))
        if max_version == version1:
            return 1
        else:
            return 0


def _generate_detail_json(item: str, level: str, result: str, info: str = ''):
    return {'item': item, 'level': level, 'result': result, 'info': info, }


def get_deb_depends(file: str):
    """
    获取deb包依赖
    :param file: deb包文件
    :return deb_list: 依赖包列表
    """
    deb_list_json = []
    pre_dep_list = re.split('[,|]', subprocess.getoutput(
        'apt show {} | grep Pre-Depends | sed \'s/ //g\' | awk -F \':\' \'{{print $2}}\''.format(file)).split('\n')[-1])
    if pre_dep_list != ['']:
        for deb in pre_dep_list:
            if deb.find('(') != -1:
                data = {'name': re.findall(r'(.*)\(', deb)[0], 'limit': re.findall(r'\((.?=)\s?', deb)[0],
                        'version': re.findall(r'=\s?(.*)\)', deb)[0]}
            else:
                data = {'name': deb, 'limit': '', 'version': ''}
            deb_list_json.append(data)

    dep_list = re.split('[,|]', subprocess.getoutput(
        'apt show {} | grep ^Depends | sed \'s/ //g\' | awk -F \':\' \'{{print $2}}\''.format(file)).split('\n')[-1])
    print(dep_list)
    if dep_list != ['']:
        for deb in dep_list:
            if deb.find('(') != -1:
                data = {'name': re.findall(r'(.*)\(', deb)[0], 'limit': re.findall(r'\((.?=)\s?', deb)[0],
                        'version': re.findall(r'=\s?(.*)\)', deb)[0]}
            else:
                data = {'name': deb, 'limit': '', 'version': ''}
            deb_list_json.append(data)

    return deb_list_json


def get_rpm_depends(file: str):
    """
    获取deb包依赖
    :param file: rpm包文件
    :return deb_list: 依赖列表
    """

    rpm_depends = subprocess.getoutput(
        'rpm -qpR {} | awk -F \'(\' \'{{print $1}}\' | awk \'{{print $1}}\'| uniq'.format(file)).split('\n')
    rpm_depends.pop(0)
    return rpm_depends


def deb_check(checker: Checker, name: str, checklist: list):
    """
    检查deb包依赖是否合规
    :param checker: 检查类对象
    :param name:源文件
    :param checklist: 待检查依赖列表
    :return:
    """
    warning_num = 0
    data = {'name': name, 'result': '', 'detail': []}
    if checklist:
        for pkg in checklist:
            pkgname = pkg['name']
            limit = pkg['limit']
            version = pkg['version']
            checker.logger.info('### 正在检查' + pkgname + ' ###')
            # 具体的检查步骤
            # print(checker.stdfile.keys())
            if pkgname not in checker.stdfile.keys():
                checker.logger.info('该包未在标准中')
                checker.logger.info('结果为warning')
                detail = _generate_detail_json(pkgname, 'none', 'warning', '该包为不推荐使用的包，请您使用标准中的包')
                warning_num += 1
            else:
                level = checker.stdfile[pkgname]['level']
                if checker.stdfile[pkgname]['deprecated'] == 'true':
                    checker.logger.info('该包即将废弃')
                    checker.logger.info('结果为warning')
                    detail = _generate_detail_json(pkgname, level, 'warning', '该包即将在下一版标准中废弃，不推荐使用')
                    warning_num += 1
                else:
                    if level == 'L1' or level == 'L2':
                        if limit == '':
                            checker.logger.info('依赖版本没有要求')
                            checker.logger.info('结果为pass')
                            detail = _generate_detail_json(pkgname, level, 'pass')
                        elif limit == '>=':
                            # 版本比较
                            std_version = checker.stdfile[pkgname]['version']
                            result = _version_compare(version, std_version)
                            if result == 0:
                                checker.logger.info('依赖版本符合版本')
                                checker.logger.info('结果为pass')
                                detail = _generate_detail_json(pkgname, level, 'pass')
                            elif result < 0:
                                checker.logger.info('依赖版本要求 ' + level + ' 低于 ' + std_version)
                                checker.logger.info('结果为warning')
                                detail = _generate_detail_json(pkgname, level, 'warning',
                                                               '依赖版本要求 ' + level + ' 低于 ' + std_version)
                                warning_num += 1
                            else:
                                checker.logger.info('依赖版本要求 ' + level + ' 高于 ' + std_version)
                                checker.logger.info('结果为warning')
                                detail = _generate_detail_json(pkgname, level, 'warning',
                                                               '依赖版本要求 ' + level + ' 高于 ' + std_version)
                                warning_num += 1
                        else:
                            checker.logger.info('依赖版本要求过严')
                            checker.logger.info('结果为warning')
                            detail = _generate_detail_json(pkgname, level, 'warning', '该依赖要求版本过严，建议修改')
                            warning_num += 1
                    else:
                        checker.logger.info('该包系统不保证兼容')
                        checker.logger.info('结果为warning')
                        detail = _generate_detail_json(pkgname, level, 'warning', '该包系统不保证兼容，不推荐使用')
                        warning_num += 1
            data['detail'].append(detail)
            checker.logger.info('### ' + pkgname + ' 检查完毕 ###')
    else:
        checker.logger.info('### ' + name + '没有依赖 ###')

    if warning_num != 0:
        data['result'] = 'warning'
    else:
        data['result'] = 'pass'

    checker.result['data'].append(data)

    return data['result']


class PkgChecker(Checker):
    def __init__(self, file: str, stdfilepath: str, standard: str, pkgmt: str):
        """
        初始化一个空的结果，result demo如下
        result = {
            'result': 'pass/fail',
            data': [
                {
                    'name': 'run.sh',
                    'result': 'fail',
                    'detail': [
                        {'item': line 99,
                        'result': 'fail'
                        'info': 'xxxxx',
                        },
                        {}
                    ]
                }， ... ...
            ]
        }
        """
        # 存储参数，读取标准文件，初始化结果
        super().__init__()

        self.file = file
        if pkgmt == 'dpkg':
            json_formatter.format4pkg(stdfilepath, 'AppChecker_C')
            self._get_filelist('AppChecker_C/pkg_std.json', standard)
        else:
            pass
            # json_formatter.format4lib(stdfilepath, 'AppChecker_C')
            # self._get_filelist('AppChecker_C/so_std.json', standard)
        self.pkgmt = pkgmt
        self.name = __name__
        # 初始化logger
        init_logger()
        self.logger = logging.getLogger('AppChecker')

    def _get_filelist(self, stdfilepath: str, standard: str):
        std_file_path = os.path.abspath(stdfilepath)
        if not os.path.isfile(std_file_path):
            raise FileExistsError(f'标准文件未找到： {std_file_path}')
        filetype = mimetypes.guess_type(stdfilepath)
        if str(filetype[0]) != 'application/json':
            raise TypeError(f'文件类型错误：{filetype[0]}, 应传入json格式')
        self.stdfilepath = stdfilepath
        self.stdfile = Checker._get_standard(self.stdfilepath)[standard]

    def check(self):
        """
        实现对包依赖的检查，获取依赖的方式：u系用dpkg-rdepends，r系用deplist
        :return: self
        """
        self.logger.info('########## 软件包依赖检测开始 ##########')
        # 判断包格式
        self.logger.info('##### 正在检查包 ' + self.file + ' #####')
        if self.pkgmt == 'dpkg':
            if re.match(r'.*\.deb$', self.file):
                pkg_depends = get_deb_depends(self.file)
                self.logger.info('获取到依赖包列表 ' + str(pkg_depends))

                result = deb_check(self, self.file, pkg_depends)
            else:
                self.logger.info(self.file + '不适用于本架构')
        # elif self.pkgmt == 'rpm':
        #     if re.match(r'.*\.rpm$', self.file):
        #         # 获取依赖
        #         rpm_depends = get_rpm_depends(self.file)
        #         self.logger.info('获取到依赖列表 ' + str(rpm_depends))
        #
        #         result = so_check(self, self.file, rpm_depends)
        else:
            self.logger.warning('本包格式暂不支持')
            result = 'warning'

        self.result['result'] = result

        self.logger.info('##### 包 ' + self.file + ' 检测完毕 #####')
        self.logger.info('########## 软件包依赖检测完成 ##########')
        # print(json.dumps(self.result, indent=4, ensure_ascii=False))
        return self
