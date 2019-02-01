import logging
import sys
from os.path import exists, abspath

from .utils import *
from logging.handlers import TimedRotatingFileHandler

# 初始化
os.chdir(abspath(dirname(sys.argv[0])))
if not exists('log'):
    os.mkdir('log')
formatter = logging.Formatter("%(asctime)s %(levelname)s - %(funcName)s line %(lineno)d : %(message)s")
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
# 控制台日志
console_log = logging.StreamHandler()
console_log.setLevel(logging.DEBUG)
console_log.setFormatter(formatter)
logger.addHandler(console_log)
# 文件日志 按天生成
file_log = TimedRotatingFileHandler("log/runtime.log", when='D', encoding="utf-8")
file_log.setLevel(logging.DEBUG)
file_log.setFormatter(formatter)
logger.addHandler(file_log)
