#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ACR=reddogacr.azurecr.io
TAG=latest

PROJECT=$DIR/..

for component in accounting-service loyalty-service makeline-service order-service receipt-generation-service virtual-customers virtual-worker
do
    cd $PROJECT/$component

    mvn clean package
    [[ $? -ne 0 ]] && exit 1

    IMAGE=$ACR/reddogs/$component:$TAG

    docker build . -f Dockerfile -t $IMAGE

    docker push $IMAGE
done

exit 0

# openai-service
component=openai-service
IMAGE=$ACR/reddogs/$component:TAG

cd $PROJECT/generative-ai/az-openai

docker build . -f Dockerfile -t $IMAGE

docker push $IMAGE
