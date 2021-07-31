#!/bin/bash

## Begin initial deployment step
cd config
./env.sh
cd ..
docker-compose --env-file=docker.env up -d

## Wait for container to be functional
sleep 1m

## Create and configure Influx database
docker cp ./config/database.sh influxdb:./database.sh
docker exec -d influxdb chmod 0700 ./database.sh
docker exec -d influxdb chattr -s ./database.sh
docker exec -it influxdb ./database.sh
docker exec -d influxdb rm -f ./database.sh

## Begins backup procedure
./backup/backup.sh
