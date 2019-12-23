import _thread
import logging
import os
import subprocess
import time
from os.path import abspath, join

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot
from pyaria2 import Aria2RPC
from pynput.keyboard import Controller, Key, Listener
import win32gui

import common
from .setting import setting_instance

global_listener = None

# 监听按压
def on_p(key):
    try:
        hwnd = win32gui.GetForegroundWindow()
        app = win32gui.GetWindowText(hwnd)
        logging.debug("P - {0}\t{1}".format(app,format(key.char)))
    except AttributeError:
        logging.debug("P - {0}".format(format(key)))


# 监听释放
def on_r(key):
    try:
        hwnd = win32gui.GetForegroundWindow()
        app = win32gui.GetWindowText(hwnd)
        logging.debug("R - {0}\t{1}".format(app,format(key.char)))
    except AttributeError:
        logging.debug("R - {0}".format(format(key)))

    # if key == Key.esc:
        # 停止监听
        # return False


# 开始监听
def start_listen():
    with Listener(on_press=on_p, on_release=on_r) as listener:
        global global_listener
        global_listener = listener
        listener.join()
        # if not setting_instance.settings['listenkeyboard']:
        #     listener.stop()


class KeyboardListener(QObject):
    """
    键盘监听
    """
    futility_signal = pyqtSignal()
    parseCompleteSignal = pyqtSignal(str, arguments=['originUrl'])

    def __init__(self, parent=None):
        super().__init__(parent)
        if setting_instance.settings['listenkeyboard']:
            self.listener(True)


    @pyqtSlot(bool, name='listener')
    def listener(self, status):
        global global_listener
        try:
            global_listener.stop()
        except:
            pass
        if status:
            _thread.start_new_thread(start_listen, () )


keyboard_listener_instance = KeyboardListener()