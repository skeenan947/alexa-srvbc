#!/bin/bash
cd /tmp
docker pull skeenan947/alexa-srvbc
RAILS_ENV=production docker-compose -f  alexa-srvbc.yml up -d