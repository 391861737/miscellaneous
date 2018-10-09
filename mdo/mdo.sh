#!/bin/bash

##################
# Author liuxy   #
##################

# -------------------- global var ---------------------#
# Define root path # 定义mdo根目录
rootpath=/home/mdo
# Make sure it does exist no matter what # 确保根目录的存在
if [ ! -d $rootpath ]; then
    mkdir -p $rootpath
fi
# -------------------- host's map ---------------------#
# Store old IFS and assign an new one # 保存旧的IFS(分隔符)，然后分配一个新的，也就是冒号
OIFS="$IFS"
IFS=":"
# Declare a hmap of Array type # 定义一个(linux的)Array类型的hmap
declare -A hmap=()
# Read lines from file "hlist", and put all the key value pairs into hmap 
# 读取hlist文件(与脚本同路径下)，把其中以分隔符分隔的k/v对存入map
# key为主机的别名，value为主机的ip地址或主机名
while read line 
do
    pair=($line)
    hmap[${pair[0]}]=${pair[1]}
done < hlist
# Restore IFS
IFS=$OIFS

# -------------------- functions  ---------------------#
# Pick a key's value from hmap, and if there's none, then you'll get itself for its value
# 从hmap中拣选别名所对应的ip地址或主机名
function pick {
    local v=${hmap[$1]}
    if [ "$v" = "" ]; then
        echo $1
    else
        echo $v
    fi
}

# Let a remote host remember me. 
# The remote host will not be asked for password while accessing me if function is called successfully
# 让一只远程机记住我
# 如果这个函数调用成功，将来远程机通过ssh访问我的时候，我就不会跟它要密码了
function remember {
    ssh root@$1 <<EOF
ssh-keygen -t rsa




EOF

    ff get $1 /root/.ssh id_rsa.pub $rootpath
    cat $rootpath/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
}

# Let me impress the remote host the reverse way the function "remember" does
# 让远程机记住我
function impress {
    ssh-keygen -t rsa <<EOF



    
EOF

    ssh-copy-id root@$1
    ssh root@$1 <<EOF
if [ ! -d $rootpath ]; then
    mkdir -p $rootpath
fi    
EOF
}

#################################
#                               #
# $1 from $2 at $3 of $4 to $5  #
# e.g.                          #
# get from 172.16.2.2 at /home/ #
# of data.file to /local/       #
#                               #
#################################
function ff {
    sftp root@$2 <<EOF
cd $3
lcd $5
$1 $4
bye    
EOF
}

# 开始表演一个sftp命令
# Act a sftp command
function act {
    # $1 from $2 at $rootpath of $3 to $rootpath
    ff $1 $2 $rootpath $3 $rootpath
}

# 在远程机的指定目录下执行一个命令，命令最多可以有7节字符串
# Run a command on a remote host
function run {
    ssh root@$1 <<EOF
set -v
cd $2
$3 $4 $5 $6 $7 $8 $9
exit
EOF
}

# 在远程机上请求一个(它所能访问的url)，将响应输出到文件中，然后传回到mdo根路径里
# Request an url, output the Responsed content into a file, then transfer it back into rootpath
function html {
    local fn=$(date "+%Y_%m_%d_%H%M%S").html
    run $1 . curl -o $rootpath/$fn $2
    act get $1 $rootpath/$fn
}

function cmd {
    if [ "$2" = "" ]; then
        usage
        exit
    fi
    case $1 in 
        "pick" ) echo pick;;
        "run" ) echo run;;
        "remember" ) echo remember;;
        "impress" ) echo impress;;
        "put" ) echo act put;;
        "get" ) echo act get;;
        "act" ) echo act;;
        "html" ) echo html;;
        * ) exit
    esac
}

# do at all the hosts difined in hmap which is parsed from hlist
function all {
    for k in ${!hmap[@]}
    do
        $(cmd $1) ${hmap[$k]} $2 $3 $4 $5 $6 $7 $8
    done
}

function init {
    all impress
}

# print usage
function usage {
    echo "usage: "
    echo "  pick <hostname>"
    echo "  run <hostname> <cmd> ..."
    echo "  remember <hostname>"
    echo "  impress <hostname>"
    echo "  put <hostname> <filename>"
    echo "  get <hostname> <filename>"
    echo "  act <hostname> <sftp command> ..."
    echo "  html <hostname> <url>"
    echo "  all <command above without hostname>"
}

# -------------------- api        ---------------------#
case $1 in 
    pick) pick $2;;
    run|remember|impress|put|get|act|html ) $(cmd $1) $(pick $2) $3 $4 $5 $6 $7 $8 $9;;
    all) all $2 $3 $4 $5 $6 $7 $8 $9;;
    "") exit;;
	*) usage
esac
