"""
用法示例：
python 0pyfile_To_oneline.py -f 0pyfile_To_oneline.py -e base32
"""

import base64
import argparse

def base64_encode(code,encode):
    if encode == 'base64':
        encoded = base64.b64encode(code.encode())
        return 'python -c "import base64;exec(base64.b64decode({}).decode())"'.format(encoded)
    elif encode == 'base32':
        encoded = base64.b32encode(code.encode())
        return 'python -c "import base64;exec(base64.b32decode({}).decode())"'.format(encoded)
    raise SyntaxError('encode error')


parse = argparse.ArgumentParser(description='该脚本可以将 py 文件转换成一行的命令行去执行。\n注意：脚本文件必须是执行即运行，不支持携带参数或交互。', add_help=True)
parse.add_argument('-f',required=True,nargs=1,type=str,dest='file',help='py file')
parse.add_argument('-e',required=True,nargs=1,type=str,choices=["base32","base64"],dest='encode',help='base64|32')

arg = parse.parse_args()
try:
    file = arg.file[0]
    encode = arg.encode[0]
    with open(file,mode='r',encoding='utf-8') as f:
        code = f.read()
    print(base64_encode(code,encode))
except Exception:
    print('命令语法错误')
    raise SystemExit


