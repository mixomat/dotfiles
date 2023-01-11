#!/usr/bin/env zsh


#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        VARIABLES          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
export EXA_USER="marc.weinberger"
export EXA_PROJECTS="${HOME}/projects/exaring"
export EXA_OPEN="open"
export PATH="${PATH}:${EXA_PROJECTS}/exaring-env/bin:${EXA_PROJECTS}/_scripts"

source $EXA_PROJECTS/.env
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
# user-ng api
alias users-dev='_exa_users dev'
alias users-preview='_exa_users preview'
# subscription-management api
alias sm-subscription-dev='_exa_sm_subscription dev'
alias sm-subscription-preview='_exa_sm_subscription preview'
alias sm-subscription-prod='_exa_sm_subscription prod'
# billwerk api
alias bw-customer-dev="_exa_bw_customer dev"
alias bw-customer-preview="_exa_bw_customer preview"
alias bw-customer-prod="_exa_bw_customer prod"
alias bw-contract-dev="_exa_bw_contract dev"
alias bw-contract-preview="_exa_bw_contract preview"
alias bw-contract-prod="_exa_bw_contract prod"


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

function _exa_users() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle|email"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    http -a "$USERS_AUTH" https://users.int.${host}/api/users/$userHandle 
  fi

}

function _exa_sm_subscription() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    http -a "$SM_AUTH" https://subscription-management.int.${host}/api/users/$userHandle/subscription Accept:'application/vnd.waipu.subscription-management-subscription-v1+json' --pretty=none -b | jq .
  fi
}

function _exa_bw_customer() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env customer"
  else
    local host=$(_exa_host $1)
    local customer=$2
    shift 2
    http -a $BW_AUTH https://billwerk-cache-service.$host/api/v1/Customers/$customer $@
  fi
}

function _exa_bw_contract() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env contract"
  else
    local host=$(_exa_host $1)
    local contract=$2
    shift 2
    http -a $BW_AUTH https://billwerk-cache-service.$host/api/v1/Contracts/$contract $@
  fi
}

function _exa_dazn_pac_stage() {
  http --verbose POST https://partners.ar.dazn-stage.com/v1/public/api/access-codes X-Dazn-Auth-Key:$DAZN_AUTH_STAGE campaignName='DAZN x Waiputvdemn2022'
}

function _exa_tag_deploy() {
  if [[ -z "$1" ]]; then
    echo "Usage: $0 tag-name"
  else 
    tag=$1
    git tag $tag && git push origin $tag
  fi
}

function _exa_host() {
  case $1 in
    "dev")
      echo "waipu-dev.net"
      ;;
    "preview")
      echo "waipu-preview.net"
      ;;
    "prod")
      echo "waipu.tv"
      ;;
    *)
      echo "invalid environment: $1"
      return 1
      ;;
  esac
}
