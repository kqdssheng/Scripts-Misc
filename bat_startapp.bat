@echo off
setlocal enabledelayedexpansion
::bat命令使用格式，startapp.bat type path
::注意编码方式为 ANSI 或 GB2312 否则脚本可能无法运行。

set type=%1
::set length=0
set arguments=%*

::以循环的方式将参数中包含的type类型字串去除，顺便也可计算length的长度。echo %length%
:loop
if defined type (
    set type=%type:~1%
	set arguments=%arguments:~1%
    set /a length+=1				
    goto loop
)

set exe=""
set py2="C:\Users\28419\Desktop\kali-tool\bin\python2\python.exe"
set py3="C:\Users\28419\Desktop\kali-tool\bin\Python3\python.exe"
set pip3="C:\Users\28419\Desktop\kali-tool\bin\Python3\Scripts\pip3.exe"
set jdk8="C:\Users\28419\Desktop\kali-tool\bin\jdk8\bin\java.exe"
set jdk17="C:\Users\28419\Desktop\kali-tool\bin\jdk17\bin\java.exe"
set jdk20="C:\Users\28419\Desktop\kali-tool\bin\jdk20\bin\java.exe"
set go="C:\Users\28419\Desktop\kali-tool\bin\go\bin\go.exe"

set readme="C:\Users\28419\Desktop\kali-tool\README.txt"

::exe应用启动
if "%1" == "exe" (
%arguments%
exit
)

::python2应用启动
if "%1" == "py2" (
%py2% %arguments%
exit
)

::python3应用启动
if "%1" == "py3" (
%py3% %arguments%
exit
)

::pip3应用启动
if "%1" == "pip3" (
%pip3% %arguments%
exit
)

::jdk8应用启动
if "%1" == "jdk8" (
%jdk8% %arguments%
exit
)

::jdk17应用启动
if "%1" == "jdk17" (
%jdk17% %arguments%
exit
)

::jdk20应用启动
if "%1" == "jdk20" (
%jdk20% %arguments%
exit
)

::go应用启动
if "%1" == "go" (
%go% %arguments%
exit
)

type %readme%
echo 格式错误或不支持，请按照以下格式执行:
echo "startapp.bat [exe|py2|py3|pip3|jdk8|jdk17|jdk20|go] [option] app_path"