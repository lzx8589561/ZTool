import _thread
import logging
import os
import time
from os.path import abspath, join

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot
from pyaria2 import Aria2RPC

import common

class HostEdit(QObject):
    """
    host文件编辑
    """

    @pyqtSlot(result=str,name='read')
    def parse(self):
        f = open("C:/Windows/System32/drivers/etc/hosts",'r')
        content = f.read()
        return content

    @pyqtSlot(str,result=str,name='write')
    def write(self, content):
        try:
            f = open("C:/Windows/System32/drivers/etc/hosts",'w')
            f.write(content)
            f.close()
        except:
            return 'error'
        return 'success'

host_edit_instance = HostEdit()