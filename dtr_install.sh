#!/bin/bash -x
#global_action, nodename, ucpcontrollerip, ucpip, ucpsan, dtrurl
action=$1
nodename=$2
ucpcontrollerip=$3
ucpip=$4
ucpsan=$5
dtrurl="https://${ucpip}"
ucpurl="${ucpcontrollerip}:8443"

VAGRANT_PROVISION_DIR=/tmp_deploying_stage
VAGRANT_LICENSES_DIR=/licenses

#UCP admin/PASSWORD
ucpuser="admin"
ucppasswd="orca"

DTR_INFO=${VAGRANT_PROVISION_DIR}/dtr_info
UCP_INFO=${VAGRANT_PROVISION_DIR}/ucp_info

echo "PARAMETERS: [$*]"
echo "-------"
echo "HOSTNAME: $(hostname)"
echo "DTR URL: ${dtrurl}"
echo "UCP CONTROLLER IP: ${ucpcontrollerip}"
echo "UCP MYIP: ${ucpip}"
echo "-----------------"
echo "ACTION: ${action}"


DTR_NODE_PROVISIONED=${VAGRANT_PROVISION_DIR}/dtr_${nodename}.provisioned

[ ! -f ${UCP_INFO} ] && echo "UCP isn't provisioned yet ... can not install DTR" && exit 0

if [ ! -f ${DTR_NODE_PROVISIONED} ]
then
	echo "---- DTR INSTALL ----"
	#echo 	curl -k https://${ucpurl}/ca > ${VAGRANT_PROVISION_DIR}/ucp-ca.pem

	curl -o ${VAGRANT_PROVISION_DIR}/ucp-ca.pem -sSk https://${ucpurl}/ca
	sleep 5
	cat ${VAGRANT_PROVISION_DIR}/ca.pem
  #wget -q --no-check-certificate https://10.0.100.10/ca -O -wget -q --no-check-certificate https://10.0.100.10/ca -O - > ${VAGRANT_PROVISION_DIR}/ucp-ca.pem

	docker run --rm --name simple-ucp-tools -v /tmp_deploying_stage:/OUTDIR frjaraur/simple-ucp-tools -n https://${ucpurl}

	export DOCKER_TLS_VERIFY=1
	export DOCKER_CERT_PATH="/tmp_deploying_stage"
	export DOCKER_HOST=tcp://${ucpurl}


	echo docker run --rm \
	  docker/dtr install \
		--ucp-url https://${ucpurl} \
		--ucp-node ${nodename} \
	  --dtr-external-url ${dtrurl} \
	  --ucp-username ${ucpuser} --ucp-password ${ucppasswd} \
	  --ucp-ca "$(cat ${VAGRANT_PROVISION_DIR}/ucp-ca.pem)"

		docker run --rm \
		  docker/dtr install \
		  --ucp-url https://${ucpurl} \
		  --ucp-node ${nodename} \
		  --dtr-external-url ${dtrurl} \
		  --ucp-username ${ucpuser} --ucp-password ${ucppasswd} \
		  --ucp-ca "$(cat ${VAGRANT_PROVISION_DIR}/ucp-ca.pem)"

		if [ $? -eq 0 ]
		then
			echo ${dtrurl} > ${DTR_INFO}
			touch ${DTR_NODE_PROVISIONED}
		fi

fi
