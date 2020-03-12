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
    
    @pyqtSlot(name='chromeRendererCodeIntegrityEnabled')
    def chromeRendererCodeIntegrityEnabled(self):
        try:
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"Software\Policies",
                            access=winreg.KEY_WRITE)
            try:
                winreg.CreateKey(key, r"Google\Chrome")
            except:
                pass

            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"Software\Policies\Google\Chrome",
                            access=winreg.KEY_WRITE)
            winreg.SetValueEx(key, "RendererCodeIntegrityEnabled", 0, winreg.REG_DWORD, 0)
            key.Close()
        except:
            pass

crack_instance = Crack()