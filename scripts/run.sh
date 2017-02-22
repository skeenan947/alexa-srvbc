#!/bin/bash
IMAGE=$1
docker rm -f alexa-srvbc
docker run -d -p127.0.0.1:9899:4567 --name=alexa-srvbc $IMAGE