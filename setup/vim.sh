#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_vim_plug() {
  execute \
        "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" \
        "Installing vim-plug"
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
        print_in_purple "\n • VIM\n\n"

        ask_for_confirmation "Should I install vim-plug"
        if answer_is_yes; then
            install_vim_plug
            else
        print_warning "Skipping vim-plug installation"
        fi
}

main
