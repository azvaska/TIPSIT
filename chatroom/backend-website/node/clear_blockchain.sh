#!/bin/bash

sudo rm -rf node*/state.db 
sudo rm -rf node*/data 
sudo rm -rf node*/prev-state.json 
sudo rm -rf node*/state.json
sudo rm -rf node*/txs
sudo rm -rf node*/txs1
sudo rm -rf node*/config/*
sudo docker-compose build
sudo docker-compose up -d;
sleep 15;
echo "slept 15 seconds";
rm -rf node*.log
docker-compose logs node1 > node1.log
docker-compose logs node2 > node2.log
sudo docker-compose down -t 1
sudo python change_id.py
# cp node1/static_config/config.toml node1/config/config.toml
# cp node2/static_config/config.toml node2/config/config.toml
sudo docker-compose build
sudo docker-compose up 
