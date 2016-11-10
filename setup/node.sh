#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_global_node_modules() {
  execute \
        "npm install -g commitizen cz-conventional-changelog" \
        "Installing global node modules"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
        print_in_purple "\n • Node\n\n"

        install_global_node_modules
}

main
