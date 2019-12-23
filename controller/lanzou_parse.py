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

class LanzouParse(QObject):
    """
    蓝奏云解析
    """
    futility_signal = pyqtSignal()
    parseCompleteSignal = pyqtSignal(str, arguments=['originUrl'])

    @pyqtSlot(str, name='parse')
    def parse(self, url):
        _thread.start_new_thread(self.__parse, (url,) )

    def __parse(self, url):
        logging.debug("开始解析")
        try:
            originUrl = common.lanzou_download(url)
        except:
            originUrl = ''
        self.parseCompleteSignal.emit(originUrl)
    
    @pyqtSlot(str, name='paste')
    def paste(self, url):
        pyperclip.copy(url)

lanzou_parse_instance = LanzouParse()