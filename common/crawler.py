import requests
import re
import json
from bs4 import BeautifulSoup

def lanzou_download(url):
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 Edg/79.0.309.51',
        'origin': 'https://www.lanzous.com'
        }
    # 请求下载页面
    strhtml = requests.get(url, headers=headers)
    soup = BeautifulSoup(strhtml.text)
    # 拿到iframe地址
    data = soup.select('body > div.d > div.d2 > div.ifr > iframe')
    dowhtml = requests.get('https://www.lanzous.com'+data[0]['src'], headers=headers)
    soup = BeautifulSoup(dowhtml.text)
    # 拿到ajax请求脚本
    data = soup.select('body > script')
    # 正则取签名
    print(data[0].string)
    sg_var = re.findall( r'\tvar ajaxup = \'(.*)\';', data[0].string, re.M|re.I)

    if len(sg_var) > 0:
        sg = sg_var[0]
    else:
        searchObj = re.findall( r'\tdata(.*)\'sign\':\'(.*?)\'', data[0].string, re.M|re.I)
        sg = searchObj[0][1]
    # 请求ajax获取跳转地址
    dowjsonStr = requests.post('https://www.lanzous.com/ajaxm.php',data={'action':'downprocess','sign':sg,'ves':'1'},headers={
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 Edg/79.0.309.51',
        'referer': 'https://www.lanzous.com/fn?' + sg,
        })
    dowjson = json.loads(dowjsonStr.text)
    # 请求跳转地址获取真实地址
    oragin = requests.get(dowjson['dom'] + '/file/' + dowjson['url'],allow_redirects=False ,headers={
        'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 Edg/79.0.309.51'
    })
    # 拿到302跳转地址
    downUrl = oragin.next.url
    return downUrl