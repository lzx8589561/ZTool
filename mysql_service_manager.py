import _thread
import configparser
import os
import time
from os.path import abspath, dirname, join

import pymysql
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal


class MysqlServiceManager(QObject):
    """
    Mysql服务管理
    """
    statusSignal = pyqtSignal(str, arguments=['status'])
    pwdSignal = pyqtSignal(str, arguments=['status'])
    mysql_dir_path = abspath(join(dirname(__file__), 'mysql'))
    mysqld_name = 'mysqlddkw.exe'
    cf = configparser.RawConfigParser()
    cf.read(abspath(join(mysql_dir_path, 'my.ini')))

    def __init__(self, setting, parent=None):
        super().__init__(parent)
        self.setting = setting
        self.new_pwd = None
        self.rboot = None

    @pyqtSlot(result=str, name='installService')
    def install_service(self):
        """
        安装mysql服务
        """
        cmd = '{0} --install{1} {2} --defaults-file=\"{3}\"'.format(
            join(self.mysql_dir_path, 'bin', self.mysqld_name),
            ('' if self.setting.settings['autostarts'] == 1 else '-manual'), self.setting.settings['service'],
            join(self.mysql_dir_path, 'my.ini'))

        print("安装命令：" + cmd)
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        print(tmp)
        if tmp.find('successfully') != -1:
            return 'ok'
        elif tmp.find('already exists') != -1:
            return 'exists'
        else:
            return 'error'

    @pyqtSlot(result=str, name='uninstallService')
    def uninstall_service(self):
        """
        卸载mysql服务
        """
        cmd = join(self.mysql_dir_path, 'bin', self.mysqld_name) + ' --remove ' + self.setting.settings['service']
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        print(tmp)
        if tmp.find('success') != -1:
            return 'ok'
        else:
            return 'error'

    @pyqtSlot(str, str, result=str, name='modifiedPassword')
    def modified_password(self, newp, rboot):
        """
        强制修改mysql密码
        """
        self.new_pwd = newp
        self.rboot = rboot
        _thread.start_new_thread(self.skip_pwd_start_service, ())

        return 'ok'

    @pyqtSlot(result=str, name='startService')
    def start_service(self):
        """
        启动mysql服务
        """
        cmd = 'sc start ' + self.setting.settings['service']
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        print(tmp)
        if tmp.find('start_pending') != -1:
            return 'ok'
        else:
            return 'error'

    def skip_pwd_start_service(self):
        """
        跳过密码启动mysql服务
        """
        self.kill_progress()

        cmd = '{0} --defaults-file=\"{1}\" --skip-grant-tables'.format(
            join(self.mysql_dir_path, 'bin', self.mysqld_name), join(self.mysql_dir_path, 'my.ini'))
        os.popen(cmd)

        try_count = 0
        successed = False
        while True:
            try:
                try_count += 1
                connect = pymysql.connect(host='127.0.0.1', port=3309, user='root', passwd='123', db='mysql',
                                          charset='utf8')
                cursor = connect.cursor()
                sql = 'update mysql.user set Password=password(\'{0}\') where User=\'root\';'.format(self.new_pwd)
                # 执行SQL语句
                cursor.execute(sql)
                connect.commit()
                successed = True
                self.kill_progress()
                if self.rboot == '1':
                    self.start_service()
                break
            except:
                print("尝试链接数据库失败")
            if try_count == 3:
                break
        self.pwdSignal.emit('ok' if successed else 'false')

    @pyqtSlot(result=str, name='stopService')
    def stop_service(self):
        """
        停止mysql服务
        """
        cmd = 'sc stop ' + self.setting.settings['service']
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        print(tmp)
        if tmp.find('stop_pending') != -1:
            return 'ok'
        else:
            return 'error'

    @pyqtSlot(result=str, name='killProgress')
    def kill_progress(self):
        """
        强制停止进程
        """
        cmd = 'chcp 437 && taskkill /f /im \"{0}\" '.format(self.mysqld_name)
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        if tmp.find('success') != -1:
            return 'ok'
        else:
            return 'error'

    @pyqtSlot(result=str, name='statusService')
    def status_service(self):
        """
        获取mysql服务状态
        """
        cmd = 'sc query ' + self.setting.settings['service']
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        # print(tmp)
        if tmp.find('stopped') != -1:
            return 'stopped'
        elif tmp.find('1060') != -1:
            return 'notfound'
        elif tmp.find('running') != -1:
            return 'running'
        elif tmp.find('stop_pending') != -1:
            return 'stopPending'
        elif tmp.find('start_pending') != -1:
            return 'startPending'
        else:
            return 'error'

    def status_update_thread(self):
        """
        会阻塞线程，开启新线程启动
        """
        while True:
            status = self.status_service()
            self.statusSignal.emit(status)
            time.sleep(0.5)
