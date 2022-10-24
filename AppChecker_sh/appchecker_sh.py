# coding=utf-8
"""
Copyright (c) 麒麟软件有限公司 . 2018-2022 . All rights reserved.
AppAPIChecker licensed under the Mulan PSL v2.
You can use this software according to the terms and conditions of the Mulan PSL v2.
You may obtain a copy of Mulan PSL v2 at:
     http://license.coscl.org.cn/MulanPSL2
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
See the Mulan PSL v2 for more details.

@Project : appchecker
@Time    : 2022/9/15 10:37
@Author  : wangbin
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
from utils.json_formatter import format4sh
from utils.logger import init_logger


class ShChecker(Checker):
    def __init__(self, type: str, std_path: str, file: str = None, file_list: list = None):
        # 存储参数，读取标准文件，初始化结果
        super().__init__()
        self.name = __name__
        if file_list:
            self.file_list = file_list
        elif file:
            self.file_list = file
        else:
            self.file_list = []
        self.type = type
        self.std_path = std_path or 'Jsons/cmd_list.json'
        # 初始化logger
        init_logger()
        self.logger = logging.getLogger('AppChecker')

    @staticmethod
    def _get_cmd_list_file(std_path: str):
        std_file_path = os.path.abspath(std_path)
        if not os.path.isfile(std_file_path):
            raise FileExistsError(f'标准文件未找到： {std_file_path}')
        filetype = mimetypes.guess_type(std_path)
        if str(filetype[0]) != 'application/json':
            raise TypeError(f'文件类型错误：{filetype[0]}, 应传入json格式')
        cmd_list_tmp = format4sh(std_file_path)
        return cmd_list_tmp

    def check(self):
        """
        实现对sh文件的检查
        :return: self
        """
        self.logger.info('########## sh 文件依赖检测开始 ##########')
        cmd_list = self._get_cmd_list_file(self.std_path)
        for file in self.file_list:
            result_file = 'pass'
            subprocess.getoutput(f'chmod +x AppChecker_sh/checker_sh/lsbappchk-sh.pl')
            cmd = f'./AppChecker_sh/checker_sh/lsbappchk-sh.pl -o logs/{file}.log -c {cmd_list} {file}'
            fetch = subprocess.getoutput(cmd)
            infos = []
            for line in fetch.split('\n'):
                if line.startswith('[FAIL]'):
                    infos.append(line)
                    result_file = 'fail'
                    self.result['result'] = 'fail'
            info = '\n'.join(infos)
            self.result['data'].append({
                'name': file,
                'result': result_file,
                'info': info
            })
            self.result['result'] = self.result['result'] or 'pass'
        return self


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", nargs='+', dest="file", required=True, help='输入待测文件路径')
    parser.add_argument("-t", "--type", type=str, dest="type", required=True, help='输入操作系统类型 desktop/server')
    parser.add_argument("-c", "--cmdlist", type=str, dest="cmdlist_path", help='指定cmdlist文本文件的路径')
    args = parser.parse_args()

    result = ShChecker(args.type, args.cmdlist_path, file=args.file).check().export().stat()
    print(result)
