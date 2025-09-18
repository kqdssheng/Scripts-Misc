#!/usr/bin/env sh
# 请根据实际情况修改代理IP和端口
proxy_ip=192.168.56.1
proxy_port=7890

# 要安装的基本命令和扩展命令列表
base_cmd="git zsh"
extend_cmd="tealdeer fzf thefuck trash-cli locate"

# 颜色和格式设置
FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

# 用户继续与否确认
yes_or_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "请输入 y 或 n.";;
        esac
    done
}

# 网络检测
network_check() {
    wget -q -T 2 -O /dev/null www.google.com && code=0 || code=1
    if [ $code -eq 0 ]; then
        echo "${FMT_GREEN}网络通畅，可以正常工作。${FMT_RESET}"
        return
    fi

    echo "${FMT_YELLOW}网络不通，尝试配置代理...${FMT_RESET}"
    sleep 1
    echo "${FMT_GREEN}配置代理中...${FMT_RESET}"
    export http_proxy=http://$proxy_ip:$proxy_port
    export https_proxy=http://$proxy_ip:$proxy_port
    export no_proxy=$proxy_ip,localhost
    export HTTP_PROXY=http://$proxy_ip:$proxy_port
    export HTTPS_PROXY=http://$proxy_ip:$proxy_port
    export NO_PROXY=$proxy_ip,localhost
    echo "${FMT_GREEN}代理配置完毕，正在测试网络连接...${FMT_RESET}"

    wget -q -T 2 -O /dev/null www.google.com && code=0 || code=1
    if [ $code -eq 0 ]; then
        echo "${FMT_GREEN}网络通畅，代理工作正常。${FMT_RESET}"
    else
        echo "${FMT_RED}网络不通，代理工作异常，请检查好网络设置之后再继续。${FMT_RESET}"
        exit
    fi
}

# oh-my-zsh 工具安装
omz_install() {
    echo "${FMT_GREEN}正在安装基本命令和扩展命令...${FMT_RESET}"
    sleep 1

    if [ "$(command -v sudo)" ]; then
        sudo apt update
        sleep 1
        sudo apt install -y $base_cmd $extend_cmd
    else
        apt update
        sleep 1
        apt install -y $base_cmd $extend_cmd
    fi
    
    if [ $? -ne 0 ]; then
        echo "${FMT_RED}基本命令和扩展命令安装失败，请检查网络和 APT 源设置。${FMT_RESET}"
        exit
    fi

    echo "${FMT_GREEN}基本命令和扩展命令安装完毕,接下来开始安装 ohmyzsh...${FMT_RESET}"
    sleep 1
    wget -O /tmp/install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    
    if [ $? -ne 0 ]; then
        echo "${FMT_RED}ohmyzsh 安装脚本下载失败，请检查网络。${FMT_RESET}"
        exit
    fi

    sed -i '/^RUNZSH/s/yes/no/' /tmp/install.sh
    sh /tmp/install.sh

    echo "${FMT_GREEN}ohmyzsh 安装完毕,接下来开始安装 zsh-autosuggestions 插件...${FMT_RESET}"
    sleep 1
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "${FMT_GREEN}zsh-autosuggestions 插件安装完毕${FMT_RESET}"

    echo "${FMT_GREEN}接着开始修改 zsh 的配置文件...${FMT_RESET}"
    sleep 1
    sed -i '/^ZSH_THEME/s/ZSH_THEME=/ZSH_THEME="maran" #/' ~/.zshrc
    sed -i '/^plugins/s/plugins=/plugins=(z fzf aliases tldr themes thefuck zsh-autosuggestions) #/' ~/.zshrc
    sed -i '$a \
# 自定义开始 \
#eval $(thefuck --alias c)\
alias rm="trash"\
alias zshconfig="nano ~/.zshrc"\
alias ohmyzsh="cd ~/.oh-my-zsh"\
# 自定义结束\
' ~/.zshrc
    echo "export FZF_COMPLETION_TRIGGER='\'" >> ~/.zshrc
    echo "${FMT_GREEN}zsh 配置完毕${FMT_RESET}"

    echo "${FMT_GREEN}正在配置 zsh-autosuggestions 插件...${FMT_RESET}"
    sleep 1
    sed -i '/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=/s/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#00ff00,bg=black,bold,underline" #/' ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    echo "${FMT_GREEN}zsh-autosuggestions 插件配置完毕${FMT_RESET}"

    echo "${FMT_GREEN}正在配置 tldr 插件...${FMT_RESET}"
    sleep 1
    sed -i '/^bindkey/s/bindkey/#bindkey/' ~/.oh-my-zsh/plugins/tldr/tldr.plugin.zsh
    sed -i '$a bindkey "^t" tldr-command-line' ~/.oh-my-zsh/plugins/tldr/tldr.plugin.zsh
    echo "${FMT_GREEN}tldr 插件配置完毕${FMT_RESET}"
}

# 主程序
main() {
    network_check
    yes_or_no "是否继续安装 ohmyzsh ？" && omz_install || echo "用户取消安装 ohmyzsh。"
    sleep 1
    echo "${FMT_GREEN}所有工具安装和配置完毕，请重启终端或运行 'source ~/.zshrc' 以应用更改。${FMT_RESET}"
}

main