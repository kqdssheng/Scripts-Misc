import socket
from time import sleep
host = '192.168.56.20'
# host = '127.0.0.1'
port = 1234
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock2 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
def main_lin(s):
    while True:
        while True:
            cmd = input('>')
            if cmd == '':
                continue
            else:
                break
        cmd = cmd + '\n'
        s.send(cmd.encode())
        try:
            recv = s.recv(4096,).decode()
            print(recv, end='')
        except Exception:
            pass

def main_win(s):

    recv = sock.recv(4096).decode(encoding='gbk')
    print(recv, end='')
    while True:
        cmd = input()
        cmd = cmd + '\n'
        sock.send(cmd.encode(encoding='gbk'))
        sleep(1)
        recv = sock.recv(4096).decode(encoding='gbk')
        print(recv, end='')


try:
    sock.connect((host,port))
    sock.settimeout(2)
    # sock2.connect((host, port))
except Exception as e:
    print("连接异常", e)
else:
    print("连接成功")
    main_lin(sock)# for so in [sock,sock2]:
finally:
    sock.close()
    sock2.close()
    print("连接关闭")