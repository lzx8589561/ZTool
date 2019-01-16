# mysql-tool
PyQt5 + Qt Quick Mysql管理工具
--------
快速安装Mysql 5.6数据库，只需解压运行点击安装即可。绿色运行，方便迁移，后面会做各个版本之间切换

压缩之后工具+Mysql5.6仅30M左右
## 功能
- 快速安装
- 快速启动
- 密码修改，无需原始密码
- 快捷可视化配置
- 多语言热切换
## 技术栈
- IDE：PyCharm + Qt creator
- 前端：PyQt5 qml 自定义UI组件
- 后端：Python 3.7.2
- 数据库：Mysql 5.6
- 配置：yaml

## 安装
### 步骤
#### 安装php依赖包
```
pip install PyQt5
pip install PyYAML
pip install configparser
pip install pyinstaller
```
#### 启动运行
````
# shell 环境
pyrcc5 .\ui\qml.qrc -o .\ui\qml_rc.py | python d:/PythonWorkspace/mysql-tool/main.py
````
#### 打包
````
pyinstaller .\main.spec
````
#### 配置
##### mysql
- 默认端口 3309
- 默认root密码 123456

## 预览
### 首页
![预览图](preview/demo.gif)
