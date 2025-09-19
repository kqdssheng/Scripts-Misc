#!/usr/bin/env sh
# 请根据实际情况修改代理IP和端口
proxy_ip=192.168.56.1
proxy_port=7890

# 要安装的基本命令和扩展命令列表
base_cmd="git zsh"
extend_cmd="tealdeer fzf thefuck trash-cli locate"
docker_pkgs="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

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
    # 创建 zsh 自定义补全命令参数的目录【注：后续有新的补全命令需要添加直接放这即可】
    mkdir -p ~/.oh-my-zsh/custom/completions

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

# Docker 安装
docker_install(){
    wget -q -O /tmp/install-docker.sh https://get.docker.com/
    if [ $? -ne 0 ]; then
        echo "${FMT_RED}Docker 安装脚本下载失败，请检查网络。${FMT_RESET}"
        exit
    fi
    
    grep -i kali /etc/*release >/dev/null
    if [ $? -eq 0 ]; then
        sed -i '/apt_repo=/s/$dist_version/buster/' /tmp/install-docker.sh
    fi

    if yes_or_no "是否自定义安装 Docker 组件，还是使用默认设置？【第一次建议使用默认安装方式n，若不成功第二次再使用自定义安装放肆y】" ; then
        echo "${FMT_GREEN}正在配置 Docker 自定义组件...${FMT_RESET}"
        sleep 1
        #该处会修改 docker 安装脚本中 echo_docker_as_nonroot 字串的前两行处添加一个 pkgs 变量定义行
        sed -i "/apt-get.*pkgs/i pkgs='$docker_pkgs'" /tmp/install-docker.sh
        sed -i "/pkg_manager.*pkgs/i pkgs='$docker_pkgs'" /tmp/install-docker.sh
        echo "${FMT_GREEN}Docker 自定义组件配置完毕${FMT_RESET}"
    fi

    echo "${FMT_GREEN}正在安装 Docker...${FMT_RESET}"
    sleep 1
    if [ "$(command -v sudo)" ]; then
        sudo sh /tmp/install-docker.sh --mirror Aliyun
        #sudo usermod -aG docker $USER
    else
        sh /tmp/install-docker.sh --mirror Aliyun
        #usermod -aG docker $USER
    fi
    echo "${FMT_GREEN}Docker 安装完毕${FMT_RESET}"
}

# 其他工具下载
tools_download() {
    mkdir -p ~/tools;cd ~/tools

    # 下载 chsrc 工具
    echo "${FMT_GREEN}正在下载 chsrc 工具...${FMT_RESET}"
    sleep 1
    wget https://gitee.com/RubyMetric/chsrc/releases/download/pre/chsrc-x64-linux -O chsrc; chmod +x ./chsrc
    echo "${FMT_GREEN}chsrc 工具下载完毕${FMT_RESET}"

    # 拉取 clash-for-linux 工具
    echo "${FMT_GREEN}正在拉取 clash-for-linux 工具...${FMT_RESET}"
    sleep 1
    git clone https://github.com/wnlen/clash-for-linux
    echo "${FMT_GREEN}clash-for-linux 工具拉取完毕${FMT_RESET}"

    # 下载 vfox 工具【单文件至 /user/local/bin 目录】
    echo "${FMT_GREEN}正在安装 vfox 工具...${FMT_RESET}"
    sleep 1
    curl -sSL https://raw.githubusercontent.com/version-fox/vfox/main/install.sh | bash
    echo "${FMT_GREEN}vfox 工具安装完毕${FMT_RESET}"
}

# 主程序
main() {
    network_check
    yes_or_no "是否继续安装 ohmyzsh ？" && omz_install || echo "用户取消安装 ohmyzsh。"
    sleep 1
    yes_or_no "是否继续安装 Docker ？" && docker_install || echo "用户取消安装 Docker。"
    sleep 1
    yes_or_no "是否继续下载其他常用工具 ？" && tools_download || echo "用户取消下载其他常用工具。"
    sleep
    echo "${FMT_GREEN}所有工具安装和配置完毕，请重启终端或运行 'source ~/.zshrc' 以应用更改。${FMT_RESET}"
}

main
