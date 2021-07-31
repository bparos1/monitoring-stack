#!/bin/bash

## Perform scheduled backup of volume
docker stop $name
docker run --rm --volumes-from $name -v $HOME/backup:/backup ubuntu bash -c “cd /var/lib/influxdb && tar cvf $HOME/backup/volume_$name.tar .”

docker start $name
