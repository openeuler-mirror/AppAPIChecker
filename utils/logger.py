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
@Time    : 2022/8/8 10:39
@Author  : wangbin
"""
import logging.config
import os


def log_handler():
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    formatter = logging.Formatter(f'[%(asctime)s][%(levelname)s][%(message)s]')
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    log_file_path = 'logs/app_checker.txt'
    fh = logging.FileHandler(log_file_path)
    formatter = logging.Formatter(f'[%(asctime)s][%(filename)s:%(lineno)d]:[%(levelname)s][%(message)s]')
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    return logger


LOGGING_CONFIG = {
    "version": 1,
    "formatters": {
        "console": {
            'format': '[%(asctime)s] [AppChecker] [%(levelname)s] %(message)s',
        },
        "file": {
            'format': '[%(asctime)s] [%(filename)s:%(lineno)d]:[%(levelname)s] %(message)s',
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "console",
        },
        "info": {
            'level': 'INFO',
            "class": "logging.handlers.RotatingFileHandler",
            "formatter": "file",
            'filename': os.path.join('logs', "checker_info.log"),
            'encoding': 'utf-8',
        },
        'error': {
            'level': 'ERROR',
            'class': 'logging.handlers.RotatingFileHandler',  # 保存到文件，自动切
            'filename': os.path.join('logs', "checker_error.log"),  # 日志文件
            'maxBytes': 1024 * 1024 * 5,  # 日志大小 50M
            'backupCount': 5,
            'formatter': 'file',
            'encoding': 'utf-8',
        },
    },
    'loggers': {  # 日志实例
        'AppChecker': {  # 默认的logger应用如下配置
            'handlers': ['console', 'info', 'error'],  # 上线之后可以把'console'移除
            'level': 'INFO',
            'propagate': True,  # 是否向上一级logger实例传递日志信息
        },
        'root': {  # 名为 'root' 的logger还单独处理
            'handlers': ['console', 'info', 'error'],
            'level': 'DEBUG',
        }
    },
    "disable_existing_loggers": True,
}


# logger = log_handler()


def init_logger():
    logging.config.dictConfig(LOGGING_CONFIG)
