#!/usr/bin/env zsh

fpath=( $DOTFILES/shell/fun "${fpath[@]}" )
autoload -Uz $fpath[1]/*(.:t)


function git-root {
  root=$(git rev-parse --git-dir 2>/dev/null)
  [[ -z "$root" ]] && root="."
  dirname $root
}

function decode_secret() {
  local secret=$1 secret_entry=$2

  if [ $# -eq 2 ]; then
    echo "decoding secret $secret_entry in $secret\n"
    local encoded=$(kubectl get secret $secret -ojsonpath="{.data.$secret_entry}")
    echo -n "$encoded" | base64 --decode
  elif [ $# -eq 1 ]; then
    echo "retrieving secret $secret\n"
    kubectl get secret $secret -o yaml
  else
    echo "usage: decode_secret <secret> <secret_entry>"
  fi
}

function b64dec() {
  if [ $# -eq 1 ]; then
    echo -n "$1" | base64 -D
  else
    echo "usage: base64dec <encoded>"
  fi
}

function b64enc() {
  if [ $# -eq 1 ]; then
    echo -n "$1" | base64
  else
    echo "usage: b64enc <decoded>"
  fi
}
