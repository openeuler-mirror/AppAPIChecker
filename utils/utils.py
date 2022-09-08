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
@Time    : 2022/8/8 16:56
@Author  : wangbin
"""
import os
import time
import subprocess


def mkdir(path):
    """
    创建文件夹 并返回该文件夹绝对路径
    :param path:
    :return:
    """
    if not os.path.isdir(path):
        os.mkdir(path)
    return os.path.abspath(path)


def local_time():
    """
    获取当前日期
    :return: str 时间字符串， 格式为:%Y-%m-%d-%H-%M-%S
    """
    return time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())


def get_env_info():
    """
    获取当前操作系统 发行版和版本
    :return:
    """
    info_list = [x for x in subprocess.getoutput('cat /etc/os-release').split('\n') if '=' in x]
    info = dict()
    for i in info_list:
        info[i.split('=')[0].strip()] = i.split('=')[-1].strip().replace('\"', '').replace('\"', '')
    return info

