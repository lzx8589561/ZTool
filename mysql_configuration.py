import configparser
from os.path import abspath, dirname, join

from PyQt5.QtCore import pyqtProperty, QObject, pyqtSlot, pyqtSignal


class MysqlConfiguration(QObject):
    """
    mysql配置管理
    """
    cf = configparser.RawConfigParser()
    mysql_dir_path = abspath(join(dirname(__file__), 'mysql'))
    ini_path = abspath(join(mysql_dir_path, 'my.ini'))
    cf.read(ini_path)
    futility_signal = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.cf.set('mysqld', 'basedir', self.mysql_dir_path)
        self.cf.set('mysqld', 'datadir', abspath(join(self.mysql_dir_path, 'data')))
        self.write_cf()

    @pyqtSlot(name='writeCf')
    def write_cf(self):
        """
        立即写入配置
        """
        with open(self.ini_path, "w+") as f:
            self.cf.write(f)

    @pyqtProperty('QString', notify=futility_signal)
    def port(self):
        return self.cf.get('client', 'port')

    @port.setter
    def port(self, val):
        self.cf.set('client', 'port', val)
        self.cf.set('mysqld', 'port', val)

    @pyqtProperty('QString', notify=futility_signal)
    def max_connections(self):
        return self.cf.get('mysqld', 'max_connections')

    @max_connections.setter
    def max_connections(self, val):
        self.cf.set('mysqld', 'max_connections', val)

    @pyqtProperty('QString', notify=futility_signal)
    def back_log(self):
        return self.cf.get('mysqld', 'back_log')

    @back_log.setter
    def back_log(self, val):
        self.cf.set('mysqld', 'back_log', val)

    @pyqtProperty('QString', notify=futility_signal)
    def default_storage_engine(self):
        return self.cf.get('mysqld', 'default-storage-engine')

    @default_storage_engine.setter
    def default_storage_engine(self, val):
        self.cf.set('mysqld', 'default-storage-engine', val)

    @pyqtProperty('QString', notify=futility_signal)
    def key_buffer_size(self):
        return self.cf.get('mysqld', 'key_buffer_size')

    @key_buffer_size.setter
    def key_buffer_size(self, val):
        self.cf.set('mysqld', 'key_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_buffer_pool_size(self):
        return self.cf.get('mysqld', 'innodb_buffer_pool_size')

    @innodb_buffer_pool_size.setter
    def innodb_buffer_pool_size(self, val):
        self.cf.set('mysqld', 'innodb_buffer_pool_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_additional_mem_pool_size(self):
        return self.cf.get('mysqld', 'innodb_additional_mem_pool_size')

    @innodb_additional_mem_pool_size.setter
    def innodb_additional_mem_pool_size(self, val):
        self.cf.set('mysqld', 'innodb_additional_mem_pool_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_log_buffer_size(self):
        return self.cf.get('mysqld', 'innodb_log_buffer_size')

    @innodb_log_buffer_size.setter
    def innodb_log_buffer_size(self, val):
        self.cf.set('mysqld', 'innodb_log_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def query_cache_size(self):
        return self.cf.get('mysqld', 'query_cache_size')

    @query_cache_size.setter
    def query_cache_size(self, val):
        self.cf.set('mysqld', 'query_cache_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def read_buffer_size(self):
        return self.cf.get('mysqld', 'read_buffer_size')

    @read_buffer_size.setter
    def read_buffer_size(self, val):
        self.cf.set('mysqld', 'read_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def read_rnd_buffer_size(self):
        return self.cf.get('mysqld', 'read_rnd_buffer_size')

    @read_rnd_buffer_size.setter
    def read_rnd_buffer_size(self, val):
        self.cf.set('mysqld', 'read_rnd_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def sort_buffer_size(self):
        return self.cf.get('mysqld', 'sort_buffer_size')

    @sort_buffer_size.setter
    def sort_buffer_size(self, val):
        self.cf.set('mysqld', 'sort_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def tmp_table_size(self):
        return self.cf.get('mysqld', 'tmp_table_size')

    @tmp_table_size.setter
    def tmp_table_size(self, val):
        self.cf.set('mysqld', 'tmp_table_size', val)
