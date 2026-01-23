# misc
alias cd..="cd .."
alias :q="exit"
alias c='clear'
alias t='tar xfv'
alias tj='tar xfjv'
alias tz='tar xfzv'
alias s='screen -r'
alias l='less'
alias screen='screen -l'
alias df='df -h'
alias su='su --login'
alias psg='ps -ef | grep'
alias fwlog='tail -f /var/log/ipfw.log'
alias v='vim'
alias pwgen="openssl rand -base64 128 | tr -dc 'A-Za-z0-9' | head -c 64"
alias C='see'
alias gl='glances'
alias reboot='sudo /sbin/reboot'
alias nmap='sudo nmap -sS -P0'
alias ipfw='sudo ipfw'
alias top='top -R -F -s 2 -o cpu'
alias digall='dig +nocmd +multiline +noall +answer'
alias sshx='ssh -p 4365'
alias week='date +%V'
alias path='echo -e ${PATH//:/\\n}'
alias decode64='base64 -D'
alias wolman='wakeonlan 3c:7c:3f:7d:a7:d3'
alias timestamp='date -r'
alias date='gdate'

# git
alias g='git'
alias gco='git branch | fzf | xargs git checkout'
alias push='git push'
alias pull='git pull -r'

#glab
alias glab-mr='glab mr create -f -y --push --squash-before-merge --remove-source-branch -l bs-cap && glab mr view --web'
alias glab-mr-draft='glab mr create -f -y --draft --push --squash-before-merge --remove-source-branch -l bs-cap && glab mr view --web'

# docker
alias d='docker'
alias dcom='docker compose'

# k8s
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kubeseal='kubeseal --controller-namespace gitops --scope cluster-wide'
alias kubesealraw='kubeseal --raw --from-file=/dev/stdin --controller-namespace gitops --scope cluster-wide'
alias fluxctl='fluxctl --k8s-fwd-ns gitops'
alias h='helm'

# aws
alias aws-local='aws --endpoint-url=http://localhost:4566'
