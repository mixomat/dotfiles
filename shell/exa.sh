#!/usr/bin/env zsh

[ -r $DOTFILES/shell/exa_env ] && . $DOTFILES/shell/exa_env

#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        VARIABLES          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
export EXA_USER="marc.weinberger"
export EXA_PROJECTS="${HOME}/projects/exaring"
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
alias fixauthor="_exa_fix_author"
alias tag-deploy="_exa_tag_deploy"

# db tunnel
alias db-users-dev="_exa_tunnel dev 5555:exaring-dev-users-encrypted-db.cqegwlhlos6b.eu-central-1.rds.amazonaws.com:5432 promstack"
alias db-users-prod="_exa_tunnel prod 6666:exaring-prod-users-encrypted-db.ccgynvk3looc.eu-central-1.rds.amazonaws.com:5432 promstack"

# user-ng api
alias users-dev='_exa_users dev'
alias users-preview='_exa_users preview'
alias users-prod='_exa_users prod'
# subscription-management api
alias sm-dev='_exa_sm_service dev'
alias sm-preview='_exa_sm_service preview'
alias sm-prod='_exa_sm_service prod'
alias sm-subscription-dev='_exa_sm_subscription dev'
alias sm-subscription-preview='_exa_sm_subscription preview'
alias sm-subscription-prod='_exa_sm_subscription prod'
alias sm-subscription-refresh-dev='_exa_sm_refresh dev'
alias sm-subscription-refresh-preview='_exa_sm_refresh preview'
alias sm-subscription-refresh-prod='_exa_sm_refresh prod'

# billwerk api
alias bw-dev="_exa_bw dev"
# billwerk cache service api
alias bwc-customer-dev="_exa_bwc_customer dev"
alias bwc-customer-preview="_exa_bwc_customer preview"
alias bwc-customer-prod="_exa_bwc_customer prod"
alias bwc-contract-dev="_exa_bwc_contract dev"
alias bwc-contract-preview="_exa_bwc_contract preview"
alias bwc-contract-prod="_exa_bwc_contract prod"
alias bwc-contract-refresh-dev="_exa_bwc_contract_refresh dev"
alias bwc-contract-refresh-preview="_exa_bwc_contract_refresh preview"
alias bwc-contract-refresh-prod="_exa_bwc_contract_refresh prod"
# product-configuration api
alias product-config-dev="_exa_product_config dev"
alias product-config-preview="_exa_product_config preview"
alias product-config-prod="_exa_product_config prod"
# access-control
alias assets-dev="_exa_assets dev"
alias assets-preview="_exa_assets preview"
alias assets-prod="_exa_assets prod"



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

function jwt-decode() {
  jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' <<< $1
}

function _exa_dev_billwerk_redis() {
  _exa_jumphost logstash -L16010:billwerk-cache-service-cache.csp7th.0001.euc1.cache.amazonaws.com:6380
}

function _exa_tunnel() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env tunnel (jumphost)"
  else
    local env=$1
    local tunnel=$2
    local jumphost="${3:-logstash}"

    awsume $env
    _exa_jumphost $jumphost -i $EXA_PROJECTS/exaring-secrets/ssh-keys/ec2-deploy -L $tunnel
  fi
}

function _exa_fix_author() {
  git config user.email "marc.weinberger@extern.exaring.de"
}

function _exa_auth_token() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env username password"
  else
    local host=$(_exa_host "$1")
    local username="$2"
    local password="$3"
    https --follow POST "auth.${host}/oauth/token?grant_type=password&username=${username}&password=${password}"
  fi
}

function _exa_users() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle|email"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    https -a "$USERS_AUTH" users.int.${host}/api/users/$userHandle 
  fi

}

function _exa_sm_subscription() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    https -a "$SM_AUTH" subscription-management.int.${host}/api/users/$userHandle/subscription --pretty=none -b | jq .
  fi
}

function _exa_sm_refresh() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    https -a "$SM_AUTH" DELETE "subscription-management.int.${host}/api/users/$userHandle/cache?propagateCacheInvalidation=true"
  fi
}

function _exa_sm_service() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env path"
  else
    local host=$(_exa_host "$1")
    shift 1
    https -v -a "$SM_AUTH" subscription-management.int.${host}$@ Accept:" */*"
  fi
}

function _exa_bwc_customer() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env customer"
  else
    local host=$(_exa_host $1)
    local customer=$2
    shift 2
    https -a $BWC_AUTH billwerk-cache-service.$host/api/v1/Customers/$customer $@
  fi
}

function _exa_bwc_contract() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env contract"
  else
    local host=$(_exa_host $1)
    local contract=$2
    shift 2
    https -a $BWC_AUTH billwerk-cache-service.$host/api/v1/Contracts/$contract$@
  fi
}

function _exa_bwc_contract_refresh() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env contract"
  else
    local host=$(_exa_host $1)
    local contract=$2
    shift 2
    https -v -a $BWC_AUTH POST "billwerk-cache-service.$host/api/v1/Contracts/$contract/refresh?ensureBillwerkRefresh=true"
  fi
}

function _exa_bw_auth_token() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 env"
  elif [[ -z ${BILLWERK_TOKEN} ]]; then
    export BILLWERK_TOKEN="$(https -a ${BILLWERK_AUTH} --form POST 'exaring-dev.billwerk.com/oauth/token' 'grant_type=client_credentials' | jq -r '.access_token')"
  else
    echo "Using existing billwerk token"
  fi
}

function _exa_bw() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 env method"
  else
    local host=$(_exa_host $1)
    local method="${2:-GET}"
    shift 2
    _exa_bw_auth_token $host
    https -A bearer -a $BILLWERK_TOKEN $method exaring-dev.billwerk.com$@
  fi
}


function _exa_product_config() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 env (salesBundle)"
  else
    local host=$(_exa_host $1)
    shift 1
    https -a $PC_AUTH product-configuration.int.$host/api/sales-bundles/$@
  fi
}

function _exa_assets() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env user"
  else
    local host=$(_exa_host $1)
    local user=$2
    shift 2
    https -a $ACCESS_AUTH "access-control.$host/api/users/$user/assets"
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
