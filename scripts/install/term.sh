#!/bin/bash

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Install the iterm2 themes
open "${HOME}/dotfiles/term/themes/Solarized Dark.itermcolors"
open "${HOME}/dotfiles/term/themes/Molotov.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false