#!/usr/bin/env bash

git submodule update --init --recursive --remote

mkdir -p ~/.config

cp ./dotbot/tools/git-submodule/install .
./install
rm -f ./install
