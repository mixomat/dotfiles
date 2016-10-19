#!/bin/bash

# Install the iterm2 themes
open "${HOME}/dotfiles/term/themes/Solarized Dark.itermcolors"
open "${HOME}/dotfiles/term/themes/Molotov.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false