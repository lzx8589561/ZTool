import _thread
import logging
import os
import subprocess
import time
from os.path import abspath, join
import requests
import hashlib
from urllib import parse
import websocket
import json
import pickle
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.util import datetime_repr
import os,ctypes,psutil,win32api
from ctypes import *

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot

import common
from controller import setting_instance


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
    jobExedSignal = pyqtSignal(str, arguments=['job_id'])
    hookStateSignal = pyqtSignal(str, arguments=['state'])
    weather_template = '晚上好呀！下面是明天的天气情况[吃瓜]\n\n你的城市：{city_name}\n天气：{tomorrow_text}\n温度：{tomorrow_temp}\n风向：{tomorrow_wind}\n贴心提示：{tomorrow_dress_tips}\n运动：{tomorrow_sport_tips}\n紫外线：{tomorrow_ua_tips}\n预测时间：{update_time}\n\nONE.一个：{one}'

    def __init__(self, parent=None):
        super().__init__(parent)
        
    
    @pyqtSlot(name='initScheduler')
    def init_scheduler(self):
        self.scheduler = BackgroundScheduler()
        self.scheduler.start()

        # 加载存储的节点
        try:
            with open(self.jobs_path, "rb") as f:
                self.jobs_conf = pickle.load(f)
        except:
            self.jobs_conf = []
        # 初始化执行定时器
        self.__reset_scheduler()

    def sync_request(self,url):
        req_count = 0
        while req_count < 10:
            try:
                return requests.get(url, timeout=10, headers={"content-type": "application/json"})
            except:
                req_count += 1
        
        return None
    
    @pyqtSlot(name='hook')
    def hook(self):
        _thread.start_new_thread(self.__hook, ())

    def __hook(self):
        PAGE_READWRITE = 0x00000040
        PROCESS_ALL_ACCESS =  (0x000F0000|0x00100000|0xFFF)
        VIRTUAL_MEM = (0x00001000 | 0x00002000)
        dll_path = bytes((os.path.abspath('.')+"\\version2.9.0.123-4.5.7.71.dll").encode('utf-8'))
        print(dll_path)
        dll_len = len(dll_path)
        kernel32 = ctypes.windll.kernel32
        wechat_path = ''
        #第一步获取整个系统的进程快照
        pids = psutil.pids()
        #第二步在快照中去比对进程名
        for pid in pids:
            p= psutil.Process(pid)
            try:
                if p.name()=='WeChat.exe':
                    wechat_path = p.cwd()
                    break
                else:
                    pid = 0
            except:
                pass
        #第三步用找到的pid去打开进程获取到句柄
        if pid == 0:
            self.hookStateSignal.emit('NOT_FOUND_WECHAT')
        else:
            h_process=kernel32.OpenProcess(PROCESS_ALL_ACCESS,False,(pid))
            if not h_process:
                self.hookStateSignal.emit('ERROR')
                return
            else:
                arg_adress=kernel32.VirtualAllocEx(h_process,None,dll_len*10,VIRTUAL_MEM,PAGE_READWRITE)
                NULL = c_int(0)
                kernel32.WriteProcessMemory(h_process,arg_adress,dll_path,dll_len*10,NULL)
                h_kernel32 = win32api.GetModuleHandle("kernel32.dll")
                h_loadlib = win32api.GetProcAddress(h_kernel32, 'LoadLibraryA')
                thread_id = c_ulong(0)
                c_remt = kernel32.CreateRemoteThread(h_process,None,0,c_long(h_loadlib),arg_adress,0,byref(thread_id))
                self.hookStateSignal.emit('SUCCESS')

    def get_weather(self, job):
        req_count = 0
        res = self.sync_request('https://geoapi.qweather.net/v2/city/lookup?location={}&key={}'.format(
                    job['location'],setting_instance.settings['qweather_key']))

        city_name = None
        if res is not None:
            res_content = res.content.decode()
            print(res_content)
            json_res = json.loads(res_content)
            city_name = json_res['location'][0]['name']

        req_count = 0
        res = self.sync_request('https://api.qweather.net/v7/weather/3d?location={}&key={}'.format(
                    job['location'],setting_instance.settings['qweather_key']))

        tomorrow_text = None
        tomorrow_temp = None
        tomorrow_wind = None
        update_time = None
        if res is not None:
            res_content = res.content.decode()
            print(res_content)
            json_res = json.loads(res_content)
            update_time = json_res['updateTime']
            tomorrow_text = json_res['daily'][1]['textDay']
            tomorrow_temp = json_res['daily'][1]['tempMin'] + \
                '~' + json_res['daily'][1]['tempMax']
            tomorrow_wind = json_res['daily'][1]['windDirDay'] + \
                json_res['daily'][1]['windScaleDay'] + '级'

        print('update_time:{},tomorrow_text:{},tomorrow_temp:{},tomorrow_wind:{}'.format(
            update_time, tomorrow_text, tomorrow_temp, tomorrow_wind))

        req_count = 0
        res = self.sync_request('https://api.qweather.net/v7/indices/3d?location={}&type=1,3,5&key={}'.format(
                    job['location'],setting_instance.settings['qweather_key']))

        tomorrow_dress_tips = None
        tomorrow_sport_tips = None
        tomorrow_ua_tips = None
        if res is not None:
            res_content = res.content.decode()
            print(res_content)
            json_res = json.loads(res_content)
            tomorrow_sport_tips = json_res['daily'][3]['text']
            tomorrow_dress_tips = json_res['daily'][4]['text']
            tomorrow_ua_tips = json_res['daily'][5]['text']

        print('tomorrow_dress_tips:{},tomorrow_sport_tips:{},tomorrow_ua_tips:{}'.format(
            tomorrow_dress_tips, tomorrow_sport_tips, tomorrow_ua_tips))

        # 获取ONE
        one = common.get_wufazhuce_info()
        result = self.weather_template.format(tomorrow_text=tomorrow_text, tomorrow_temp=tomorrow_temp, tomorrow_wind=tomorrow_wind, tomorrow_dress_tips=tomorrow_dress_tips,
                                              tomorrow_sport_tips=tomorrow_sport_tips, tomorrow_ua_tips=tomorrow_ua_tips, update_time=update_time, city_name=city_name, one=one)
        return result

    def __job_task(self, job):
        self.jobExedSignal.emit(job['job_id'])
        msg = None
        if job['msg_type'] == 'weather':
            msg = self.get_weather(job)
        elif job['msg_type'] == 'text':
            msg = job['msg']
        json_msg = {
            'id': self._getid(),
            'type': 555,
            'content': msg,
            'wxid': job['wxid']
        }
        if self.websocketOnline:
            self.ws.send(json.dumps(json_msg))

    def __reset_scheduler(self):
        self.scheduler.remove_all_jobs()
        for index, item in enumerate(self.jobs_conf):
            if item['job_enable']:
                if item['trigger'] == 'interval':
                    self.scheduler.add_job(self.__job_task, 'interval', coalesce=True, misfire_grace_time=3600, weeks=int(item['weeks']), days=int(item['days']), hours=int(
                        item['hours']), minutes=int(item['minutes']), seconds=int(item['seconds']), jitter=int(item['jitter']), id=item['job_id'], args=[item])
                elif item['trigger'] == 'cron':
                    self.scheduler.add_job(self.__job_task, 'cron', coalesce=True, misfire_grace_time=3600, second=item['second'], minute=item[
                                           'minute'], hour=item['hour'], day_of_week=item['day_of_week'], jitter=int(item['jitter']), id=item['job_id'], args=[item])

    @pyqtSlot(QVariant, name='addJob')
    def add_job(self, job):
        job = job.toVariant()
        job['job_id'] = self._getid()
        self.jobs_conf.append(job)
        self._save_conf()
        self.__reset_scheduler()

    @pyqtSlot(QVariant, name='editJob')
    def edit_job(self, job):
        job = job.toVariant()
        for index, item in enumerate(self.jobs_conf):
            if item['job_id'] == job['job_id']:
                self.jobs_conf[index] = job
        self._save_conf()
        self.__reset_scheduler()

    @pyqtSlot(str, name='delJob')
    def del_job(self, job_id):
        job_index = 0
        for index, item in enumerate(self.jobs_conf):
            if item['job_id'] == job_id:
                job_index = index
        self.jobs_conf.pop(job_index)
        self._save_conf()
        self.__reset_scheduler()

    @pyqtSlot(name='getJobsConf', result=QVariant)
    def get_jobs_conf(self):
        return self.jobs_conf

    @pyqtSlot(name='getJobsState', result=QVariant)
    def get_jobs_state(self):
        jobs = self.scheduler.get_jobs()
        jobs_state = {}
        for job in jobs:
            jobs_state[job.id] = datetime_repr(job.next_run_time)
        return jobs_state

    def _save_conf(self):
        with open(self.jobs_path, "wb") as jf:
            pickle.dump(self.jobs_conf, jf)

    def _getid(self):
        id = str(int(time.time() * 1000))
        return id

    @pyqtSlot(name='getUserList')
    def get_user_list(self):
        if self.websocketOnline:
            self.ws.send(
                '{"id":"1231231236","type":5000,"content":"user list","wxid":"null"}')

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
        _thread.start_new_thread(self._websocket_init, ())

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
