#!/bin/bash
IMAGE=$1
docker pull $IMAGE
docker pull redis
docker run -d --name redis -p 6379:6379 redis
docker rm -f alexa-srvbc
docker run -td -e RAILS_ENV=production -p127.0.0.1:9899:5000 --name=alexa-srvbc $IMAGE
