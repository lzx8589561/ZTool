import _thread
import os
from os.path import abspath, join

import requests
import configparser
import time
import common
import hashlib
import threading
import sys
import logging
from controller import setting_instance

# 设置解释器递归次数显示，但涉及系统底层，win ≈ 4400 linux ≈ 24900
sys.setrecursionlimit(20000)


class Onedrive:

    # 分片大小
    block_size = setting_instance.settings['block_size'] * 1024 * 1024

    def __init__(self):
        self.cf = configparser.RawConfigParser()
        self.cf.read(abspath(join(common.project_path(), 'base.ini')))
        # 同步锁
        self.mutex = threading.Lock()

        self.access_token = self.cf.get('token', 'access_token')
        self.client_id = self.cf.get('token', 'client_id')
        self.client_secret = self.cf.get('token', 'client_secret')
        self.redirect_uri = self.cf.get('token', 'redirect_uri')
        self.app_url = self.cf.get('token', 'app_url')
        self.refresh_token = self.cf.get('token', 'refresh_token')
        # 实例化时立即尝试获取token，避免多线程并发
        _thread.start_new_thread(self.__get_access_token, ())

    def write_cf(self):  # 写入新的配置
        """
        立即写入配置(避免多线程照成并发，加锁)
        """
        self.mutex.acquire()
        with open("base.ini", "w+") as f:
            try:
                self.cf.write(f)
            except Exception as e:
                logging.debug('文件写入失败，等待下次尝试！')
        self.mutex.release()

    def upload(self, local_file, remote_path):  # 上传文件
        """
        小的单文件上传
        :param local_file: 本地文件路径
        :param remote_path: 远程路径(带文件名)
        :return: None
        """
        at = self.__get_access_token()
        headers = {
            'Authorization': 'bearer ' + at
        }

        file_size = common.get_file_size(local_file)
        logging.debug('文件大小:{0}'.format(file_size))
        url = self.app_url + '_api/v2.0/me/drive/root:/' + remote_path + ':/content'
        file = open(local_file, 'rb')

        r = requests.put(url, headers=headers, data=file)
        r.encoding = "utf-8"

        if r.status_code == 200 or r.status_code == 201:
            # 返回json格式的数据
            print(r.json())
        else:
            logging.debug('接口访问失败')

    def __get_access_token(self):
        """
        获取token 若过期重新获取
        :return: token:str
        """
        expires_on = self.cf.getint('token', 'expires_on')
        if expires_on > time.time() + 600:
            return self.access_token
        else:
            self.get_token()
            self.write_cf()
            return self.access_token

    def get_token(self):
        """
        调用接口获取token
        :return: succeed
        """
        logging.debug('用接口获取Token')
        url = 'https://login.chinacloudapi.cn/common/oauth2/token'
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        data = {
            'client_id': self.client_id,
            'redirect_uri': self.redirect_uri,
            'client_secret': self.client_secret,
            'refresh_token': self.refresh_token,
            'grant_type': 'refresh_token',
            'resource': self.app_url
        }
        r = requests.post(url, headers=headers, data=data)
        if r.status_code == 200:
            json = r.json()
            print(r.json())
            self.cf.set('token', 'expires_on', json['expires_on'])
            self.cf.set('token', 'access_token', json['access_token'])
            self.access_token = json['access_token']
            self.write_cf()
            return True
        else:
            return False

    def upload_large_file(self, local_file, remote_path, process_callback=None):  # 大文件上传
        """
        大文件分片上传
        :param local_file: 本地文件路径
        :param remote_path:  远程路径(带文件名)
        :param process_callback:  回调
        """
        global session
        if not os.path.exists(local_file):
            raise Exception('未找到文件！')

        md5 = hashlib.md5((local_file + remote_path).encode("utf-8")).hexdigest()
        file_size = os.path.getsize(local_file)
        if not self.cf.has_section(md5):
            session = self.__create_upload_session(remote_path)
            if not session:
                logging.debug('文件已经存在！')
                return
            self.cf.add_section(md5)
            self.cf.set(md5, 'url', session['uploadUrl'])
            self.cf.set(md5, 'local_file', local_file)
            self.cf.set(md5, 'remote_path', remote_path)
            self.cf.set(md5, 'file_size', str(file_size))
            self.cf.set(md5, 'offset', '0')
            self.cf.set(md5, 'length', str(self.block_size))
            self.cf.set(md5, 'update_time', str(time.time()))
            self.write_cf()

        # 开始进行分片上传
        begin = common.msec()
        offset = int(self.cf.get(md5, 'offset'))
        length = int(self.cf.get(md5, 'length'))
        r = self.__upload_session(self.cf.get(md5, 'url'), local_file, offset, length)
        if r.get('nextExpectedRanges', False):
            end = common.msec()
            elapsed = end - begin
            curr = offset + self.block_size
            process = 100 if curr > file_size else int((curr / file_size) * 100)
            if process_callback:
                process_callback(md5, process)
                logging.debug(local_file + ' 上传进度：' + str(process) + '，分块上传耗时：' + str(elapsed))
            # length = int(length / elapsed / 32768 * 2 * 327680)
            # length = 104857600 if (length > 104857600) else length
            tem = r['nextExpectedRanges'][0].split('-')

            self.cf.set(md5, 'offset', tem[0])
            # self.cf.set(md5, 'length', str(length))
            self.cf.set(md5, 'update_time', str(time.time()))
            self.write_cf()

        elif r.get('@content.downloadUrl', False):
            logging.debug(local_file + '文件上传完成')
            if process_callback:
                process_callback(md5, 100)
            self.cf.remove_section(md5)
            self.write_cf()
            return
        else:
            logging.debug('上传分块失败')

        # 递归上传 TODO: 修改为循环控制
        self.upload_large_file(local_file, remote_path, process_callback)

    def __create_upload_session(self, remote_path):
        """
        创建分片上传会话
        :param remote_path: 远程路径(含文件名)
        :return: succeed ? json : None
        """
        at = self.__get_access_token()
        headers = {
            'Authorization': 'bearer ' + at,
            'Content-Type': 'application/json'
        }
        json = {
            'item': {
                '@microsoft.graph.conflictBehavior': 'rename'
            },
            # 'deferCommit': False
        }
        url = self.app_url + '_api/v2.0/me/drive/root:/' + remote_path + ':/createUploadSession'
        r = requests.post(url, headers=headers, json=json)
        if r.status_code == 409:
            return None
        return r.json()

    def __upload_session(self, url, file, offset, length=10240):
        """
        上传分片
        :param url: 分片url
        :param file: file
        :param offset: 偏移值
        :param length: 长度
        :return: json data
        """
        at = self.__get_access_token()
        file_size = os.path.getsize(file)

        content_length = (file_size - offset) if ((offset + length) > file_size) else length
        end = offset + content_length - 1
        with open(file, 'rb') as f:
            f.seek(offset)
            data = f.read(length)

        headers = {
            'Authorization': 'bearer ' + at,
            'Content-Length': str(content_length),
            'Content-Range': 'bytes ' + str(offset) + '-' + str(end) + '/' + str(file_size)
        }

        r = requests.put(url, headers=headers, data=data)
        return r.json()

    def get_default_upload_path(self) -> str:
        """
        获取默认远程位置
        :return: path:str
        """
        return self.cf.get('token', 'path')

    def set_default_upload_path(self, val):
        """
        设置默认上传远程位置
        :param val: 路径
        """
        self.cf.set('token', 'path', val)
        self.write_cf()

    def delete(self, item_id):
        """
        删除文件到回收站
        :param item_id: item id
        :return: succeed
        """
        at = self.__get_access_token()
        headers = {
            'Authorization': 'bearer ' + at
        }
        url = self.app_url + '_api/v2.0/me/drive/items/' + item_id
        r = requests.delete(url, headers=headers)
        if r.status_code == 204:
            return True
        return False

    def dir(self, path: str = '/'):  # 检索目录内容
        """
        获取指定目录文件列表
        :param path: 相对路径
        :return: [{'name': 'Documents', 'downloadUrl': None, 'type': None, 'folder': True},...]
        """
        if path != '/':
            path = ':' + path.rstrip('/') + ':/'
        url = self.app_url + '_api/v2.0/me/drive/root' + path + 'children?expand=thumbnails'
        items = []
        self.__dir_next_page(url, items)
        return items

    def __dir_next_page(self, url, items):
        """
        分页数据获取
        :param url: url
        :param items: context
        """
        at = self.__get_access_token()
        headers = {
            'Authorization': 'bearer ' + at
        }
        r = requests.get(url, headers=headers)
        json = r.json()
        for item in json['value']:
            is_folder = True if 'folder' in item else False
            items.append({
                'id': item['id'],
                'name': item['name'],
                'downloadUrl': None if is_folder else item['@content.downloadUrl'],
                'type': None if is_folder else item['file']['mimeType'],
                'folder': is_folder
            })

        # 若存在分页 递归查询
        if '@odata.nextLink' in json:
            # TODO: 修改为循环控制
            self.__dir_next_page(json['@odata.nextLink'], items)

    # noinspection PyMethodMayBeStatic
    def download(self, local_file, remote_path):
        """
        文件下载(适合小文件下载)
        :param local_file:
        :param remote_path:
        :return:
        """
        r = requests.get(remote_path, stream=True)
        with open(local_file, 'wb') as f:
            for chunk in r.iter_content(100000):
                f.write(chunk)

    # noinspection PyMethodMayBeStatic
    def flush_site(self, path=None):
        """
        清除网站缓存，使下载连接立即生效
        :param path: 清除路径，不填写这重建缓存(比较耗时)
                /Oneindex/Projects/xxxx/
        :return:
        """
        # TODO: php后台添加清除指定路径缓存
        cookies = {'admin': 'fcc189b51539109d1dd3c2f64beebeb0'}
        url = 'https://pan.ilt.me/?/admin/cache'
        data = {'update', path} if path else {'clear': ''}
        r = requests.post(url, cookies=cookies, data=data)
        # print(r.content.decode('utf-8'))


if __name__ == '__main__':
    one = Onedrive()
    # 上传大文件调用示例
    # one.upload_large_file('3.zip', '3.zip')
    # 获取文件路径调用示例
    # print(one.dir(one.cf.get('token', 'projects_path')))
    # 文件加载调用示例
    # one.download('qmltest.zip', 'https://pan.ilt.me/qmltest.zip')
    # 清除缓存调用示例
    # one.flush_site()
    # one.delete('01LYPWX4L4BE4YMRXX2JFJLINHQUPKQ75Y')
