#!/bin/bash 
docker build -t sample .
docker tag sample nsimsiri/sample:latest
docker push nsimsiri/sample:latest
