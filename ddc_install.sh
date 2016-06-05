#!/bin/bash -x
action=$1
nodename=$2
ucprole=$3
ucpcontrollerip=$4
ucpip=$5
ucpsan=$6

VAGRANT_PROVISION_DIR=/tmp_deploying_stage
VAGRANT_LICENSES_DIR=/licenses

echo "USER: $(whoami)"

UCP_CONTROLLER_PROVISIONED=${VAGRANT_PROVISION_DIR}/ucp_controller_provisioned
UCP_FINGERPRINT=""

echo "PARAMETERS: [$*]"
echo "-------"
echo "HOSTNAME: $(hostname)"
echo "UCP ROLE: ${ucprole}"
echo "UCP CONTROLLER IP: ${ucpcontrollerip}"
echo "UCP MYIP: ${ucpip}"
echo "-----------------"
echo "ACTION: ${action}"


UCP_NODE_PROVISIONED=${VAGRANT_PROVISION_DIR}/ucp_${nodename}.${ucprole}.provisioned

case ${ucprole} in
	controller)
		if [ ! -f ${UCP_CONTROLLER_PROVISIONED} ]
		then
			echo "---- UCP MASTER CONTROLLER INSTALL ----"
			echo docker run --rm \
			--name ucp -v ${VAGRANT_LICENSES_DIR}/docker_subscription.lic:/docker_subscription.lic \
			-v /var/run/docker.sock:/var/run/docker.sock \
			docker/ucp install --host-address ${ucpip} --san ${ucpsan}

			docker run --rm \
			--name ucp -v ${VAGRANT_LICENSES_DIR}/docker_subscription.lic:/docker_subscription.lic \
			-v /var/run/docker.sock:/var/run/docker.sock \
			docker/ucp install --host-address ${ucpip} --san ${ucpsan}


			echo "---- Preparing UCP Fingerprint ----"
			ucpfingerprint=$(docker run --rm --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp fingerprint )
			ucpcontrollerurl="https://${ucpcontrollerip}"

			echo ${ucpcontrollerurl} > ${UCP_CONTROLLER_PROVISIONED}
			echo ${ucpfingerprint} >> ${UCP_CONTROLLER_PROVISIONED}

			touch ${UCP_NODE_PROVISIONED}

		fi


	;;

	replica)
		if [ ! -f ${UCP_CONTROLLER_PROVISIONED} ]
		then
			echo "UCP manager not provisioned yet ..." && exit 0
		fi

		if [ ! -f ${UCP_NODE_PROVISIONED} ]
		then
			echo "---- UCP NODE INSTALL ----"

			echo docker run --rm --name ucp \
			-v /var/run/docker.sock:/var/run/docker.sock \
			docker/ucp join --replica --admin-username admin --admin-password orca \
			--host-address ${ucpip} --san ${ucpsan} \
			--url $(head -1 ${UCP_CONTROLLER_PROVISIONED}) \
			--fingerprint $(tail -1 ${UCP_CONTROLLER_PROVISIONED})

			docker run --rm --name ucp \
			-v /var/run/docker.sock:/var/run/docker.sock \
			docker/ucp join --replica --admin-username admin --admin-password orca \
			--host-address ${ucpip} --san ${ucpsan} \
			--url $(head -1 ${UCP_CONTROLLER_PROVISIONED}) \
			--fingerprint $(tail -1 ${UCP_CONTROLLER_PROVISIONED})

			#We will use old service standard
			service docker restart

			touch ${UCP_NODE_PROVISIONED}
		else
			echo "UCP replica ${nodename} already provioned ..." && exit 0
		fi


	;;



	node)
		if [ ! -f ${UCP_CONTROLLER_PROVISIONED} ]
		then
			echo "UCP manager not provisioned yet ..." && exit 0
		fi

		if [ ! -f ${UCP_NODE_PROVISIONED} ]
		then
			echo "---- UCP NODE INSTALL ----"

			echo docker run --rm --name ucp \
	  	-v /var/run/docker.sock:/var/run/docker.sock \
	  	docker/ucp join --admin-username admin --admin-password orca \
			--host-address ${ucpip} --san ${ucpsan} \
			--url $(head -1 ${UCP_CONTROLLER_PROVISIONED}) \
			--fingerprint $(tail -1 ${UCP_CONTROLLER_PROVISIONED})

			docker run --rm --name ucp \
	  	-v /var/run/docker.sock:/var/run/docker.sock \
	  	docker/ucp join --admin-username admin --admin-password orca \
			--host-address ${ucpip} --san ${ucpsan} \
			--url $(head -1 ${UCP_CONTROLLER_PROVISIONED}) \
			--fingerprint $(tail -1 ${UCP_CONTROLLER_PROVISIONED})

			#We will use old service standard
			service docker restart

			touch ${UCP_NODE_PROVISIONED}
		else
			echo "UCP node ${nodename} already provioned ..." && exit 0
		fi


	;;

	*)
		echo "Undefined DDC UCP role"
	;;

esac
