#!/usr/bin/env bash

git submodule update --init --recursive --remote

cp ./dotbot/tools/git-submodule/install .
./install
rm -f ./install
