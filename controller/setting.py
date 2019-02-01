import os
import sys
import winreg

import yaml
from PyQt5.QtCore import pyqtProperty, QObject, pyqtSignal

import common


class Setting(QObject):
    """
    软件设置
    """
    yaml_path = os.path.join(common.project_path(), "setting.yaml")
    program_path = sys.argv[0]
    futility_signal = pyqtSignal()
    settings = {
        'autostarts': 1,
        'lang': 1,
        'opacity': 0.98,
        'service': 'MysqlServer56',
        'top': False,
        'block_size': 2,
        'init': True,
        'log': True,
        'autostart': False
    }

    def __init__(self, parent=None):
        super().__init__(parent)
        self.background_run_param = False
        exists = os.path.exists(self.yaml_path)
        if not exists:
            self.save_cfg()

        with open(self.yaml_path, "r", encoding="utf-8") as f:
            self.settings = yaml.load(f)

    def save_cfg(self):
        with open(self.yaml_path, "w", encoding="utf-8") as f:
            yaml.dump(self.settings, f, default_flow_style=False)

    @pyqtProperty(bool, notify=futility_signal)
    def background_run(self):
        return self.background_run_param

    @pyqtProperty(int, notify=futility_signal)
    def lang(self):
        return self.settings['lang']

    @lang.setter
    def lang(self, val):
        self.settings['lang'] = val
        self.save_cfg()

    @pyqtProperty(float, notify=futility_signal)
    def opacity(self):
        return self.settings['opacity']

    @opacity.setter
    def opacity(self, val):
        self.settings['opacity'] = val
        self.save_cfg()

    @pyqtProperty(int, notify=futility_signal)
    def autostarts(self):
        return self.settings['autostarts']

    @autostarts.setter
    def autostarts(self, val):
        self.settings['autostarts'] = val
        self.save_cfg()

    @pyqtProperty(str, notify=futility_signal)
    def service(self):
        return self.settings['service']

    @service.setter
    def service(self, val):
        self.settings['service'] = val
        self.save_cfg()

    @pyqtProperty(bool, notify=futility_signal)
    def top(self):
        return self.settings['top']

    @top.setter
    def top(self, val):
        self.settings['top'] = val
        self.save_cfg()

    @pyqtProperty(bool, notify=futility_signal)
    def init(self):
        return self.settings['init']

    @init.setter
    def init(self, val):
        self.settings['init'] = val
        self.save_cfg()

    @pyqtProperty(bool, notify=futility_signal)
    def autostart(self):
        return self.settings['autostart']

    @autostart.setter
    def autostart(self, val):
        self.settings['autostart'] = val
        self.save_cfg()
        # 设置开机自启动
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                             access=winreg.KEY_WRITE)
        if val:
            winreg.SetValueEx(key, "ZTool", 0, winreg.REG_SZ, '"{0}" background'.format(self.program_path))
        else:
            try:
                winreg.DeleteValue(key, "ZTool")
            except:
                pass


setting_instance = Setting()
