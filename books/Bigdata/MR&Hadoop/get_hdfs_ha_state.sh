#!/bin/bash 

NN1_HOSTNAME=""
NN2_HOSTNAME=""
NN1_SERVICEID=""
NN2_SERVICEID=""
NN1_SERVICESTATE=""
NN2_SERVICESTATE=""

CDH_BIN_HOME=/opt/cloudera/parcels/CDH/bin

ha_name=$(${CDH_BIN_HOME}/hdfs getconf -confKey dfs.nameservices)
namenode_serviceids=$(${CDH_BIN_HOME}/hdfs getconf -confKey dfs.ha.namenodes.${ha_name})

for node in $(echo ${namenode_serviceids//,/ }); do
	state=$(${CDH_BIN_HOME}/hdfs haadmin -getServiceState $node)

	if [ "$state" == "active" ]; then
		NN1_SERVICEID="${node}"
		NN1_SERVICESTATE="${state}"
		NN1_HOSTNAME=`echo $(${CDH_BIN_HOME}/hdfs getconf -confKey dfs.namenode.rpc-address.${ha_name}.${node}) | awk -F ':' '{print $1}'`
		#echo "${NN1_HOSTNAME} : ${NN1_SERVICEID} : ${NN1_SERVICESTATE}"

	elif [ "$state" == "standby" ]; then
		NN2_SERVICEID="${node}"
		NN2_SERVICESTATE="${state}"
		NN2_HOSTNAME=`echo $(${CDH_BIN_HOME}/hdfs getconf -confKey dfs.namenode.rpc-address.${ha_name}.${node}) | awk -F ':' '{print $1}'`
		#echo "${NN2_HOSTNAME} : ${NN2_SERVICEID} : ${NN2_SERVICESTATE}"
	else
		echo "hdfs haadmin -getServiceState $node: unkown"
	fi

done

echo "                                                                "
echo "Hostname		Namenode_Serviceid		Namenode_State"
echo "${NN1_HOSTNAME}		${NN1_SERVICEID}		${NN1_SERVICESTATE}"
echo "${NN2_HOSTNAME}		${NN2_SERVICEID}		${NN2_SERVICESTATE}"
