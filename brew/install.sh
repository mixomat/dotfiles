#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../setup/utils.sh" \

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check for Homebrew and install it if missing
install_homebrew() {
    if test ! $(which brew)
    then
      echo "Installing Homebrew..."
      sudo -v
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
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
    execute \
        "brew bundle install" \
        "Homebrew (bundle install)"

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
