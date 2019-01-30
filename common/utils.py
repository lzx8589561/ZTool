import ctypes
import inspect
import os
import socket
import time
from os.path import dirname


def net_is_used(port, ip='127.0.0.1'):
    """
    检查端口是否占用（如没被占用会有大概1秒的等待）
    :param port: 端口号
    :param ip: IP地址
    :return: 是/否
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect_ex((ip, port))
        s.shutdown(2)
        print('%s:%d is used' % (ip, port))
        return True
    except:
        print('%s:%d is unused' % (ip, port))
        return False


def kill_progress(progress_name):
    """
    强制停止进程
    """
    cmd = 'chcp 437 && taskkill /f /im \"{0}\" '.format(progress_name)
    tmp = os.popen(cmd).readlines()
    tmp = "".join(tmp).lower()
    if tmp.find('success') != -1:
        return True
    else:
        return False


def msec():
    """
    获取毫秒时间戳
    :return:
    """
    return int(time.time() * 1000)


def class_function_name(cla):
    """
    获取方法名
    :param cla: 实例
    """
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + '  ' + cla.__class__.__name__ + '.' + \
           inspect.stack()[1][3] + ' >> '


def get_file_size(file_path):
    """
    获取文件大小
    :param file_path: 文件路径
    :return: size
    """
    size = os.path.getsize(file_path)
    return size


def is_admin():
    """
    判断当前环境是否为管理员
    :return: bool
    """
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False


def project_path():
    """
    获取项目目录
    :return: path
    """
    return dirname(dirname(__file__))
