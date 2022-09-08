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
@Time    : 2022/8/17 16:34
@Author  : wangbin
"""

import os,sys
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, parentdir)
from utils.myjson import Json


def format4pkg(file, path):
    result = {
        'desktop': {},
        'server': {}
    }
    data = Json(file).read().get('libs').get('category')
    for category, pkg in data.items():
        # print(category, pkg)
        if category.startswith('##'):
            continue
        # if category != 'base':
        #     continue
        for name, info in pkg.get('packages').items():
            # print(name)
            if name.startswith('##'):
                continue
            result['desktop'][name] = {
                'level': info.get('necessity').get('desktop').get('level'),
                'deprecated': info.get('necessity').get('desktop').get('deprecated'),
                'version': info.get('version').get('desktop')
            }
            result['server'][name] = {
                'level': info.get('necessity').get('server').get('level'),
                'deprecated': info.get('necessity').get('server').get('deprecated'),
                'version': info.get('version').get('server')
            }
            # print(name)
            # print(info.get('version'))
            # print(result['desktop'][name])
            # print(result['server'][name])

            # 由于libxcrypt的别名和glibc重复且重要性更低，故先取更高等级的标准，跳过libxcrypt的别名
            if name != 'libxcrypt':
                for alias in info.get('alias'):
                    result['desktop'][alias.get('name')] = {
                        'level': info.get('necessity').get('desktop').get('level'),
                        'deprecated': info.get('necessity').get('desktop').get('deprecated'),
                        'version': alias.get('version').get('desktop')
                    }
                    result['server'][alias.get('name')] = {
                        'level': info.get('necessity').get('server').get('level'),
                        'deprecated': info.get('necessity').get('server').get('deprecated'),
                        'version': alias.get('version').get('server')
                    }
                    # print('alias')
                    # print(alias.get('name'))
                    # print(info.get('version'))
                    # print(result['desktop'][alias.get('name')])
                    # print(result['server'][alias.get('name')])

    Json(f'{path}/pkg_std.json').write(result)


def format4lib(file, path):
    result = {
        'desktop': {},
        'server': {}
    }
    data = Json(file).read().get('libs').get('category')
    for category, pkg in data.items():
        # print(category, pkg)
        if category.startswith('##'):
            continue
        for name, info in pkg.get('packages').items():
            # print(name)'
            if name.startswith('##'):
                continue
            for lib_desktop in info.get('share_objs').get('desktop'):
                # if info.get('necessity').get('desktop_necessity')[2]:
                #     print(info.get('necessity').get('desktop_necessity')[2])
                result['desktop'][lib_desktop] = {
                    'level': info.get('necessity').get('desktop').get('level'),
                    'deprecated': info.get('necessity').get('desktop').get('deprecated'),
                }
                # print('desktop')
                # print(lib_desktop)
                # print(result['desktop'][lib_desktop])
            for lib_server in info.get('share_objs').get('server'):
                result['server'][lib_server] = {
                    'level': info.get('necessity').get('server').get('level'),
                    'deprecated': info.get('necessity').get('server').get('deprecated'),
                }
                # print('server')
                # print(lib_server)
                # print(result['server'][lib_server])

    Json(f'{path}/so_std.json').write(result)


if __name__ == '__main__':
    format4pkg('config/lib_list_1.0I(20220826).json', './')
    format4lib('config/lib_list_1.0I(20220826).json', './')