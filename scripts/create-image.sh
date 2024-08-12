#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ACR=reddogacr.azurecr.io

PROJECT=$DIR/..

for component in $(cat ./services)
do
    cd $PROJECT/$component

    mvn clean package

    IMAGE=$ACR/reddogs/$component

    docker build . -f Dockerfile-multi-stage -t $IMAGE

    docker push $IMAGE
done
