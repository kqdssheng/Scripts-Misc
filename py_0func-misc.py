"""
常用功能函数集锦
"""

def print_progress():   #简单进度条打印功能
    import time
    total = 100
    num = 0
    while num < total:
        print(num,'/',total,end='')
        time.sleep(0.01)
        print('\r',end='')
        num += 1

# print_progress()

def str_color(str,color):   #字符串上色功能
    Color = {
        #标准 8 色：黑白红蓝绿黄紫青。
        "RESET" : '\033[0m',
        "BLACK" : '\033[0;30m',
        "WHITE" : '\033[0;37m',
        "RED" : '\033[0;31m',
        "BLUE" : '\033[0;34m',
        "GREEN" : '\033[0;32m',
        "YELLOW" : '\033[0;33m',
        "PURPLE" : '\033[0;35m',
        "CYAN" : '\033[0;36m'
    }
    return Color[color] + str + Color["RESET"]

# print(str_color('hello','BLACK'),str_color('hello','WHITE'),str_color('hello','RED'),str_color('hello','BLUE'),str_color('hello','GREEN'),str_color('hello','YELLOW'),str_color('hello','PURPLE'),str_color('hello','CYAN'))

def args_init():     #命令行参数初始化
    pass
