#!/bin/bash
#
# macos defaults script, mainly inspired by https://mths.be/macos
#

# Ask for the administrator password upfront
sudo -v

# Set standby delay to 2 hours (default is 1 hour)
sudo pmset -a standbydelay 7200

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Menu bar: hide the Time Machine, Volume, and User icons
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    defaults write "${domain}" dontAutoLoad -array \
          "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
              "/System/Library/CoreServices/Menu Extras/Volume.menu" \
                  "/System/Library/CoreServices/Menu Extras/User.menu"
done

# disable timemachine local backups
sudo tmutil disablelocal

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Disable animation on showing and hiding Mission Control
defaults write com.apple.dock expose-animation-duration -float 0

# Disable animation on showing and hiding Launchpad
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0

# Disable animation on changing pages in Launchpad
defaults write com.apple.dock springboard-page-duration -float 0

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
