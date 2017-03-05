#!/bin/bash
cd /tmp
RAILS_ENV=production docker-compose -f  alexa-srvbc.yml up -d