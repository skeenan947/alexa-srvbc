#!/bin/bash
IMAGE=$1
docker pull $IMAGE
docker rm -f alexa-srvbc
docker run -td -p127.0.0.1:9899:5000 --name=alexa-srvbc $IMAGE
