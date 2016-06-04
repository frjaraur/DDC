#!/bin/sh
action=$1
nodename=$2
ucprole=$3
ucpcontrollerip=$4
ucpip=$5
ucpsan=$6

UCP_CONTROLLER_PROVISIONED=/tmp/ucp_controller_provisioned

echo $*
echo "-------"
echo "HOSTNAME: $(hostname)"
echo "UCP ROLE: $ucprole"
echo "UCP CONTROLLER IP: $ucpcontrollerip"
echo "UCP MYIP: $ucpip"
echo "-----------------"
echo "ACTION: $action"


case $ucprole in
	controller)
	if [ ! -f $UCP_CONTROLLER_PROVISIONED ]
	then
	echo docker run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock \
		docker/ucp install --host-addressdocker run --rm -it \
		--name ucp -v /var/run/docker.sock:/var/run/docker.sock \
		docker/ucp install --host-address $ucpip --san $ucpsan
	fi
	touch $UCP_CONTROLLER_PROVISIONED
	;;

	*)
		echo "Undefined DDC UCP role"
	;;

esac
