#!/bin/bash

source prometheus.env
envsubst < template.yml > prometheus.yml
rm template.yml
