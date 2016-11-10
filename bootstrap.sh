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

    ./setup/symlinks.sh

    ./setup/node.sh
    ./setup/brew.sh
    ./setup/xcode.sh
    ./setup/vim.sh
}

main
