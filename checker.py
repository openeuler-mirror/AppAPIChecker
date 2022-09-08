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
@Time    : 2022/8/8 11:29
@Author  : wangbin
"""
from abc import ABC, abstractmethod
from utils.myjson import Json


class Checker(ABC):
    def __init__(self):
        """
        初始化一个空的结果，result demo如下
        result = {
            'result': 'pass/fail',
            'data': [
                {
                    'name': 'xxxxfile',
                    'result': 'pass',
                    'std': 'xxxx',
                    'act': 'xxxx'
                }， ... ...
            ]
        }
        """
        self.result = {
            'result': 'pass',
            'data': []
        }

    @staticmethod
    def _get_standard(standard_path):
        """
        去读json文件，处理为dict
        :param standard_path: 标准文件路径
        :return: 标准文件的dict格式
        """
        return Json(standard_path).read()

    @abstractmethod
    def check(self):
        """
        需重新实现check方法， 完成检查逻辑
        :return: self
        """
        return self

    def export(self, folder=None):
        """
        把待测包在该checker的测试结果json文件输出到待测包结果文件夹
        :param folder: 输出报告所在的待测包结果文件夹
        :return: self
        """
        folder = folder or 'report'
        Json(f'{folder}/{self.__class__.__name__}.json').write(self.result)
        return self

    def stat(self):
        """
        把待测包在该checker的测试结果统计数据返回
        :return: 统计数据
        """
        stats = dict()
        for item in self.result.get('data'):
            stats[item.get('result')] = stats[item.get('result')] + 1 if stats.get(item.get('result')) else 1
        return stats

