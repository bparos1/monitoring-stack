#!/bin/bash

## Creates the Database
influx -execute "CREATE DATABASE $database"

## Sets Database Configurations
influx -database $database -execute "CREATE USER $uname WITH PASSWORD '$pword'"
influx -database $database -execute "GRANT ALL PRIVILEGES TO $uname"
influx -database $database -execute "CREATE RETENTION POLICY $policy ON $database DURATION $time $replication default"

## Exits shell
exit
