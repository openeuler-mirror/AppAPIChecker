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
@Time    : 2022/8/11 14:30
@Author  : wangchunli
"""
import argparse
import logging
import mimetypes
import re
import subprocess

import os,sys
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, parentdir)
from checker import Checker
from utils import json_formatter
from utils.logger import init_logger


def _generate_detail_json(item: str, level: str, result: str, info: str = ''):
    return {'item': item, 'level': level, 'result': result, 'info': info, }


def so_check(checker: Checker, name: str, checklist: list, std_list=[]):
    """
        检查一个文件的依赖so，自包含检查
        :param checker: 检查类对象
        :param name:源文件
        :param checklist: 待检查依赖列表
        :param std_list: 包内so列表，用于检查自包含
        :return:
        """
    warning_num = 0
    data = {'name': name, 'result': '', 'detail': []}
    for so in checklist:
        checker.logger.info('### 正在检查' + so + ' ###')
        # 具体的检查步骤
        if so not in checker.stdfile.keys():
            checker.logger.info('该库未在标准中')
            if so in std_list:
                checker.logger.info('库自包含')
                checker.logger.info('结果为pass')
                detail = _generate_detail_json(so, 'none', 'pass')
            else:
                checker.logger.info('库未自包含')
                checker.logger.info('结果为warning')
                detail = _generate_detail_json(so, 'none', 'warning', '本库系统不保证兼容，建议您将对应库放入包中')
                warning_num += 1
        else:
            level = checker.stdfile[so]['level']
            if checker.stdfile[so]['deprecated'] is True:
                checker.logger.info('该库即将在下一个版本废弃')
                detail = _generate_detail_json(so, level, 'warning', '该库即将在下一个版本中废弃，不建议使用')
            else:
                checker.logger.info('库等级为' + level)
                if level == 'L1' or level == 'L2':
                    if so in std_list:
                        checker.logger.info('库自包含')
                        checker.logger.info('结果为warning')
                        detail = _generate_detail_json(so, level, 'warning', '本库系统已支持，不建议放入包中')
                        warning_num += 1
                    else:
                        checker.logger.info('库未自包含')
                        checker.logger.info('结果为pass')
                        detail = _generate_detail_json(so, level, 'pass')
                else:
                    if so in std_list:
                        checker.logger.info('库自包含')
                        checker.logger.info('结果为pass')
                        detail = _generate_detail_json(so, level, 'pass')
                    else:
                        checker.logger.info('库未自包含')
                        checker.logger.info('结果为warning')
                        detail = _generate_detail_json(so, level, 'warning', '本库系统不保证兼容，建议您将对应库放入包中')
                        warning_num += 1

        data['detail'].append(detail)
        checker.logger.info('### ' + so + ' 检查完毕 ###')

    if warning_num != 0:
        data['result'] = 'warning'
    else:
        data['result'] = 'pass'

    checker.result['data'].append(data)

    return data['result']


class SoChecker(Checker):
    def __init__(self, filelist: list, stdfilepath: str, standard: str):
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
                        'level':'L0',
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
        stdfilepath = stdfilepath or os.path.abspath('Jsons/lib_list_1.0I.json')
        json_formatter.format4lib(stdfilepath, 'AppChecker_C')
        self.name = __name__
        self.filelist = filelist
        self._get_standard('AppChecker_C/so_std.json', standard)
        # 初始化logger
        init_logger()
        self.logger = logging.getLogger('AppChecker')

    def _get_standard(self, stdfilepath: str, standard: str):
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
        实现对so文件的检查，包括依赖和包中自带的
        :return: self
        """
        self.logger.info('########## ELF文件依赖检测开始 ##########')
        so_list = [os.path.basename(file) for file in self.filelist if re.match(r'.*\.so.*$', file)]
        self.logger.info('包内so文件列表 ' + str(so_list))
        warning_num = 0
        # 循环读取文件
        for file in self.filelist:
            # 判断文件类型为elf文件
            self.logger.info('##### 正在检查文件 ' + file + ' #####')
            filetype = subprocess.getoutput('file {} | awk \'{{print $2}}\''.format(file))
            if filetype != 'ELF':
                self.logger.warning('文件类型不在检测范围内：' + filetype)
            else:
                # 取[]中间的内容
                so_depends = re.findall(r"\[(.*)]", subprocess.getoutput(
                    'readelf -d {} | grep NEEDED'.format(file)), re.M)
                if so_depends is not None:
                    self.logger.info('获取到依赖so列表' + str(so_depends))
                    depends_result = so_check(self, file, so_depends, so_list)
                else:
                    self.logger.info('本文件无依赖so')
                    depends_result = 'pass'

                if depends_result == 'warning':
                    warning_num += 1

            self.logger.info('##### 文件 ' + file + ' 检查完毕 #####')

        # 补充本包内so的检查
        self.logger.info('##### 检测包内so文件列表 #####')
        # print(so_list)
        if so_list:
            depends_result = so_check(self, 'other', so_list, so_list)
            if depends_result == 'warning':
                warning_num += 1
            self.logger.info('#####包内so文件列表检查完毕#####')
            if warning_num != 0:
                self.result['result'] = 'warning'
            else:
                self.result['result'] = 'pass'
        else:
            self.logger.info("##### 包内无so文件 #####")

        # print(json.dumps(self.result, indent=4, ensure_ascii=False))
        self.logger.info('########## ELF文件依赖检测完毕 ##########')
        # Json("./result.json").write(self.result)
        return self


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--files", nargs='+', dest="files", required=True, help='输入待测文件列表')
    parser.add_argument("-s", "--stdfile", type=str, dest="stdfile", required=False, help='输入使用标准文件路径')
    parser.add_argument("-t", "--standard", type=str, dest="standard", required=True,
                        help='输入评估待测包使用的标准 desktop/server')

    args = parser.parse_args()

    # print(args.files, args.standard, args.stdfile)
    # binary = ["/home/kylin/桌面/tmp/opt/apps/com.qihoo.360zip/files/360zip/7z.so",
    #           "/home/kylin/桌面/tmp/opt/apps/com.qihoo.360zip/files/360zip/360zip",
    #           "/home/kylin/桌面/tmp/opt/apps/com.qihoo.360zip/files/360zip/Codecs/Rar.so",
    #           "/home/kylin/桌面/tmp/opt/apps/com.qihoo.360zip/entries/plugins/menu/libdfm-360zip.so",
    #           "/home/kylin/桌面/tmp.txt"]
    # print(args.files)
    result = SoChecker(args.files, args.stdfile, args.standard).check().export().stat()
    print(result)
