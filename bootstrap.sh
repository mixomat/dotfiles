#!/bin/bash

# Bootstrap setup script for dotfiles.
#
# inspired by alrra's nice work:
#   https://github.com/alrra/dotfiles/blob/master/src/os/setup.sh

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
main() {

    ask_for_sudo

    ./setup/xcode.sh
    ./setup/brew.sh
    ./setup/shell.sh
    ./setup/symlinks.sh
    ./setup/vim.sh
}

main
