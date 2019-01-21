import re
import time
from contextlib import closing
from os.path import dirname, join
from urllib import parse

import requests


# 文件下载器
def down_load(url, save_path, callback=None):
    """
    下载文件
    :param url: 文件链接
    :param save_path: 保存路径
    :param callback: 回调
    :return: 是否下载完成
    """
    with closing(requests.get(url, stream=True)) as response:
        chunk_size = 1024 * 1024  # 单次请求最大值
        content_size = int(response.headers['content-length'])  # 内容体总大小
        content_disposition = response.headers['Content-Disposition']
        index = content_disposition.find('filename="')
        file_name = str(int(time.time() * 1000))
        if index != -1:
            pattern = re.compile(r'filename="(.+)"')
            matcher = re.search(pattern, content_disposition)
            file_name = parse.unquote(matcher.group(1))
        data_count = 0
        start_time = time.time()
        with open(join(dirname(__file__), save_path, file_name), "wb") as file:
            for data in response.iter_content(chunk_size=chunk_size):
                file.write(data)
                data_count = data_count + len(data)
                now_jd = int((data_count / content_size) * 100)
                speed = data_count / (time.time() - start_time) / 1024
                if callback is not None:
                    callback({
                        'file_name': file_name,
                        'file_len': content_size,
                        'already': data_count,
                        'process': now_jd,
                        'speed': speed
                        })
                print("\r 文件下载进度：%d%%(%d/%d) - %s" % (now_jd, data_count, content_size, save_path), end=" ")
                if now_jd == 100:
                    return True
        return False


if __name__ == '__main__':
    file_url = 'https://pan.ilt.me/Vedio/1-1+%E8%AF%BE%E7%A8%8B%E5%AF%BC%E5%AD%A6+.mp4'  # 文件链接
    file_path = "d:/"  # 文件路径
    down_load(file_url, file_path, lambda obj: {
        print("回调："+str(obj['process']))
    })
