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
@Time    : 2022/8/8 10:45
@Author  : wangbin
"""
import os
import csv


class CSV:
    def __init__(self, file):
        self.file = file

    def read(self):
        if not os.path.isfile(self.file):
            return []
        with open(self.file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            # print(type(reader), reader)
            return [x for x in reader]

    def write(self, content):
        header = True if not os.path.isfile(self.file) else False
        with open(self.file, 'a+', newline='', encoding='utf-8-sig')as f:
            fnames = content.keys()
            writer = csv.DictWriter(f, fieldnames=fnames)
            if header:
                writer.writeheader()
            writer.writerow(content)

    def write_list(self, content, titles):
        with open(self.file, 'a', newline='', encoding='utf-8-sig')as f:
            writer = csv.DictWriter(f, titles)
            writer.writeheader()
            for row in content:
                writer.writerow(row)

