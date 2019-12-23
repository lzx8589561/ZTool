import os
import sys
import winreg

import yaml
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot

import common

class Crack(QObject):
    """
    破解相关
    """

    @pyqtSlot(name='beyondCompare4')
    def beyondCompare4(self):
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Scooter Software\Beyond Compare 4",
                            access=winreg.KEY_WRITE)
            winreg.DeleteValue(key, "CacheID")
        except:
            pass

crack_instance = Crack()