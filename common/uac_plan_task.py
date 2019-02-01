import logging
import os
import sys
from os.path import abspath
import xml.etree.ElementTree as ET
import tempfile


def exist_plan():
    """
    是否存在当前程序计划任务
    :return:
    """
    tem = os.popen('chcp 437 && schtasks.exe /Query /V /FO CSV /TN AdminZTool').readlines()
    tem2 = "".join(tem).lower()
    if tem2.find('taskname') != -1:
        logging.debug("find out plan task!")
        program_path = tem[2].split(',')[8].replace('"', '')
        if abspath(program_path) == abspath(sys.argv[0]):
            return True
    return False


def admin_plan():
    """
    自动检测并创建相应的计划任务
    :return:
    """
    if sys.argv[0].endswith('.exe'):
        logging.debug("current is package status!")
        if exist_plan():
            logging.debug("exists plan task,return")
            return

        # 尝试删除任务，不管有没有
        os.popen('schtasks.exe /Delete /F /TN AdminZTool')
        # 添加window 计划任务
        xml_content = """
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo />
  <Triggers />
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command></Command>
    </Exec>
  </Actions>
</Task>
        """
        out_file = os.path.abspath(os.path.join(tempfile.gettempdir(), 'temp_plan.xml'))
        ET.register_namespace('', "http://schemas.microsoft.com/windows/2004/02/mit/task")
        element = ET.fromstringlist(xml_content)
        tree = ET.ElementTree(element=element)
        el = tree.find(
            '{http://schemas.microsoft.com/windows/2004/02/mit/task}Actions/{http://schemas.microsoft.com/windows/'
            '2004/02/mit/task}Exec/{http://schemas.microsoft.com/windows/2004/02/mit/task}Command')
        el.text = sys.argv[0]
        tree.write(out_file, xml_declaration=True, encoding="UTF-16", method="xml")

        cmd = 'chcp 437 && schtasks.exe /Create /TN AdminZTool /XML ' + out_file
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        logging.debug("execute add plan result:" + tmp)


def start_plan_task():
    if exist_plan() and sys.argv[0].endswith('.exe'):
        cmd = 'chcp 437 && schtasks.exe /run /tn "AdminZTool" '
        tmp = os.popen(cmd).readlines()
        tmp = "".join(tmp).lower()
        logging.debug("execute start plan result:" + tmp)
        sys.exit()
