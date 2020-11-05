# ZTool
PyQt5 + Qt Quick Controller2

## 功能
- Mysql快速启动 / 密码修改，无需原始密码 / 快捷可视化配置
- V2ray 客户端 快速配置，链接导入，PAC、全局代理
- Aria2 下载
- Host编辑
- 短链接生成
- 蓝奏云解析
- 微信机器人（时间调度自动发送消息）定时向女朋友发送消息，可设置浮动、定时、cron，程序员必备暖心神器
- 多语言热切换
## 技术栈
- IDE：PyCharm + Qt creator
- 前端：PyQt5.10.1 Qml 自定义UI组件
- 后端：Python 3.7.2
- 数据库：Mysql 5.6
- 配置：yaml
- 日志：logging
## 安装
### 步骤
#### 安装依赖包
```
pip install -r .\requirements.txt
```
#### 打包
````
pyinstaller .\package.spec
````
#### 启动运行
````
# shell 环境
pyrcc5 .\ui\qml.qrc -o .\ui\qml_rc.py | python ./main.py
````

#### 可执行程序下载
##### 1.0下载
https://github.com/lzx8589561/ZTool/releases/download/F0.0.1/MysqlTool.7z
##### 2.0下载
https://github.com/lzx8589561/ZTool/releases/download/V2.0.0/ZTool.7z

## 预览
### 2.0版本预览
![预览图](preview/1.png)
![预览图](preview/2.png)
![预览图](preview/3.png)
![预览图](preview/4.png)
![预览图](preview/5.png)
![预览图](preview/6.png)
![预览图](preview/7.png)
![预览图](preview/8.png)
![预览图](preview/9.png)
![预览图](preview/10.png)
![预览图](preview/11.png)
![预览图](preview/12.png)
![预览图](preview/13.png)
![预览图](preview/14.png)
![预览图](preview/15.png)
![预览图](preview/16.png)
![预览图](preview/17.png)

### 1.0版本预览 源码到release下载
![预览图](preview/demo.gif)
#### 配置
##### mysql
- 默认端口 3309
- 默认root密码 123456
