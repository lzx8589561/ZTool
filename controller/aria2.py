import _thread
import logging
import os
import subprocess
import time
from os.path import abspath, join

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot
from pyaria2 import Aria2RPC

import common


class Aria2(QObject):
    """
    下载控制器
    """
    processSignal = pyqtSignal(QVariant, arguments=['process'])
    taskStateSignal = pyqtSignal(str, QVariant, arguments=['gid', 'process'])
    msgSignal = pyqtSignal(str, arguments=['msg'])
    flagMsgSignal = pyqtSignal(str, str, str, arguments=['msg', 'flag', 'taskId'])
    listenerUrl = pyqtSignal(str, arguments=['url'])
    aria2_path = abspath(join(common.project_path(), 'aria2', 'aria2c.exe'))
    default_config = {
        # 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
        'dir': 'aria2/Download',
        # 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
        'disk-cache': '32M',
        # 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
        # 预分配所需时间: none < falloc < trunc < prealloc
        # NTFS建议使用falloc
        'file-allocation': 'none',
        # 断点续传
        'continue': 'true',
        # 最大同时下载任务数, 运行时可修改, 默认:5
        'max-concurrent-downloads': '5',
        # 同一服务器连接数, 添加时可指定, 默认:1
        'max-connection-per-server': '16',
        # 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
        # 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
        'min-split-size': '10M',
        # 单个任务最大线程数, 添加时可指定, 默认:5
        'split': '100',
        # 整体上传速度限制, 运行时可修改, 默认:0
        'max-overall-upload-limit': '1M',
        # 禁用IPv6, 默认:false
        'disable-ipv6': 'true',
        # 从会话文件中读取下载任务
        'input-file': 'aria2/aria2.session',
        # 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
        'save-session': 'aria2/aria2.session',
        # 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
        'save-session-interval': '60',
        # 启用RPC, 默认:false
        'enable-rpc': 'true',
        # rpc端口
        'rpc-listen-port': '6800',
        # 允许所有来源, 默认:false
        'rpc-allow-origin-all': 'true',
        # 允许非外部访问, 默认:false
        'rpc-listen-all': 'true',
    }

    def __init__(self, parent=None):
        super().__init__(parent)
        self.popen = None
        # 启动aria2
        _thread.start_new_thread(self.start_aria2, ())

        # 启动监听剪贴板
        _thread.start_new_thread(self.listener_paste, ())

    @pyqtSlot(str, name='openDir')
    def open_dir(self, file_path):
        if file_path.find(':') != -1:
            path = r'/select,' + abspath(file_path)
        else:
            path = r'/select,' + abspath(join(common.project_path(), file_path))
        os.system("explorer.exe %s" % path)

    def start_aria2(self):
        """
        启动aria2 需要开启新线程启动，会阻塞
        """
        # 干掉上次的aria2进程
        common.kill_progress('aria2c.exe')

        args = []
        for item in self.default_config.items():
            args.append('--' + item[0] + '=' + item[1])

        args.insert(0, self.aria2_path)
        popen = subprocess.Popen(args,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 # bufsize=1,
                                 creationflags=subprocess.CREATE_NO_WINDOW)
        self.popen = popen
        # 重定向标准输出 None表示正在执行中
        while popen.poll() is None:
            r = popen.stdout.readline().decode('utf8')
            if r.replace('\r', '').replace('\n', '').strip(' ') != '':
                logging.debug(r.replace('\n', ''))

    @pyqtSlot(name='stopAria2')
    def stop_aria2(self):
        """
        停止aria2 子进程
        """
        if self.popen is not None:
            self.popen.kill()

    @pyqtSlot(str, QVariant, name='addTask')
    def add_task(self, url, options=None):
        """
        添加任务
        :param url: 文件地址
        :param options: 可选项
        """
        _thread.start_new_thread(self.__add_task, (url, options, None))

    @pyqtSlot(str, str, name='addFlagTask')
    def add_flag_task(self, url, flag, options=None):
        """
        添加任务
        :param flag: 标志
        :param url: 文件地址
        :param options: 可选项
        """
        _thread.start_new_thread(self.__add_task, (url, options, flag))

    def __add_task(self, url, options, flag):
        aria2 = Aria2RPC()
        if options is None:
            options = {}
        else:
            options = options.toVariant()

        try:
            id = aria2.addUri([url], options=options)
            if flag is None:
                self.msgSignal.emit("addSuccess")
            else:
                self.flagMsgSignal.emit("addSuccess", flag, id)

        except:
            if flag is None:
                self.msgSignal.emit("addFail")
            else:
                self.flagMsgSignal.emit("addFail", flag, None)

    @pyqtSlot(str, name='pauseTask')
    def pause_task(self, gid):
        """
        暂停任务
        :param gid: 主键
        """
        _thread.start_new_thread(self.__pause_task, (gid,))

    def __pause_task(self, gid):
        aria2 = Aria2RPC()
        try:
            aria2.pause(gid)
            self.msgSignal.emit("pauseSuccess")
        except:
            self.msgSignal.emit("pauseFail")

    @pyqtSlot(str, name='unpauseTask')
    def start_task(self, gid):
        """
        开始任务
        :param gid: 主键
        """
        _thread.start_new_thread(self.__start_task, (gid,))

    def __start_task(self, gid):
        aria2 = Aria2RPC()
        try:
            aria2.unpause(gid)
            self.msgSignal.emit("startSuccess")
        except:
            self.msgSignal.emit("startFail")

    @pyqtSlot(str, name='removeTask')
    def remove_task(self, gid):
        """
        删除任务
        :param gid: 主键
        """
        _thread.start_new_thread(self.__remove_task, (gid,))

    def __remove_task(self, gid):
        aria2 = Aria2RPC()
        try:
            aria2.remove(gid)
            self.msgSignal.emit("removeSuccess")
        except:
            self.msgSignal.emit("removeFail")

    @pyqtSlot(name='selTask')
    def sel_task(self):
        """
        查询当前任务的状态
        """
        _thread.start_new_thread(self.__sel_task, ())

    @pyqtSlot(str, name='selTaskById')
    def sel_task_id(self, gid):
        """
        查询任务的状态
        """
        _thread.start_new_thread(self.__sel_task_id, (gid,))

    def __sel_task_id(self, gid):
        aria2 = Aria2RPC()
        file_state = aria2.getFiles(gid)
        self.taskStateSignal.emit(gid, QVariant(file_state))

    def __sel_task(self):
        aria2 = Aria2RPC()
        res = aria2.multicall([{'methodName': 'aria2.getGlobalStat'},
                               {'methodName': 'aria2.tellActive'},
                               {'methodName': 'aria2.tellWaiting', 'params': [0, 1000]},
                               {'methodName': 'aria2.tellStopped', 'params': [0, 1000]}
                               ])
        self.processSignal.emit(QVariant(res))

    def listener_paste(self):
        """
        监听剪贴板
        """
        recent_value = ''
        while True:
            tmp_value = pyperclip.paste()  # 读取剪切板复制的内容
            try:
                if tmp_value != recent_value:  # 如果检测到剪切板内容有改动，那么就进入文本的修改
                    recent_value = tmp_value
                    if recent_value.startswith('http://') or recent_value.startswith('https://'):
                        logging.debug("发现链接:" + recent_value)
                        self.listenerUrl.emit(recent_value)
            except:
                pass
            time.sleep(0.1)


aria2_instance = Aria2()
