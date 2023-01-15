#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

setup_oh-my-zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

setup_powerlevel_theme() {
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
  print_in_purple "\n • ZSH\n\n"

  ask_for_confirmation "Should I install and oh-my-zsh?"
  if answer_is_yes; then
    setup_oh-my-zsh
  else
    print_warning "Skipping oh-my-zsh installation"
  fi

  ask_for_confirmation "Should I install powerlevel10k?"
  if answer_is_yes; then
    setup_powerlevel_theme
  else
    print_warning "Skipping powerlevel10k installation"
  fi
}

main
