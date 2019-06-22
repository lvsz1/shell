#!/bin/bash

# 通过 ssh隧道 登录mysql
# ssh隧道 可参考 https://www.zsythink.net/archives/2450

# 获取对应模块的mysql配置
function getMysqlConfig()
{
	if [ $# != 1 ]; then
		return 1
	fi
	m=$1 

	# @todo 填充mysql配置
	case $m in
		"module" )
			mysqlConfig="host:ip:user:password:db"
			;;
		* )
			return 1
	esac

	return 0
}

# 解析mysql配置
function parseMysqlConfig()
{
	if [ $# != 1 ]; then
		return 1
	fi
	config=$1

	local index=0
	for v in `echo $config | awk -F: '{print $1, $2, $3, $4, $5}'`
	do
		arr[$index]=$v
		index=$((index + 1))
	done

	host=${arr[0]}
	port=${arr[1]}
	user=${arr[2]}
	password=${arr[3]}
	db=${arr[4]}

	unset arr 
	return 0
}

# ssh tunnel 登录数据库
function loginMysql()
{
	ssh -NCPf $sshRemoteAddr  -L ${port}:${host}:${port} 
	mysql -h127.0.0.1 -P${port} -u${user} -p${password} -D${db}
}

# 结果校验
function checkResult()
{
	code=$?
	if [ $code != 0 ]; then 
		msg=$1
		echo "code:$code error:\"$msg\""
		exit $code
	fi
}


help="Usage: ssh_tunnel_mysql module"
if [ $# != 1 ]; then
	echo $helps
	exit 1
fi
module=$1

# ssh server地址
sshRemoteAddr=user@ip

mysqlConfig=
host=
port=
user=
password=
db=

getMysqlConfig $module
checkResult "not support module:$module"

parseMysqlConfig $mysqlConfig
checkResult "parse mysql config error:$mysqlConfig"
echo "host:$host port:$port user:$user password:$password db:$db"

loginMysql
