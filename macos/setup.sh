#!/bin/bash
#
# macos defaults script, mainly inspired by https://mths.be/macos
#

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

###
# Misc
###

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###
# Finder
###

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###
# Dock
###

# Disable animation in Dock 
defaults write com.apple.dock tilesize -int 36

# Minimize to application in Dock
defaults write com.apple.dock minimize-to-application -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock autohide-time-modifier -int 0.1

# Disable animations
defaults write com.apple.dock expose-animation-duration -float 0
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock mineffect -string "scale"

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# jpg screenshot files
defaults write com.apple.screencapture type jpg


###
# Restart Apps
###
for app in "Dock" \
	"Finder" \
	"iTerm" ; do
	killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
