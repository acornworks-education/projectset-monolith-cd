#!/bin/bash

docker-compose build
docker-compose up -d database
docker-compose run flyway
docker-compose up -d monolith

echo "To run a frontend go to src/frontend then run yarn start"