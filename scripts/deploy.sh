#!/bin/bash
[ -d ~/.ssh ] || mkdir ~/.ssh
openssl aes-256-cbc -K $encrypted_b293f50235e4_key -iv $encrypted_b293f50235e4_iv \
    -in id_travis.enc -out ~/.ssh/id_rsa -d
chmod 0600 ~/.ssh/id_rsa
scp -p scripts/run.sh skeenan@skeenan.net:/tmp/run-alexa-srvbc.sh
scp -p scripts/docker-compose.yml skeenan@skeenan.net:/tmp/alexa-srvbc.yml
ssh skeenan@skeenan.net /tmp/run-alexa-srvbc.sh