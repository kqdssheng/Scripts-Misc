@echo off
setlocal enabledelayedexpansion
::bat����ʹ�ø�ʽ��startapp.bat type path

set type=%1
::set length=0
set arguments=%*

::��ѭ���ķ�ʽ�������а�����type�����ִ�ȥ����˳��Ҳ�ɼ���length�ĳ��ȡ�echo %length%
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

::exeӦ������
if "%1" == "exe" (
%arguments%
exit
)

::python2Ӧ������
if "%1" == "py2" (
%py2% %arguments%
exit
)

::python3Ӧ������
if "%1" == "py3" (
%py3% %arguments%
exit
)

::pip3Ӧ������
if "%1" == "pip3" (
%pip3% %arguments%
exit
)

::jdk8Ӧ������
if "%1" == "jdk8" (
%jdk8% %arguments%
exit
)

::jdk17Ӧ������
if "%1" == "jdk17" (
%jdk17% %arguments%
exit
)

::jdk20Ӧ������
if "%1" == "jdk20" (
%jdk20% %arguments%
exit
)

::goӦ������
if "%1" == "go" (
%go% %arguments%
exit
)

type %readme%
echo ��ʽ�����֧�֣��밴�����¸�ʽִ��:
echo "startapp.bat [exe|py2|py3|pip3|jdk8|jdk17|jdk20|go] [option] app_path"