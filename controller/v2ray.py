import _thread
import logging
from os.path import abspath, join
import subprocess
import base64
import json
import pickle
import requests
import copy
import socket
import urllib.parse as parse

import pyperclip
from PyQt5.QtCore import QObject, pyqtSignal, QVariant, pyqtSlot
from .setting import setting_instance

import common
import common.v2ray_adpt as v2ray_adpt
from common.porxy_manager import *


class V2ray(QObject):
    """
    V2ray管理
    """

    v2ray_dir_path = abspath(join(common.project_path(), 'v2ray'))
    v2ray_exe_name = 'wv2ray.exe'
    v2ray_conf_name = 'config.json'
    pac_name = join(v2ray_dir_path, 'pac.js')
    proxy_exe_name = 'v2ray_privoxy.exe'
    proxy_conf_name = 'privoxy.conf'
    ndata_path = join(v2ray_dir_path, 'ndata')
    config_path = join(v2ray_dir_path, 'config.json')
    v2rayLogSignal = pyqtSignal(str, arguments=['log'])
    startedSignal = pyqtSignal()
    stopedSignal = pyqtSignal()
    quitedSignal = pyqtSignal()
    updPacStateSignal = pyqtSignal(str, arguments=['state'])

    # processSignal = pyqtSignal(QVariant, arguments=['process'])

    def __init__(self, parent=None):
        super().__init__(parent)
        self.v2ray_popen = None
        self.proxy_popen = None

        # 加载存储的节点
        try:
            with open(self.ndata_path, "rb") as f:
                self.saved_conf = pickle.load(f)
        except:
            self.pac_conf = None
            self.saved_conf = {
                "local": {},
                "subs": {}
            }
        try:
            # 加载pac
            with open(self.pac_name, "r", encoding="utf-8") as f:
                self.pac_conf = ''.join(f.readlines())
        except:
            self.pac_conf = None
            logging.debug('PAC加载失败')

        self.conf = dict(self.saved_conf['local'], **self.saved_conf['subs'])

        # 开启pac server
        _thread.start_new_thread(self.pac_web_server, ())

    @pyqtSlot(name='sel', result=QVariant)
    def sel(self):
        return self.saved_conf

    @pyqtSlot(name='checkPac', result=str)
    def check_pac(self):
        if self.pac_conf == None:
            return 'error'
        return ''

    @pyqtSlot(name='start')
    def start(self):
        _thread.start_new_thread(self.__start, ())

    def __start(self):
        # 停止v2ray进程
        common.kill_progress(self.v2ray_exe_name)
        # 停止代理进程
        common.kill_progress(self.proxy_exe_name)

        _thread.start_new_thread(self.start_v2ray, ())
        _thread.start_new_thread(self.start_proxy, ())

        mode = setting_instance.settings['proxy_mode']
        if mode == 'Off':
            setting_instance.set_proxy_mode('ProxyOnly')

        self.set_proxy(mode)
        self.startedSignal.emit()

    @pyqtSlot(name='quit')
    def quit(self):
        _thread.start_new_thread(self.__quit, ())

    def __quit(self):
        # 停止v2ray进程
        common.kill_progress(self.v2ray_exe_name)
        # 停止代理进程
        common.kill_progress(self.proxy_exe_name)

        self.set_proxy('Off')
        self.quitedSignal.emit()

    @pyqtSlot(str, name='changeNode', result=str)
    def change_node(self, node):
        try:
            self.setconf(node, '10808')
            self.restart()
            return ''
        except Exception as e:
            return e.args[0]

    @pyqtSlot(str, name='delNode')
    def del_node(self, node):
        self.delconf(node)

    @pyqtSlot(QVariant, name='editNode', result=str)
    def edit_node(self, node):
        # 删除旧的节点配置
        try:
            node = node.toVariant()
            self.delconf(node['oldps'])
            self.add_conf(node['ps'], node)

            if setting_instance.settings['proxy_node'] == node['oldps']:
                setting_instance.set_proxy_node(node['ps'])
                self.setconf(node['ps'], '10808')
                self.restart()
            return ''
        except:
            return 'error'

    def restart(self):
        _thread.start_new_thread(self.__restart, ())

    def __restart(self):
        common.kill_progress(self.v2ray_exe_name)
        common.kill_progress(self.proxy_exe_name)
        self.set_proxy('Off')

        self.__start()

    @pyqtSlot(name='parse', result=str)
    def parse(self):
        try:
            paste_str = pyperclip.paste()
            ret = self.parse_conf_by_uri(paste_str)
            self.add_conf_by_uri(paste_str)
            if setting_instance.settings['proxy_node'] == None:
                setting_instance.set_proxy_node(ret['ps'])
                self.setconf(ret['ps'], '10808')
            return ''
        except Exception as e:
            return e.args[0]

    @pyqtSlot(name='stop')
    def stop(self):
        _thread.start_new_thread(self.__stop, ())

    def __stop(self):
        # 停止v2ray进程
        common.kill_progress(self.v2ray_exe_name)
        # 停止代理进程
        common.kill_progress(self.proxy_exe_name)

        self.set_proxy('Off')
        self.stopedSignal.emit()

    def start_v2ray(self):
        # 窗口信息
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags = subprocess.CREATE_NEW_CONSOLE | subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = subprocess.SW_HIDE

        # 启动v2ray进程
        cmd = '\"{}\" -config \"{}\"'.format(join(self.v2ray_dir_path, self.v2ray_exe_name), join(
            self.v2ray_dir_path, self.v2ray_conf_name))
        popen = subprocess.Popen(cmd, startupinfo=startupinfo,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 creationflags=subprocess.CREATE_NO_WINDOW)
        self.v2ray_popen = popen
        # 重定向标准输出 None表示正在执行中
        while popen.poll() is None:
            r = popen.stdout.readline().decode('utf8')
            if r.replace('\r', '').replace('\n', '').strip(' ') != '':
                logging.debug(r.replace('\n', ''))
                self.v2rayLogSignal.emit(r.replace('\n', ''))

    def start_proxy(self):
        # 窗口信息
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags = subprocess.CREATE_NEW_CONSOLE | subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = subprocess.SW_HIDE

        # 启动proxy进程
        cmd = '\"{}\" \"{}\"'.format(join(self.v2ray_dir_path, self.proxy_exe_name), join(
            self.v2ray_dir_path, self.proxy_conf_name))
        popen = subprocess.Popen(cmd, startupinfo=startupinfo,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,
                                 creationflags=subprocess.CREATE_NO_WINDOW)
        self.proxy_popen = popen

    def get_uri_type(self, uri):
        try:
            op = uri.split("://")
            if op[0] == "vmess":
                return "vmess"
            elif op[0] == "ss":
                return "shadowsocks"
            else:
                raise MyException("无法解析的链接格式")
        except Exception as e:
            if e.args[0] == "无法解析的链接格式":
                raise MyException("无法解析的链接格式")
            raise MyException("解析失败")

    def b642conf(self, prot, b64str):
        """
        base64转化为dict类型配置
        :param prot:
        :param tp:
        :param b64str:
        :return:
        """
        if prot == "vmess":
            ret = json.loads(parse.unquote(base64.b64decode(
                b64str + "==").decode()).replace("\'", "\""))
            region = ret['ps']

        elif prot == "shadowsocks":
            string = b64str.split("#")
            cf = string[0].split("@")
            if len(cf) == 1:
                tmp = parse.unquote(base64.b64decode(cf[0] + "==").decode())
            else:
                tmp = parse.unquote(base64.b64decode(
                    cf[0] + "==").decode() + "@" + cf[1])
                print(tmp)
            ret = {
                "method": tmp.split(":")[0],
                "port": tmp.split(":")[2],
                "password": tmp.split(":")[1].split("@")[0],
                "add": tmp.split(":")[1].split("@")[1],
            }
            region = parse.unquote(string[1])

        ret["prot"] = prot
        return ret

    def setconf(self, region, socks, proxy=None):
        """
        生成配置
        :param region: 当前VPN别名
        :param socks: socks端口
        :return:
        """
        use_conf = self.conf[region]
        conf = copy.deepcopy(common.tpl)
        conf["inbounds"][0]["port"] = socks

        #  如果是vmess
        if use_conf['prot'] == "vmess":
            conf['outbounds'][0]["protocol"] = "vmess"
            conf['outbounds'][0]["settings"]["vnext"] = list()
            conf['outbounds'][0]["settings"]["vnext"].append({
                "address": use_conf["add"],
                "port": int(use_conf["port"]),
                "users": [
                    {
                        "id": use_conf["id"],
                        "alterId": int(use_conf["aid"]),
                        "security": "auto",
                        "level": 8,
                    }
                ]
            })
            # webSocket 协议
            if use_conf["net"] == "ws":
                conf['outbounds'][0]["streamSettings"] = {
                    "network": use_conf["net"],
                    "security": "tls" if use_conf["tls"] else "",
                    "tlssettings": {
                        "allowInsecure": True,
                        "serverName": use_conf["host"] if use_conf["tls"] else ""
                    },
                    "wssettings": {
                        "connectionReuse": True,
                        "headers": {
                            "Host": use_conf['host']
                        },
                        "path": use_conf["path"]
                    }
                }
            # mKcp协议
            elif use_conf["net"] == "kcp":
                conf['outbounds'][0]["streamSettings"] = {
                    "network": use_conf["net"],
                    "kcpsettings": {
                        "congestion": False,
                        "downlinkCapacity": 100,
                        "header": {
                            "type": use_conf["type"] if use_conf["type"] else "none"
                        },
                        "mtu": 1350,
                        "readBufferSize": 1,
                        "tti": 50,
                        "uplinkCapacity": 12,
                        "writeBufferSize": 1
                    },
                    "security": "tls" if use_conf["tls"] else "",
                    "tlssettings": {
                        "allowInsecure": True,
                        "serverName": use_conf["host"] if use_conf["tls"] else ""
                    }
                }
            # tcp
            elif use_conf["net"] == "tcp":
                conf['outbounds'][0]["streamSettings"] = {
                    "network": use_conf["net"],
                    "security": "tls" if use_conf["tls"] else "",
                    "tlssettings": {
                        "allowInsecure": True,
                        "serverName": use_conf["host"] if use_conf["tls"] else ""
                    },
                    "tcpsettings": {
                        "connectionReuse": True,
                        "header": {
                            "request": {
                                "version": "1.1",
                                "method": "GET",
                                "path": [use_conf["path"]],
                                "headers": {
                                    "User-Agent": [
                                        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"],
                                    "Accept-Encoding": ["gzip, deflate"],
                                    "Connection": ["keep-alive"],
                                    "Pragma": "no-cache",
                                    "Host": [use_conf["host"]]
                                }
                            },
                            "type": use_conf["type"]
                        }
                    } if use_conf["type"] != "none" else {}
                }
            # QUIC
            # elif use_conf["net"] == "quic":
            #     conf['outbounds'][0]["streamSettings"] = {
            #         "network": use_conf["net"],
            #         "security": "tls" if use_conf["tls"] else "none",
            #         "tlssettings": {
            #             "allowInsecure": True,
            #             "serverName": use_conf["host"]
            #         },
            #         "quicsettings": {
            #             "headers": {
            #                 "type": use_conf['type']
            #             },
            #             "key":
            #         }
            #     }
        # 如果是ss
        elif use_conf['prot'] == "shadowsocks":
            conf['outbounds'][0]["protocol"] = "shadowsocks"
            conf['outbounds'][0]["settings"]["servers"] = list()
            conf['outbounds'][0]["settings"]["servers"].append({
                "address": use_conf["add"],
                "port": int(use_conf["port"]),
                "password": use_conf["password"],
                "ota": False,
                "method": use_conf["method"]
            })
            conf['outbounds'][0]["streamSettings"] = {
                "network": "tcp"
            }
        else:
            raise MyException("不支持的协议类型")

        # 是否进行透明代理
        # if proxy and use_conf['prot'] == "vmess":
        #     # 修改入站协议

        #     conf["inbounds"].append({
        #         "tag": "transparent",
        #         "port": 12345,
        #         "protocol": "dokodemo-door",
        #         "settings": {
        #             "network": "tcp,udp",
        #             "followRedirect": True,
        #             "timeout": 30
        #         },
        #         "sniffing": {
        #             "enabled": True,
        #             "destOverride": [
        #                 "http",
        #                 "tls"
        #             ]
        #         },
        #         "streamSettings": {
        #             "sockopt": {
        #                 "tproxy": "tproxy"  # 透明代理使用 TPROXY 方式
        #             }
        #         }
        #     })

        #     # 配置dns
        #     conf['dns']["servers"] = [
        #         "8.8.8.8",  # 非中国大陆域名使用 Google 的 DNS
        #         "1.1.1.1",
        #         "114.114.114.114",
        #         {
        #             "address": "223.5.5.5",
        #             "port": 53,
        #             "domains": [
        #                 "geosite:cn",
        #                 "ntp.org",
        #                 use_conf['host']
        #             ]
        #         }
        #     ]

        #     # 每一个outbounds添加mark
        #     conf['outbounds'][0]["streamSettings"]["sockopt"] = {"mark": 255}
        #     conf['outbounds'][1]["settings"] = {"domainStrategy": "UseIP"}
        #     conf['outbounds'][1]["streamSettings"] = dict()
        #     conf['outbounds'][1]["streamSettings"]["sockopt"] = {"mark": 255}

        #     conf['outbounds'].append({
        #         "tag": "dns-out",
        #         "protocol": "dns",
        #         "streamSettings": {
        #             "sockopt": {
        #                 "mark": 255
        #             }
        #         }
        #     })
        #     # 配置路由
        #     conf['routing']["rules"].append({
        #         "type": "field",
        #         "inboundTag": [
        #             "transparent"
        #         ],
        #         "port": 53,   # 劫持53端口UDP流量，使用V2Ray的DNS
        #         "network": "udp",
        #         "outboundTag": "dns-out"
        #     })
        #     conf['routing']['rules'].append({
        #         "type": "field",
        #         "inboundTag": [
        #             "transparent"
        #         ],
        #         "port": 123,  # 直连123端口UDP流量（NTP 协议）
        #         "network": "udp",
        #         "outboundTag": "direct"
        #     })
        #     conf["routing"]["rules"].append({
        #         "type": "field",  # 设置DNS配置中的国内DNS服务器地址直连，以达到DNS分流目的
        #         "ip": [
        #             "223.5.5.5",
        #             "114.114.114.114"
        #         ],
        #         "outboundTag": "direct"
        #     })
        #     conf["routing"]["rules"].append({
        #         "type": "field",
        #         "ip": [
        #             "8.8.8.8",  # 设置 DNS 配置中的国内 DNS 服务器地址走代理，以达到DNS分流目的
        #             "1.1.1.1"
        #         ],
        #         "outboundTag": "proxy"
        #     })
        #     conf["routing"]["rules"].append({
        #         "type": "field",
        #         "protocol": ["bittorrent"],  # BT流量直连
        #         "outboundTag": "direct"
        #     })

        #     if proxy == 1:  # 国内网站直连：
        #         conf["routing"]["rules"].append({
        #             "type": "field",
        #             "ip": [
        #                "geoip:private",
        #                "geoip:cn"
        #             ],
        #             "outboundTag": "direct"
        #         })
        #         conf["routing"]["rules"].append({
        #             "type": "field",
        #             "domain": [
        #                 "geosite:cn"
        #             ],
        #             "outboundTag": "direct"
        #         })
        #     else:  # gfw
        #         conf["routing"]["rules"].append({
        #             "type": "field",
        #             "domain": [
        #                 "ext:h2y.dat:gfw"
        #             ],
        #             "outboundTag": "proxy"
        #         })
        #         conf["routing"]["rules"].append({
        #             "type": "field",
        #             "network": "tcp,udp",
        #             "outboundTag": "direct"
        #         })

        with open(self.config_path, "w") as f:
            f.write(json.dumps(conf, indent=4))

    def delconf(self, region):
        """
        删除一个配置
        :param region: 配置名
        :return:
        """
        self.conf.pop(region)
        try:
            self.saved_conf['local'].pop(region)
        except KeyError:
            self.saved_conf['subs'].pop(region)
        except:
            raise MyException("配置删除出错，请稍后再试..")

        with open(self.ndata_path, "wb") as jf:
            pickle.dump(self.saved_conf, jf)

    def parse_conf_by_uri(self, uri):
        uri_type = self.get_uri_type(uri)
        op = uri.split("://")
        ret = self.b642conf(uri_type, op[1])
        return ret

    def add_conf_by_uri(self, uri):
        """
        通过分享的连接添加配置
        """

        ret = self.parse_conf_by_uri(uri)
        op = uri.split("://")
        if op[0] == "vmess":
            region = ret['ps']
        elif op[0] == "ss":
            string = op[1].split("#")
            region = parse.unquote(string[1])
        if region in self.saved_conf["subs"]:
            region = region + "_local"
        self.add_conf(region, ret)

    def add_conf(self, region, node):
        self.saved_conf[["local", "subs"][0]][region] = node
        self.conf = dict(self.saved_conf['local'], **self.saved_conf['subs'])

        with open(self.ndata_path, "wb") as jf:
            pickle.dump(self.saved_conf, jf)

    def conf2b64(self, region):
        tmp = dict()
        prot = self.conf[region]['prot']
        for k, v in self.conf[region].items():
            tmp[k] = v
        tmp.pop("prot")
        if prot == "vmess":
            return prot + "://" + base64.b64encode(str(tmp).encode()).decode()
        else:
            prot = "ss"
            return prot + "://" + base64.b64encode("{}:{}@{}:{}".format(tmp["method"],
                                                                        tmp["password"], tmp["add"],
                                                                        tmp["port"]).encode()).decode() + "#" + region

    @pyqtSlot(name='updPac')
    def upd_pac(self):
        _thread.start_new_thread(self.__upd_pac, ())

    def __upd_pac(self):
        proxies = {
            "http": "http://127.0.0.1:10809",
            "https": "http://127.0.0.1:10809",
        }

        try:
            r = requests.get("https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt", proxies=proxies)
            rt = base64.b64decode(r.content).decode()

            ignoredLineBegins = ['!', '[']
            rt_array = rt.splitlines()

            new_rt_array = []
            for l in rt_array:
                if not (l.startswith(ignoredLineBegins[0]) or l.startswith(ignoredLineBegins[1])):
                    if not (l.isspace() or len(l) == 0):
                        new_rt_array.append(l)

            json_str = json.dumps(new_rt_array, indent=2)
            self.pac_conf = v2ray_adpt.adpt.replace('__RULES__', json_str)
            self.pac_conf = self.pac_conf.replace('__PROXY__', 'PROXY {0}:{1};'.format('127.0.0.1', '10809'))
            with open(self.pac_name, 'w') as f:
                f.write(self.pac_conf)
            self.updPacStateSignal.emit('success')
        except:
            self.updPacStateSignal.emit('error')

    def handle_client(self, client_socket):
        """
        处理客户端请求
        """
        # 获取客户端请求数据
        client_socket.recv(1024)
        # 构造响应数据
        response_start_line = "HTTP/1.1 200 OK\r\n"
        # response_body = self.pac_conf.replace('\n','\r\n')
        response_headers = "Server: Microsoft-HTTPAPI/2.0\r\nContent-Type: application/x-ns-proxy-autoconfig\r\nContent-Length: {}\r\n".format(
            len(self.pac_conf.encode('utf-8')))
        response = response_start_line + response_headers + "\r\n" + self.pac_conf

        # 向客户端返回响应数据
        client_socket.send(bytes(response, "utf-8"))

        # 关闭客户端连接
        client_socket.close()

    def pac_web_server(self):
        """
        开启pac web 服务
        """
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_socket.bind(("", 18001))
        server_socket.listen(128)

        print('开始pac运行服务')
        while True:
            client_socket, client_address = server_socket.accept()
            logging.debug("[%s, %s]请求" % client_address)
            _thread.start_new_thread(self.handle_client, (client_socket,))

    def set_proxy(self, op):
        if op == 'Off':
            disable_proxy()
        else:
            if op == 'ProxyOnly':
                set_proxy_server('127.0.0.1:10809')
            elif op == 'PacOnly':
                set_proxy_auto('http://127.0.0.1:18001/')


# 异常
class MyException(Exception):
    def __init__(self, *args):
        self.args = args


v2ray_instance = V2ray()
