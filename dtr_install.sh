#!/bin/bash -x
#global_action, nodename, ucpcontrollerip, ucpip, ucpsan, dtrurl
action=$1
nodename=$2
ucpcontrollerip=$3
ucpip=$4
ucpsan=$5
dtrurl="https://${ucpip}"

VAGRANT_PROVISION_DIR=/tmp_deploying_stage
VAGRANT_LICENSES_DIR=/licenses

#UCP admin/PASSWORD
ucpuser="admin"
ucppasswd="orca"

DTR_PROVISIONED=${VAGRANT_PROVISION_DIR}/ucp_controller_provisioned
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

[ -f ${UCP_INFO} ] && echo "UCP isn't provisioned yet ... can not install DTR" && exit 0

if [ -f ${DTR_NODE_PROVISIONED} ]
then
	echo "---- DTR INSTALL ----"
	curl -k https://${ucpcontrollerip}/ca > ${VAGRANT_PROVISION_DIR}/ucp-ca.pem

	docker run --rm --name simple-ucp-tools -v /tmp_deploying_stage:/OUTDIR hopla/simple-ucp-tools -n https://10.0.100.10
	export DOCKER_TLS_VERIFY=1
	export DOCKER_CERT_PATH="/tmp_deploying_stage"
	export DOCKER_HOST=tcp://${ucpcontrollerip}:443


	echo docker run --rm \
	  docker/dtr install \
		--ucp-url https://${ucpcontrollerip} \
		--ucp-node ${nodename} \
	  --dtr-external-url ${dtrurl} \
	  --ucp-username ${ucpuser} --ucp-password ${ucppasswd} \
	  --ucp-ca "$(cat ${VAGRANT_PROVISION_DIR}/ucp-ca.pem)"

		docker run --rm \
		  docker/dtr install \
		  --ucp-url https://${ucpcontrollerip} \
		  --ucp-node ${nodename} \
		  --dtr-external-url ${dtrurl} \
		  --ucp-username ${ucpuser} --ucp-password ${ucppasswd} \
		  --ucp-ca "$(cat ${VAGRANT_PROVISION_DIR}/ucp-ca.pem)"

			echo ${dtrurl} > ${DTR_PROVISIONED}
			touch ${DTR_NODE_PROVISIONED}

fi
