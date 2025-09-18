"""
先以常规的循环方式一边读字典，一边发起请求，再将请求结果进行判断。200和300的显示，其它不显示。

再测试一秒钟能发起请求的速度是多少个。
全局变量 字典文件打开句柄，队列。

网址请求函数一个，主进程将参数、字典文件、线程调用 初始化完成之后，各线程自己去以锁的方式去读取字典并发起请求
（读之前先判断文件位置指针是否已到最后，或者说是否已读完），最后将响应结果打印在屏幕（以锁的方式打印）。

打开一个文件首先统计他有多少行，另外，每个线程读取一次 在全局计数器就加一，在屏幕打印响应结果的同时，
也把计数器/总量 显示出来，这样就清楚进度了
"""

import threading
import argparse
import requests
import time
import sys

# url = 'http://192.168.56.1:8090/'
# dict_file = './word.txt'
count = 0   #单词读取计数器
total = 0   #字典文件行数
read_line_lock = threading.Lock()   #读文件锁
print_word_lock = threading.Lock()  #打印屏幕锁
f = None    #字典文件句柄【全局】

def url_client(url):        #URL 请求客户端
    proxies = {
        "http":  "http://127.0.0.1:8080",
        "https": "http://127.0.0.1:8080",
    }
    # r = requests.request(method='GET',url=url,proxies=proxies)    #抓包测试
    try:
        r = requests.request(method='GET',url=url)      #正式使用
    except Exception:
        return 0        #为了可以正常回收主进程打开的线程，此处在通信中断的情况下依旧会正常返回一个值。
    return r.status_code

def request_speed_test(url,time_s):   #URL 请求速度测试 每秒约 30 次
    n=0
    start = time.time()
    while True:
        stop = time.time()
        if stop-start>=time_s:
            break
        n+=1
        code = url_client(url+str(n))
        print(n,':',code)

def count_lines(filename):      #文件行数粗略统计
    count = 0
    with open(filename, "rb") as f:  # 二进制模式更快
        for chunk in iter(lambda: f.read(1024 * 1024), b""):  # 每次 1MB
            count += chunk.count(b"\n")
    return count

def dict_brute(url,n):      #目录爆破主程序
    global count
    global f
    while True:
        read_line_lock.acquire()
        word = f.readline()
        read_line_lock.release()
        if word == '':
            break
        elif word[0] == '#':        #将字典开头注释的行跳过
            continue
        word = word.strip()
        code = url_client(url+word)
        if code == 0:
            print("通信异常，停止爆破！")
            break
        print_word_lock.acquire()
        print(count,'/',total,end='')
        print("\r",end='')
        if code == 200 or code == 300:
            print('线程' + str(n) + ':' + word + ':' + str(code))
        print_word_lock.release()

        count += 1

def main():
    global f
    global total

    parse = argparse.ArgumentParser(description='这是一个目录爆破器。', add_help=True)
    parse.add_argument('-u','--url',nargs=1,type=str,dest='url')
    parse.add_argument('-d','--dict',nargs=1,type=str,dest='dict')
    parse.add_argument('-t','--threads', nargs=1,type=str,dest='thread',default='2')
    arg = parse.parse_args()
    try:
        url = arg.url[0]
        dict_file = arg.dict[0]
        thread_num = int(arg.thread[0])
        if url == '' and dict_file == '':
            raise Exception
    except Exception:
        print('命令语法错误')
        sys.exit()

    # url = 'http://192.168.56.1:8090/'
    # dict_file = './word.txt'
    # thread_num = 2
    total = count_lines(dict_file)
    f = open(dict_file,'r')
    threads = []

    for n in range(thread_num):
        threads.append(threading.Thread(target=dict_brute,args=(url,n)))
    for t in threads:
        t.start()
    print("爆破开始：")
    for t in threads:
        t.join()
    f.close()
    print("爆破结束！")

main()