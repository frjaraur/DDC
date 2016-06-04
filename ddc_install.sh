#!/bin/sh
nodename=$1
ucprole=$2
ucpcontrollerip=$3
ucpip=$4
ucpsan=$5

echo $*
echo "-------"
echo "HOSTNAME: $(hostname)"
echo "UCP ROLE: $ucprole"
echo "UCP CONTROLLER IP: $ucpcontrollerip"
echo "UCP MYIP: $ucpip"

case $ucprole in
	controller)
	echo docker run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock \
		docker/ucp install --host-addressdocker run --rm -it \
		--name ucp -v /var/run/docker.sock:/var/run/docker.sock \
		docker/ucp install --host-address $ucpip --san $ucpsan

	;;

	*)
		echo "Undefined DDC UCP role"	
	;;

esac
