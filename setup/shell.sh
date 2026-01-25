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

setup_starship_prompt() {
  curl -sS https://starship.rs/install.sh | sh
  ln -s ~/dotfiles/shell/starship.toml ~/.config/
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

  ask_for_confirmation "Should I install starship.rs?"
  if answer_is_yes; then
    setup_starship_prompt
  else
    print_warning "Skipping starship.rs installation"
  fi
}

main
