#!/bin/bash

wget https://github.com/ncabatoff/process-exporter/releases/download/v0.7.5/process-exporter-0.7.5.linux-amd64.tar.gz
tar xvzf process-exporter-0.7.5.linux-amd64.tar.gz
cp process-exporter-0.7.5.linux-amd64/process-exporter /usr/local/bin
chown deploy:deploy /usr/local/bin/process-exporter
systemctl daemon-reload
systemctl start process_exporter
systemctl enable process_exporter
rm -r process-exporter-0.7.5.linux-amd64
rm process-exporter-0.7.5.linux-amd64.tar.gz

