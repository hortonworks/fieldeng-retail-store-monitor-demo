#!/bin/bash

export AMBARI_HOST=$(hostname -f)
echo "*********************************AMABRI HOST IS: $AMBARI_HOST"

export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9!$\-]+')

if [[ -z $CLUSTER_NAME ]]; then
        echo "Could not connect to Ambari Server. Please run the install script on the same host where Ambari Server is installed."
        exit 1
else
       	echo "*********************************CLUSTER NAME IS: $CLUSTER_NAME"
fi

getServiceStatus () {
       	SERVICE=$1
       	SERVICE_STATUS=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/$SERVICE | grep '"state" :' | grep -Po '([A-Z]+)')

       	echo $SERVICE_STATUS
}

stopService () {
       	SERVICE=$1
       	SERVICE_STATUS=$(getServiceStatus $SERVICE)
       	echo "*********************************Stopping Service $SERVICE ..."
       	if [ "$SERVICE_STATUS" == STARTED ]; then
        TASKID=$(curl -u admin:admin -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context": "Stop $SERVICE"}, "ServiceInfo": {"state": "INSTALLED"}}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/$SERVICE | grep "id" | grep -Po '([0-9]+)')

        echo "*********************************Stop $SERVICE TaskID $TASKID"
        sleep 2
        LOOPESCAPE="false"
        until [ "$LOOPESCAPE" == true ]; do
            TASKSTATUS=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
            if [ "$TASKSTATUS" == COMPLETED ]; then
                LOOPESCAPE="true"
            fi
            echo "*********************************Stop $SERVICE Task Status $TASKSTATUS"
            sleep 2
        done
        echo "*********************************$SERVICE Service Stopped..."
       	elif [ "$SERVICE_STATUS" == INSTALLED ]; then
       	echo "*********************************$SERVICE Service Stopped..."
       	fi
}

startService (){
       	SERVICE=$1
       	SERVICE_STATUS=$(getServiceStatus $SERVICE)
       		echo "*********************************Starting Service $SERVICE ..."
       	if [ "$SERVICE_STATUS" == INSTALLED ]; then
        TASKID=$(curl -u admin:admin -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context": "Start $SERVICE"}, "ServiceInfo": {"state": "STARTED"}}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/$SERVICE | grep "id" | grep -Po '([0-9]+)')

        echo "*********************************Start $SERVICE TaskID $TASKID"
        sleep 2
        LOOPESCAPE="false"
        until [ "$LOOPESCAPE" == true ]; do
            TASKSTATUS=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
            if [ "$TASKSTATUS" == COMPLETED ]; then
                LOOPESCAPE="true"
            fi
            echo "*********************************Start $SERVICE Task Status $TASKSTATUS"
            sleep 2
        done
        echo "*********************************$SERVICE Service Started..."
       	elif [ "$SERVICE_STATUS" == STARTED ]; then
       	echo "*********************************$SERVICE Service Started..."
       	fi
}

retargetNifiFlowReporter() {
	sleep 1
	echo "*********************************Getting Nifi Reporting Task Id..."
	REPORTING_TASK_ID=$(curl -H "Content-Type: application/json" -X GET http://$AMBARI_HOST:9090/nifi-api/flow/reporting-tasks| grep -Po '("component":{"id":"[0-9a-zA-z\-]+","name":"AtlasFlowReportingTask)'| grep -Po 'id":"([0-9a-zA-z\-]+)'| grep -Po ':"([0-9a-zA-z\-]+)'| grep -Po '([0-9a-zA-z\-]+)')

	echo "*********************************Getting Nifi Reporting Task Revision..."
	REPORTING_TASK_REVISION=$(curl -X GET http://$AMBARI_HOST:9090/nifi-api/reporting-tasks/$REPORTING_TASK_ID |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)')

	echo "*********************************Stopping Nifi Reporting Task..."
	PAYLOAD=$(echo "{\"id\":\"$REPORTING_TASK_ID\",\"revision\":{\"version\":$REPORTING_TASK_REVISION},\"component\":{\"id\":\"$REPORTING_TASK_ID\",\"state\":\"STOPPED\"}}")

	curl -d "$PAYLOAD" -H "Content-Type: application/json" -X PUT http://$AMBARI_HOST:9090/nifi-api/reporting-tasks/$REPORTING_TASK_ID

	echo "*********************************Getting Nifi Reporting Task Revision..."
	REPORTING_TASK_REVISION=$(curl -X GET http://$AMBARI_HOST:9090/nifi-api/reporting-tasks/$REPORTING_TASK_ID |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)')

	echo "*********************************Removing Nifi Reporting Task..."
	curl -X DELETE http://$AMBARI_HOST:9090/nifi-api/reporting-tasks/$REPORTING_TASK_ID?version=$REPORTING_TASK_REVISION

	echo "*********************************Instantiating Reporting Task..."
	PAYLOAD=$(echo "{\"revision\":{\"version\":0},\"component\":{\"name\":\"AtlasFlowReportingTask\",\"type\":\"org.apache.nifi.atlas.reporting.AtlasFlowReportingTask\",\"properties\":{\"Atlas URL\":\"http://$DATAPLANE_ATLAS_HOST:$DATAPLANE_ATLAS_PORT\",\"Nifi URL\":\"http://$AMBARI_HOST:9090\"}}}")

	REPORTING_TASK_ID=$(curl -d "$PAYLOAD" -H "Content-Type: application/json" -X POST http://$AMBARI_HOST:9090/nifi-api/controller/reporting-tasks|grep -Po '("component":{"id":")([0-9a-zA-z\-]+)'| grep -Po '(:"[0-9a-zA-z\-]+)'| grep -Po '([0-9a-zA-z\-]+)')

	echo "*********************************Starting Reporting Task..."
PAYLOAD=$(echo "{\"id\":\"$REPORTING_TASK_ID\",\"revision\":{\"version\":1},\"component\":{\"id\":\"$REPORTING_TASK_ID\",\"state\":\"RUNNING\"}}")

	curl -d "$PAYLOAD" -H "Content-Type: application/json" -X PUT http://$AMBARI_HOST:9090/nifi-api/reporting-tasks/$REPORTING_TASK_ID
	sleep 1
}

getNameNodeHost () {
       	NAMENODE_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HDFS/components/NAMENODE|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	
       	echo $NAMENODE_HOST
}

getMetaStoreHost () {
       	METASTORE_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HIVE/components/HIVE_METASTORE|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	
       	echo $METASTORE_HOST
}

getKafkaBroker () {
       	KAFKA_BROKER=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/KAFKA/components/KAFKA_BROKER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	
       	echo $KAFKA_BROKER
}

getAtlasHost () {
       	ATLAS_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/ATLAS/components/ATLAS_SERVER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	
       	echo $ATLAS_HOST
}

#Need to recreate the Environment Variables since shell may have chnaged and BashRC script may not have loaded
NAMENODE_HOST=$(getNameNodeHost)
export NAMENODE_HOST=$NAMENODE_HOST
ZK_HOST=$AMBARI_HOST
export ZK_HOST=$ZK_HOST
KAFKA_BROKER=$(getKafkaBroker)
export KAFKA_BROKER=$KAFKA_BROKER
METASTORE_HOST=$(getMetaStoreHost)
export METASTORE_HOST=$METASTORE_HOST
COMETD_HOST=$AMBARI_HOST
export COMETD_HOST=$COMETD_HOST
env

echo "HOSTNAME of the Data Plane KAFKA BROKER: "
read DATAPLANE_KAFKA_BROKER
echo "Listening PORT of the Data Plane KAFKA BROKER (6667): "
read DATAPLANE_KAFKA_PORT
if [ -z $DATAPLANE_KAFKA_PORT ]; then
	DATAPLANE_KAFKA_PORT=6667
fi

echo "HOSTNAME of a Data Plane ZOOKEEPER: "
read DATAPLANE_ZK_HOST
echo "Listening PORT of Data Plane ZOOKEEPER (2181): "
read DATAPLANE_ZK_PORT
if [ -z $DATAPLANE_ZK_PORT ]; then
	DATAPLANE_ZK_PORT=2181
fi

echo "HOSTNAME of the Data Plane ATLAS SERVER: "
read DATAPLANE_ATLAS_HOST
echo "Listening PORT of the Data Plane ATLAS SERVER (21000): "
read DATAPLANE_ATLAS_PORT
if [ -z $DATAPLANE_ATLAS_PORT ]; then
	DATAPLANE_ATLAS_PORT=21000
fi

echo "HOSTNAME of a Data Plane HIVE METASTORE: "
read DATAPLANE_METASTORE_HOST

export ATLAS_HOST=$DATAPLANE_ATLAS_HOST

echo "*********************************DATA PLANE ATLAS ENDPOINT: $DATAPLANE_ATLAS_HOST:$DATAPLANE_ATLAS_PORT"
echo "*********************************DATA PLANE KAFKA ENDPOINT: $DATAPLANE_KAFKA_BROKER:$DATAPLANE_KAFKA_PORT"
echo "*********************************DATA PLANE ZOOKEEPER ENDPOINT: $DATAPLANE_ZK_HOST:$DATAPLANE_ZK_PORT"

echo "*********************************Setting Hive Atlas Client Configuration..."
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME hive-site "atlas.rest.address" "$DATAPLANE_ATLAS_HOST:$DATAPLANE_ATLAS_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME hive-atlas-application.properties "atlas.kafka.bootstrap.servers" "$DATAPLANE_KAFKA_BROKER:$DATAPLANE_KAFKA_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME hive-atlas-application.properties "atlas.kafka.zookeeper.connect" "$DATAPLANE_ZK_HOST:$DATAPLANE_ZK_PORT"

echo "*********************************Setting Storm Atlas Client Configuration..."
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME storm-atlas-application.properties "atlas.rest.address" "$DATAPLANE_ATLAS_HOST:$DATAPLANE_ATLAS_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME storm-atlas-application.properties "atlas.kafka.zookeeper.connect" "$DATAPLANE_ZK_HOST:$DATAPLANE_ZK_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME storm-atlas-application.properties "atlas.kafka.bootstrap.servers" "$DATAPLANE_KAFKA_BROKER:$DATAPLANE_KAFKA_PORT"

echo "*********************************Setting Sqoop Atlas Client Configuration..."
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME sqoop-atlas-application.properties "atlas.rest.address" "$DATAPLANE_ATLAS_HOST:$DATAPLANE_ATLAS_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME sqoop-atlas-application.properties "atlas.kafka.zookeeper.connect" "$DATAPLANE_ZK_HOST:$DATAPLANE_ZK_PORT"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME sqoop-atlas-application.properties "atlas.kafka.bootstrap.servers" "$DATAPLANE_KAFKA_BROKER:$DATAPLANE_KAFKA_PORT"

echo "*********************************Setting Hive Meta Store Configuration..."
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME hive-site "javax.jdo.option.ConnectionURL" "jdbc:mysql://$DATAPLANE_METASTORE_HOST/hive?createDatabaseIfNotExist=true"
/var/lib/ambari-server/resources/scripts/configs.sh set $AMBARI_HOST $CLUSTER_NAME hive-site "javax.jdo.option.ConnectionPassword" "hive"

echo "*********************************Restarting Services to refresh configurations..."
stopService HIVE
sleep 1
stopService STORM
sleep 1
stopService SQOOP
sleep 1
 
startService HIVE
sleep 1
startService STORM
sleep 1
startService SQOOP

git clone https://github.com/vakshorton/Utils
cd Utils/DataPlaneUtils
mvn clean package
java -jar target/DataPlaneUtils-0.0.1-SNAPSHOT-jar-with-dependencies.jar

echo "*********************************Redeploy Storm Topology..."
storm kill RetailTransactionMonitor
storm jar /home/storm/RetailTransactionMonitor-0.0.1-SNAPSHOT.jar com.hortonworks.iot.retail.topology.RetailTransactionMonitorTopology

# Start Nifi Flow Reporter to send flow meta data to Atlas
echo "*********************************Retargeting Nifi Flow Reporting Task..."
sleep 5
retargetNifiFlowReporter