#!/bin/bash

## Loads backup image
docker load −i ∽/backup/$name.tar

## Creates temp volume and duplicates backup data to it
docker volume create volume_'$name'_temp
docker run --rm -v volume_'$name'_tempt:/recover -v ~/backup:/backup ubuntu bash -c “cd /recover && tar xvf /backup/volume_'$name'.tar”

## Runs recovered image
docker run -d -v volume_'$name'_tempt:/var/lib/influxdb -p 8086:8086 $name
