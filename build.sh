#! /bin/bash
export TAG=$(date +%Y%m%d-%H%M%S)
docker-compose -f docker-compose.yml -f docker-compose.build.yml -f docker-compose.latest.yml build
