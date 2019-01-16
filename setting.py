import os

import yaml
from PyQt5.QtCore import pyqtProperty, QObject, pyqtSignal


class Setting(QObject):
    """
    软件设置
    """
    yaml_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "setting.yaml")
    futility_signal = pyqtSignal()
    settings = {
        'autostarts': 1,
        'lang': 1,
        'opacity': 0.98,
        'service': 'MysqlServer56',
        'top': True
    }

    def __init__(self, parent=None):
        super().__init__(parent)
        exists = os.path.exists(self.yaml_path)
        if not exists:
            self.save_cfg()

        with open(self.yaml_path, "r", encoding="utf-8") as f:
            self.settings = yaml.load(f)

    def save_cfg(self):
        with open(self.yaml_path, "w", encoding="utf-8") as f:
            yaml.dump(self.settings, f, default_flow_style=False)

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


if __name__ == '__main__':
    ss = Setting()
    print(ss.settings)
