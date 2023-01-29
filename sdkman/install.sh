#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


setup_sdkman() {
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
  print_in_purple "\n • SDKMAN\n\n"
  ask_for_confirmation "Should I install SDKMAN?"
  if answer_is_yes; then
    setup_sdkman
  else
    print_warning "Skipping SDKMAN installation"
  fi
}
main
