from PyQt5.QtCore import pyqtProperty, QObject, pyqtSlot, pyqtSignal, QTranslator


class QmlLanguage(QObject):
    """
    多语言切换
    """
    langSignal = pyqtSignal()

    def __init__(self, app, engine, parent=None):
        super().__init__(parent)
        self._app = app
        self._engine = engine
        self._curr_lang = 0

    @pyqtSlot(int, name='setLanguage')
    def set_language(self, index):
        self._curr_lang = index
        translator = QTranslator()
        self.load_translator(translator, index)
        self._app.installTranslator(translator)
        self._engine.retranslate()
        self.langSignal.emit()

    @staticmethod
    def load_translator(translator, index):
        if index == 0:
            translator.load(':/locales/en_us.qm')
        elif index == 1:
            translator.load(':/locales/zh_cn.qm')

    @pyqtProperty(int)
    def curr_lang(self):
        return self._curr_lang
