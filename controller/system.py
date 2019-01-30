import getpass
import platform

from PyQt5.QtCore import pyqtProperty, QObject, pyqtSignal


class System(QObject):
    """
    系统信息
    """
    futility_signal = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        # Initialise the value of the properties.
        self._username = getpass.getuser()
        self._platform = platform.platform()

    @pyqtProperty('QString', notify=futility_signal)
    def username(self):
        return self._username

    @pyqtProperty('QString', notify=futility_signal)
    def platform(self):
        return self._platform


system_instance = System()
