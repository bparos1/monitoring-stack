#!/bin/bash

wget https://github.com/prometheus/node_exporter/releases/download/v1.1.1/node_exporter-1.1.1.linux-amd64.tar.gz
tar xvzf node_exporter-1.1.1.linux-amd64.tar.gz 
cp node_exporter-1.1.1.linux-amd64/node_exporter /usr/local/bin
chown deploy:deploy /usr/local/bin/node_exporter
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
rm -r node_exporter-1.1.1.linux-amd64
rm node_exporter-1.1.1.linux-amd64.tar.gz 
