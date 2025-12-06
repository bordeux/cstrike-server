#!/usr/bin/env bash

set -e

docker build --platform=linux/amd64 -t cstrike .
docker run -it --platform=linux/amd64 --rm --user root -p 26900:26900/udp -p 27020:27020/udp -p 27015:27015/udp -p 27015:27015  --entrypoint /bin/bash cstrike