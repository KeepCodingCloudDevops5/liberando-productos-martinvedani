#!/bin/bash

for ((i=1;i<=1000000;i++)); do 
    curl -X 'GET' \
        'http://0.0.0.0:8081/' \
        -H 'accept: application/json'
done