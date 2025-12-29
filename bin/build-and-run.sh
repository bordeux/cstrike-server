#!/usr/bin/env bash

set -e

docker build --platform=linux/amd64 -t cstrike --no-cache .
docker run -it  --platform=linux/amd64 -e HLTV_ENABLE=1 --rm -p 26900:26900/udp -p 27020:27020/udp -p 27015:27015/udp -p 27015:27015 -p 8080:8080 cstrike