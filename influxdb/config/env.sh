#!/bin/bash

source influx.env
envsubst < template.conf > influxdb.conf
envsubst < database_template.sh > database.sh
rm template.conf
rm database_template.sh
