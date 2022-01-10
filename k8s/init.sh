#!/usr/bin/env bash

echo "Starting minikube..."
minikube start

echo "Enabling the Ingress Controller..."
minikube addons enable ingress

echo "Creating kafka cluster..."
kubectl apply -f kafka.yaml

echo "Creating kafka topic..."
./create-topic.sh

echo "create producer server..."
kubectl apply -f producer.yaml

echo "Create ingress for the cluster..."
kubectl apply -f ingress.yaml

echo "Create consumer..."
kubectl apply -f consumer.yaml