import _thread
import logging
import os
import subprocess
import time
from os.path import abspath, join
import requests
import re
import json
import urllib.parse
from bs4 import BeautifulSoup

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot

import common

class SinaT(QObject):
    """
    新浪短网址
    """
    parseCompleteSignal = pyqtSignal(str, arguments=['shortUrl'])

    @pyqtSlot(str, name='parse')
    def parse(self, o_url):
        _thread.start_new_thread(self.__parse, (o_url,) )

    def __parse(self, o_url):
        logging.debug("开始缩短")
        try:
            o_parsed_url = urllib.parse.quote(o_url)
            
            url = 'http://suo.im/api.htm?url='+o_parsed_url+'&key=5f140f7cb1b63c2312ec95ef@29b4fb844fe6485515846a59767d8cae&expireDate=2099-03-31'
            # url = 'https://service.weibo.com/share/share.php?url='+o_url+'&pic=pic&appkey=key&title='+o_url
            headers = {
                'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 Edg/79.0.309.51',
                'origin': 'https://weibo.com'
                }
            # 请求下载页面
            strhtml = requests.get(url, headers=headers)
            short_url = strhtml.text
        except:
            short_url = ''
        self.parseCompleteSignal.emit(short_url)
    
    @pyqtSlot(str, name='paste')
    def paste(self, url):
        pyperclip.copy(url)

sina_t_instance = SinaT()