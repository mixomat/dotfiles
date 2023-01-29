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

    ./setup/shell.sh
    ./setup/symlinks.sh
    ./setup/vim.sh
    ./setup/xcode.sh
    ./brew/install.sh
    ./sdkman/install.sh
}

main
