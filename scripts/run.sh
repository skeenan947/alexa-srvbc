#!/bin/bash
IMAGE=$1
docker pull $IMAGE
docker rm -f alexa-srvbc
docker run -td -e RAILS_ENV=production -p127.0.0.1:9899:5000 --name=alexa-srvbc $IMAGE
