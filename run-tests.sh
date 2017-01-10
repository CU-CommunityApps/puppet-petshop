#!/bin/bash

docker build -t petshop-puppet-test . && \
docker run -i petshop-puppet-test rake spec && \
docker run -i petshop-puppet-test rake validate