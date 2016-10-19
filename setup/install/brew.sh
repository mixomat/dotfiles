#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \

# Installs Homebrew and some of the common dependencies needed/desired for software development
	
# Check for Homebrew and install it if missing

install_homebrew() {
    if test ! $(which brew)
    then
      echo "Installing Homebrew..."
      sudo -v
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

brew_update() {
    execute \
        "brew update" \
        "Homebrew (update)"

}

brew_upgrade() {
    execute \
        "brew upgrade" \
        "Homebrew (upgrade)"
}

brew_bundle_install() {
    brew tap Homebrew/bundle

    execute \
        "brew bundle install" \
        "Homebrew (upgrade)"

}

brew_cleanup() {
    execute \
        "brew cleanup" \
        "Homebrew (cleanup)"
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n • Homebrew\n\n"

    ask_for_confirmation "Should I install and update Homebrew?"
    if answer_is_yes; then
        install_homebrew

        brew_update
        brew_upgrade

        brew_bundle_install
        brew_cleanup
    else
        print_warning "Skipping Homebrew installation"
    fi

}

main