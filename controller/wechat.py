import _thread
import logging
import os
import subprocess
import time
from os.path import abspath, join
import websocket
import json
import pickle
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot

import common

class Wechat(QObject):
    """
    微信机器人控制器
    """
    futility_signal = pyqtSignal()
    websocket_client = None

    jobs_path = abspath(join(common.project_path(), 'jobs'))
    userListSignal = pyqtSignal(QVariant, arguments=['userList'])
    wechatLogSignal = pyqtSignal(str, arguments=['log'])
    websocketStateSignal = pyqtSignal(bool, arguments=['state'])
    websocketOnline = False
    jobs_conf = None

    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()

        # 加载存储的节点
        try:
            with open(self.jobs_path, "rb") as f:
                self.jobs_conf = pickle.load(f)
        except:
            self.jobs_conf = []
        # 初始化执行定时器
        self._reset_scheduler()
    
    def _job_task(self, job):
        json_msg = {
            'id': self._getid(),
            'type': 555,
            'content': job['msg'],
            'wxid': job['wxid']
        }
        if self.websocketOnline:
            self.ws.send(json.dumps(json_msg))
    
    def _reset_scheduler(self):
        self.scheduler.remove_all_jobs()
        for index,item in enumerate(self.jobs_conf):
            if item['job_enable']:
                if item['trigger'] == 'interval':
                    self.scheduler.add_job(self._job_task, 'interval', weeks=int(item['weeks']), days=int(item['days']), hours=int(item['hours']), minutes=int(item['minutes']), seconds=int(item['seconds']), jitter=int(item['jitter']), id=item['job_id'],args=[item])
                elif item['trigger'] == 'cron':
                    self.scheduler.add_job(self._job_task, 'cron', second=item['second'], minute=item['minute'], hour=item['hour'], day_of_week=item['day_of_week'], jitter=int(item['jitter']), id=item['job_id'], args=[item])

    @pyqtSlot(QVariant,name='addJob')
    def add_job(self, job):
        job = job.toVariant()
        job['job_id'] = self._getid()
        self.jobs_conf.append(job)
        self._save_conf()
        self._reset_scheduler()

    @pyqtSlot(QVariant,name='editJob')
    def edit_job(self, job):
        job = job.toVariant()
        for index,item in enumerate(self.jobs_conf):
            if item['job_id'] == job['job_id']:
                self.jobs_conf[index] = job
        self._save_conf()
        self._reset_scheduler()

    @pyqtSlot(str,name='delJob')
    def del_job(self, job_id):
        job_index = 0
        for index,item in enumerate(self.jobs_conf):
            if item['job_id'] == job_id:
                job_index = index
        self.jobs_conf.pop(job_index)
        self._save_conf()
        self._reset_scheduler()

    @pyqtSlot(name='getJobsConf',result=QVariant)
    def get_jobs_conf(self):
        return self.jobs_conf

    def _save_conf(self):
        with open(self.jobs_path, "wb") as jf:
            pickle.dump(self.jobs_conf, jf)

    def _getid(self):
        id = str(int(time.time() * 1000))
        return id
    
    @pyqtSlot(name='getUserList')
    def get_user_list(self):
        if self.websocketOnline:
            self.ws.send('{"id":"1231231236","type":5000,"content":"user list","wxid":"null"}')
    
    @pyqtSlot(str, str, name='sendMessage')
    def send_message(self, wxid, msg):
        logging.debug("发送消息,wxid:{0},msg:{1}".format(wxid, msg))
        json_msg = {
            'id': self._getid(),
            'type': 555,
            'content': msg,
            'wxid': wxid
        }
        if self.websocketOnline:
            self.ws.send(json.dumps(json_msg))
    
    @pyqtSlot(name='websocketInit')
    def websocket_init(self):
        if self.websocketOnline:
            self.ws.close()
        _thread.start_new_thread(self._websocket_init, () )

    def _websocket_init(self):
        self.ws = websocket.WebSocketApp('ws://127.0.0.1:5555',
                                    on_open=self.on_open,
                                    on_message=self.on_message,
                                    on_error=self.on_error,
                                    on_close=self.on_close)
        self.ws.run_forever()

    def on_message(self, message):
        logging.debug('wechat msg:{0}'.format(message))
        json_message = json.loads(message)
        self.wechatLogSignal.emit(message)

        if json_message['type'] == 5000:
            self.userListSignal.emit(json_message)

    def on_error(self, error):
        print("on_error")

    def on_open(self):
        print("on_open")
        self.websocketOnline = True
        self.websocketStateSignal.emit(True)

    def on_close(self):
        print("on_close")
        self.websocketOnline = False
        self.websocketStateSignal.emit(False)
 

wechat_instance = Wechat()