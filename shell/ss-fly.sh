#! /bin/bash
# Copyright (c) 2018 flyzy2005

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
usage () {
        cat $DIR/sshelp
}

wrong_para_prompt() {
    echo "参数输入错误!$1"
}

install() {
        if [[ "$#" -lt 1 ]]
        then
          wrong_para_prompt "请输入至少一个参数作为密码"
          return 1
        fi
        port="1024"
        if [[ "$#" -ge 2 ]]
        then
          port=$2
        fi
        if [[ $port -le 0 || $port -gt 65535 ]]
        then
          wrong_para_prompt "端口号输入格式错误，请输入1到65535"
          exit 1
        fi
        echo "{
    \"server\":\"0.0.0.0\",
    \"server_port\":$port,
    \"local_address\": \"127.0.0.1\",
    \"local_port\":1080,
    \"password\":\"$1\",
    \"timeout\":300,
    \"method\":\"aes-256-cfb\"
}" > /etc/shadowsocks.json
        apt-get update
        apt-get install -y python-pip
        pip install --upgrade pip
        pip install setuptools
        pip install shadowsocks
        chmod 755 /etc/shadowsocks.json
        apt-get install python-m2crypto
        command -v ssserver >/dev/null 2>&1 || { echo >&2 "请确保你服务器（服务器，不是你自己的电脑）的系统是Ubuntu。如果系统是Ubuntu，似乎因为网络原因ss没有安装成功，请再执行一次搭建ss脚本代码。如果试了几次还是不行，执行reboot命令重启下服务器之后再试下，如果还是不行，请联系flyzy小站。"; exit 1; } 

        #可通过help command 或者man command来查看command的意思。
        #此处用command -V的意思就是提供一个详细说明（我理解应该是后面这堆“”里面的东西），而command本身的意思是绕过正常查询指令的途径，而只执行内建指令或者指定PATH的
        #在这里，前半部分指令command -v ssserver >/dev/null 2>&1，意思是试试ssserver这个指令是否存在，怎么去识别呢？用command -V ssserver,如果指令被找到，退出状态为0，不然为1. shell里面 0是真，1是假，可以通过 man 1 test 来看
        #||表示或，所以只要前半部分执行出错，就执行||右边的东西. echo >&2 "balabalabala" 意思是把引号里这堆东西写入&2，然后退出，返回1.

        ps -fe|grep ssserver |grep -v grep > /dev/null 2>&1
        #前半部分指令ps -ef|grep ssserver |grep -v grep意思是看进程，匹配ssserver，但是不匹配字符grep。（grep -v表示不匹配，后面跟字符）
        if [ $? -ne 0 ]
        then
          ssserver -c /etc/shadowsocks.json -d start
        else
          ssserver -c /etc/shadowsocks.json -d restart
        fi
        rclocal=`cat /etc/rc.local`
        if [[ $rclocal != *'ssserver -c /etc/shadowsocks.json -d start'* ]]
        then
          sed -i '$i\ssserver -c /etc/shadowsocks.json -d start'  /etc/rc.local
        fi
        echo "安装成功~尽情冲浪吧
您的配置文件内容如下（server在客户端中需要配置成你VPS的IP）："
        cat /etc/shadowsocks.json
}

install_bbr() {
        sysfile=`cat /etc/sysctl.conf`
        if [[ $sysfile != *'net.core.default_qdisc=fq'* ]]
        then
                echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        fi
        if [[ $sysfile != *'net.ipv4.tcp_congestion_control=bbr'* ]]
        then
                echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        fi
        sysctl -p > /dev/null
        i=`uname -r | cut -f 2 -d .`
        if [ $i -le 9 ]
        then
                if
                echo '准备下载镜像文件...' && wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.2/linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb
                then
                        echo '镜像文件下载成功，开始安装...' && dpkg -i linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb && update-grub && echo '镜像安装成功，系统即将重启，重启后bbr将成功开启...' && reboot
                else
                        echo '下载内核文件失败，请重新执行安装BBR命令'
                        exit 1
                fi
        fi
        result=`sysctl net.ipv4.tcp_available_congestion_control`
        if [[ $result == *'bbr'* ]]
        then
                echo 'BBR已开启成功'
        else 
                echo 'BBR开启失败，请重试'
        fi
}

install_ssr() {
        wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
        chmod +x shadowsocksR.sh
        ./shadowsocksR.sh 2>&1 | tee shadowsocksR.log
}

uninstall_ss() {
        ps -fe|grep ssserver |grep -v grep > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
          ssserver -c /etc/shadowsocks.json -d stop
        fi
        pip uninstall -y shadowsocks
        rm /etc/shadowsocks.json
        rm /var/log/shadowsocks.log
        echo 'shadowsocks卸载成功'
}

if [ "$#" -eq 0 ]; then
        usage
        exit 0
fi

case $1 in
        -h|h|help )
                usage
                exit 0;
                ;;
        -v|v|version )
                echo 'ss-fly Version 1.0, 2018-01-20, Copyright (c) 2018 flyzy2005'
                exit 0;
                ;;
esac

if [ "$EUID" -ne 0 ]; then
        echo '必需以root身份运行，请使用sudo命令'
        exit 1;
fi

case $1 in
        -i|i|install )
        install $2 $3
                ;;
        -bbr )
        install_bbr
                ;;
        -ssr )
        install_ssr
                ;;
        -uninstall )
        uninstall_ss
                ;;
        * )
                usage
                ;;
esac
wangxingchuandeMacBook-Pro:ss-fly central$ 
