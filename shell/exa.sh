#!/usr/bin/env zsh


#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        VARIABLES          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
export EXA_USER="marc.weinberger"
export EXA_PROJECTS="/Users/marc/projects/exaring"
export EXA_OPEN="open"
export PATH="${PATH}:${EXA_PROJECTS}/exaring-env/bin:${EXA_PROJECTS}/_scripts"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        ALIASES            #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
alias exap="_exap"
alias exacommit="git config user.email 'marc.weinberger@extern.exaring.de'"
alias awsume=". awsume"
alias exadev="awsume dev && export TF_BUCKET=dev.terraform.exaring && export TF_KEY=aws-development"
alias exaprev="awsume prev && export TF_BUCKET=preview.terraform.exaring && export TF_KEY=aws-preview"
alias exaprod="awsume prod && export TF_BUCKET=prod.terraform.exaring && export TF_KEY=aws-production"
alias kdev="exadev && kx arn:aws:eks:eu-central-1:873929438979:cluster/bs-k-dev-v1"
alias kprev="exaprev && kx arn:aws:eks:eu-central-1:157635668512:cluster/bs-k-preview-v1"
alias kprod="exaprod && kx arn:aws:eks:eu-central-1:802129380100:cluster/bs-k-prod-v1"
alias unsetAWS="awsume -u"
alias prodb="_exa_prod_db_tunnel"
alias fixauthor="_exa_fix_author"
alias sm-subscription="_exa_sm_subscription"
alias bw-customer="_exa_bw_customer"
alias bw-contract="_exa_bw_contract"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       FUNCTIONS           #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function _exa_jumphost() {
  local ec2_ip="$( \
      aws ec2 describe-instances \
          | jq -r '.Reservations[].Instances[]
              | select(.Tags[]
                | select(.Key == "Name")
                | select(.Value | startswith("'$1'")))
              | select(.State.Name == "running")
              | "\(.Tags[] | select(.Key == "Name") | .Value): \(.PrivateIpAddress)"' \
          | sort \
          | bat -p --color=always -l yaml \
          | fzf \
              --ansi \
              --min-height 20 \
              --height ${FZF_TMUX_HEIGHT:-40%} \
          | head -n 1 \
          | awk -F'[: ]+' '{ print $2 }' \
  )"

  [[ -z "${ec2_ip}" ]] && return -2
  if [[ "${2}" = "-" ]]; then
      echo "${ec2_ip}"
  else
      [[ -n "${1}" ]] && shift
      echo "ssh to ${ec2_ip} ${@}"
      ssh "${ec2_ip}" "${@}"
  fi
}

function _exa_prod_db_tunnel() {
  ssh -L15010:exaring-dev-recording-aurora-cluster.cluster-cqegwlhlos6b.eu-central-1.rds.amazonaws.com:5432 10.21.31.50
}

function _exa_dev_billwerk_redis() {
  _exa_jumphost logstash -L16010:billwerk-cache-service-cache.csp7th.0001.euc1.cache.amazonaws.com:6380
}

function _exa_fix_author() {
  git config user.email "marc.weinberger@extern.exaring.de"
}

function _exa_sm_subscription() {
  if [[ -z "$1" ]]; then
    echo "Usage: $0 userHandle"
  else
    http -v -a 'Auth:f9hf843FAWE$f!fs' https://subscription-management.int.waipu-dev.net/api/users/$1/subscription Accept:'application/vnd.waipu.subscription-management-subscription-v1+json' --pretty=none --print=b | jq .
  fi
}

function _exa_bw_customer() {
  if [[ -z "$1" ]]; then
    echo "Usage: $0 customerId"
  else
    http -a "BackendEndToEndTests:VnaH6GavsLA98MABbag13Ddaa67BgXa09KnaT" https://billwerk-cache-service.waipu-dev.net/api/v1/Customers/$1
  fi
}

function _exa_bw_contract() {
  if [[ -z "$1" ]]; then
    echo "Usage: $0 contractId"
  else
    http -a "BackendEndToEndTests:VnaH6GavsLA98MABbag13Ddaa67BgXa09KnaT" https://billwerk-cache-service.waipu-dev.net/api/v1/Contracts/$1
  fi
}

source $EXA_PROJECTS/.env
