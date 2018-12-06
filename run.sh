#!/bin/bash
docker volume create test
docker run -p 1486:1486 -v /Users/nsimsiri/Documents/code/web/strain/random-sample-core/src:/test -p 8050:8050 --rm --name sample sample