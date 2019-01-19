import _thread
import ctypes
import sys

from PyQt5.QtCore import QUrl, QCoreApplication, Qt, QTranslator
from PyQt5.QtGui import QGuiApplication, QIcon
from PyQt5.QtQml import QQmlApplicationEngine
# noinspection PyUnresolvedReferences
from PyQt5.QtWebEngineWidgets import QWebEngineView

from mysql_configuration import MysqlConfiguration
from mysql_service_manager import MysqlServiceManager
from qml_language import QmlLanguage
from setting import Setting
from system import System
# noinspection PyUnresolvedReferences
from ui.qml_rc import *
qml_start_time = 0


def is_admin():
    """
    判断当前环境是否为管理员
    :return: bool
    """
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False


if __name__ == '__main__':
    if is_admin():

        QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling, True)
        path = 'qrc:/Main.qml'  # 加载的QML文件
        app = QGuiApplication(sys.argv)
        app.setWindowIcon(QIcon(':/img/icon.ico'))
        engine = QQmlApplicationEngine()
        context = engine.rootContext()

        setting = Setting()
        mysqlServiceManager = MysqlServiceManager(setting)
        mysqlConfiguration = MysqlConfiguration()
        system = System()

        context.setContextProperty("mysqlServiceManager", mysqlServiceManager)
        context.setContextProperty("mysqlConfiguration", mysqlConfiguration)
        context.setContextProperty("system", system)
        context.setContextProperty("setting", setting)

        # Mysql状态检测线程
        _thread.start_new_thread(mysqlServiceManager.status_update_thread, ())

        # 设置语言 初始化加载
        lang = QmlLanguage(app, engine)
        translator = QTranslator()
        # noinspection PyPropertyAccess
        lang.load_translator(translator, setting.lang)
        app.installTranslator(translator)
        context.setContextProperty("lang", lang)
        engine.load(QUrl(path))
        if not engine.rootObjects():
            sys.exit(-1)
        sys.exit(app.exec_())
    else:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, __file__, None, 1)
