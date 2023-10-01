#/bin/bash

# Copyright (c) 2023 hogedamari
# Released under the MIT license
# License notice:
# https:#github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

if [ $# -ne 1 ]; then
	echo "Not specified vim version"
	exit 1
fi

VIM_VERSION=$1

git clone https://github.com/vim/vim.git

cd vim/

git reset --hard HEAD
git checkout $VIM_VERSION
make || exit 1
make install || exit 1

cd ..

