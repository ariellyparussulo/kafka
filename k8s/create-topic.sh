#!/usr/bin/env bash

FIRST_BROKER="broker-0"

ZOOKEEPER="zookeeper:2181"
TOPIC_NAME="status"
PARTITIONS=10
REPLICATION_FACTOR=3

TOPIC_CREATED=0
while [[ TOPIC_CREATED -eq 0 ]]; do
  BROKERS_STATUS=$(kubectl get statefulsets.apps broker -o json | jq '.status')
  READY_REPLICAS=$(echo $BROKERS_STATUS | jq '.readyReplicas')

  if [[ $REPLICATION_FACTOR -lt $READY_REPLICAS ]]; then
    echo "Replicas are not ready yet. Waiting for pods to be ready."
    sleep 5
  fi

  kubectl exec -it "$FIRST_BROKER" -- /opt/kafka/bin/kafka-topics.sh --create --if-not-exists --zookeeper "$ZOOKEEPER" --topic "$TOPIC_NAME" --partitions "$PARTITIONS" --replication-factor "$REPLICATION_FACTOR"
  kubectl exec -it "$FIRST_BROKER" -- /opt/kafka/bin/kafka-topics.sh --describe --zookeeper "$ZOOKEEPER"
  TOPIC_CREATED=1
done

echo "Done."