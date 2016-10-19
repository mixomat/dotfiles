#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
main() {

    ask_for_sudo

    ./create_symlinks.sh

    ./install/brew.sh
    ./install/xcode.sh
}

main