#!/bin/sh

mkdir -p ~/Tools
cd ~/Tools/

sudo apt-get install ninja-build \
     gettext libtool libtool-bin \
     autoconf automake cmake g++ \
     pkg-config unzip

has_neovim=$(ls | grep neovim)

echo $has_neovim

if [ -n "$has_neovim" ]; then

read -p "Do you want to delete neovim folder? (y/n) " yn

case $yn in
	[Yy]* ) echo "ok, deleting folder"; rm -rf neovim;;
	[Nn]* ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac

fi

echo "Cloning neovim"
git clone https://github.com/neovim/neovim.git

cd neovim
git checkout stable

rm -rf build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/Tools/neovim"
make install

export PATH="$HOME/Tools/neovim/bin:$PATH"
