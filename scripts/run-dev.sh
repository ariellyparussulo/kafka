#!/usr/bin/env bash

BROKER_NAME="broker"

ZOOKEEPER="zookeeper:2181"
TOPIC_NAME="topic"
PARTITIONS="10"
REPLICATION_FACTOR=1
NUM_BROKERS=1

wait_for_container_to_start () {
    CONTAINER_NAME=$1

    while true; do
        echo "Waiting for container ${CONTAINER_NAME} to be running"
        CONTAINER_STATE=$(docker container ls --filter "label=com.docker.compose.service=${CONTAINER_NAME}" --format '{{.State}}')

        if [[ ${CONTAINER_STATE} == "running" ]]; then
            echo "Container is running."
            break;
        fi

        sleep 5
    done
}

wait_for_broker_connection () {
    BROKER_NAME=$1

    wait_for_container_to_start "${BROKER_NAME}"

    while true; do
        echo "Waiting for broker to stablish connection with zookeeper..."
        NUM_CONNECTIONS=$(curl -q http://localhost:8080/commands/stats | jq '.["server_stats"]["num_alive_client_connections"]')

        if [[ ${NUM_CONNECTIONS} -eq ${NUM_BROKERS} ]]; then
            echo "Broker ready to be used."
            break;
        fi

        sleep 5
    done

    sleep 10
}

docker-compose build
docker-compose up -d

BROKER_ID=$(docker container ls --filter "label=com.docker.compose.service=${BROKER_NAME}" --format '{{.ID}}')

wait_for_broker_connection "${BROKER_NAME}"

echo "Creating ${TOPIC_NAME} topic..."

docker exec -it ${BROKER_ID} /opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --zookeeper ${ZOOKEEPER} --topic ${TOPIC_NAME} --partitions 10 --replication-factor ${REPLICATION_FACTOR}
docker exec -it ${BROKER_ID} /opt/bitnami/kafka/bin/kafka-topics.sh --alter --zookeeper ${ZOOKEEPER} --topic ${TOPIC_NAME}
docker exec -it ${BROKER_ID} /opt/bitnami/kafka/bin/kafka-topics.sh --describe --zookeeper ${ZOOKEEPER} --topic ${TOPIC_NAME}
echo "Done."