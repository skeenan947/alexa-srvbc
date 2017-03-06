#!/bin/bash
RAILS_ENV={$1:-development}

docker pull skeenan947/alexa-srvbc
docker-compose -f /tmp/alexa-srvbc.yml up -d