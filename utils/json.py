# coding=utf-8
"""
@Project : AppChecker
@Time    : 2022/8/8 10:47
@Author  : wangbin
"""
import json


class Json:
    def __init__(self, path):
        self.file = path

    def read(self):
        with open(self.file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data

    def write(self, data: dict):
        with open(self.file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False)
        return self.file
