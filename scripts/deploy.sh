#!/bin/bash
[ -d ~/.ssh ] || mkdir ~/.ssh
openssl aes-256-cbc -K $encrypted_b293f50235e4_key -iv $encrypted_b293f50235e4_iv \
    -in id_travis.enc -out ~/.ssh/id_travis -d
scp -p scripts/run.sh skeenan@skeenan.net:/tmp/run-alexa-srvbc.sh
ssh skeenan@skeenan.net /tmp/run-alexa-srvbc.sh $REPO:$TAG
