#!/bin/bash

# Bootstrap setup script for dotfiles.
#
# inspired by alrra's nice work:
#   https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
main() {

    ask_for_sudo

    ./create_symlinks.sh

    ./install/node.sh
    ./install/brew.sh
    ./install/xcode.sh
    ./install/vim.sh
}

main
