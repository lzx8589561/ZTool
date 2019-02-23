import _thread
import configparser
import logging
import os
import time
import zipfile
from os.path import abspath, join

from PyQt5.QtCore import pyqtProperty, QObject, pyqtSlot, pyqtSignal

import common


class MysqlConfiguration(QObject):
    """
    mysql配置管理
    """
    futility_signal = pyqtSignal()
    unzipCompleteSignal = pyqtSignal(str, arguments=['file'])

    def __init__(self, parent=None):
        super().__init__(parent)

        self.cf = configparser.RawConfigParser()
        self.mysql_dir_path = abspath(join(common.project_path(), 'mysql'))
        self.ini_path = abspath(join(self.mysql_dir_path, 'my.ini'))
        self.mysql_exist = False
        self.already_load_cf = False
        self.sel_exist_mysql()

    def sel_exist_mysql(self):
        if not os.path.exists(self.ini_path):
            self.mysql_exist = False
        else:
            self.mysql_exist = True
            if not self.already_load_cf:
                logging.debug("开始加载Mysql配置文件")
                self.cf.read(self.ini_path)
                self.cf.set('mysqld', 'basedir', self.mysql_dir_path)
                self.cf.set('mysqld', 'datadir', abspath(join(self.mysql_dir_path, 'data')))
                self.write_cf()
                self.already_load_cf = True

    @pyqtSlot(name='writeCf')
    def write_cf(self):
        """
        立即写入配置
        """
        with open(self.ini_path, "w+") as f:
            self.cf.write(f)

    @pyqtProperty('QString', notify=futility_signal)
    def port(self):
        return self.cf.get('client', 'port') if self.mysql_exist else ""

    @port.setter
    def port(self, val):
        self.cf.set('client', 'port', val)
        self.cf.set('mysqld', 'port', val)

    @pyqtProperty('QString', notify=futility_signal)
    def max_connections(self):
        return self.cf.get('mysqld', 'max_connections') if self.mysql_exist else ""

    @max_connections.setter
    def max_connections(self, val):
        self.cf.set('mysqld', 'max_connections', val)

    @pyqtProperty('QString', notify=futility_signal)
    def back_log(self):
        return self.cf.get('mysqld', 'back_log') if self.mysql_exist else ""

    @back_log.setter
    def back_log(self, val):
        self.cf.set('mysqld', 'back_log', val)

    @pyqtProperty('QString', notify=futility_signal)
    def default_storage_engine(self):
        return self.cf.get('mysqld', 'default-storage-engine') if self.mysql_exist else ""

    @default_storage_engine.setter
    def default_storage_engine(self, val):
        self.cf.set('mysqld', 'default-storage-engine', val)

    @pyqtProperty('QString', notify=futility_signal)
    def key_buffer_size(self):
        return self.cf.get('mysqld', 'key_buffer_size') if self.mysql_exist else ""

    @key_buffer_size.setter
    def key_buffer_size(self, val):
        self.cf.set('mysqld', 'key_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_buffer_pool_size(self):
        return self.cf.get('mysqld', 'innodb_buffer_pool_size') if self.mysql_exist else ""

    @innodb_buffer_pool_size.setter
    def innodb_buffer_pool_size(self, val):
        self.cf.set('mysqld', 'innodb_buffer_pool_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_additional_mem_pool_size(self):
        return self.cf.get('mysqld', 'innodb_additional_mem_pool_size') if self.mysql_exist else ""

    @innodb_additional_mem_pool_size.setter
    def innodb_additional_mem_pool_size(self, val):
        self.cf.set('mysqld', 'innodb_additional_mem_pool_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def innodb_log_buffer_size(self):
        return self.cf.get('mysqld', 'innodb_log_buffer_size') if self.mysql_exist else ""

    @innodb_log_buffer_size.setter
    def innodb_log_buffer_size(self, val):
        self.cf.set('mysqld', 'innodb_log_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def query_cache_size(self):
        return self.cf.get('mysqld', 'query_cache_size') if self.mysql_exist else ""

    @query_cache_size.setter
    def query_cache_size(self, val):
        self.cf.set('mysqld', 'query_cache_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def read_buffer_size(self):
        return self.cf.get('mysqld', 'read_buffer_size') if self.mysql_exist else ""

    @read_buffer_size.setter
    def read_buffer_size(self, val):
        self.cf.set('mysqld', 'read_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def read_rnd_buffer_size(self):
        return self.cf.get('mysqld', 'read_rnd_buffer_size') if self.mysql_exist else ""

    @read_rnd_buffer_size.setter
    def read_rnd_buffer_size(self, val):
        self.cf.set('mysqld', 'read_rnd_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def sort_buffer_size(self):
        return self.cf.get('mysqld', 'sort_buffer_size') if self.mysql_exist else ""

    @sort_buffer_size.setter
    def sort_buffer_size(self, val):
        self.cf.set('mysqld', 'sort_buffer_size', val)

    @pyqtProperty('QString', notify=futility_signal)
    def tmp_table_size(self):
        return self.cf.get('mysqld', 'tmp_table_size') if self.mysql_exist else ""

    @tmp_table_size.setter
    def tmp_table_size(self, val):
        self.cf.set('mysqld', 'tmp_table_size', val)

    @pyqtSlot(str, str, name='unzip')
    def unzip(self, src_file, out_dir):
        _thread.start_new_thread(self.__unzip, (abspath(join(common.project_path(), src_file))
                                                , abspath(join(common.project_path(), out_dir))))

    def __unzip(self, src_file, out_dir):
        logging.debug("开始解压")
        zf = zipfile.ZipFile(src_file, 'r')

        # 检查文件是否合并完成
        for i in range(3):
            logging.debug("检查是否合并完成，文件路径："+src_file + '.aria3')
            if not os.path.exists(src_file + '.aria3'):
                logging.debug("未发现aria2临时文件，跳出开始解压")
                break
            if i == 2:
                logging.debug("解压失败，存在aria2临时文件")
                return
            time.sleep(1)

        zf.extractall(path=out_dir)
        zf.close()
        logging.debug("解压完成")
        self.unzipCompleteSignal.emit(src_file)


mysql_configuration_instance = MysqlConfiguration()
