#!/bin/bash
luarocks
if [ $? -eq 1 ]; then
    sudo pacman -S luarocks
fi
sudo luarocks install luadbi-postgresql
sudo pacman -S postgresql-libs
g++ src/dbm.cpp -lpq
