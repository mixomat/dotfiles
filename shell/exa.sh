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
alias exaprod="awsume prod" 
alias kdev="kx arn:aws:eks:eu-central-1:873929438979:cluster/bs-k-dev-v1"
alias kprev="kx arn:aws:eks:eu-central-1:157635668512:cluster/bs-k-preview-v1"
alias kprod="kx arn:aws:eks:eu-central-1:802129380100:cluster/bs-k-prod-v1"
alias unsetAWS="awsume -u"
alias fixauthor="_exa_fix_author"
alias tag-deploy="_exa_tag_deploy"

# user-ng api
alias users-dev='_exa_users dev'
alias users-preview='_exa_users preview'
alias users-prod='_exa_users prod'
alias users-email-dev='_exa_users_email dev'
alias users-email-preview='_exa_users_email preview'
alias users-email-prod='_exa_users_email prod'

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

#auth api
alias auth-dev='_exa_auth_service dev'
alias auth-preview='_exa_auth_service preview'
alias auth-prod='_exa_auth_service prod'
alias auth-token-dev='_exa_auth_token dev'

# access-control
alias assets-dev="_exa_assets dev"
alias assets-preview="_exa_assets preview"
alias assets-prod="_exa_assets prod"

# booking
alias booking-dev='_exa_booking_service dev'
alias booking-preview='_exa_booking_service preview'
alias booking-prod='_exa_booking_service prod'

# billwerk api
alias bw-dev="_exa_bw dev"
alias bw-prod="_exa_bw prod"

# product-configuration api
alias product-config-dev="_exa_product_config dev"
alias product-config-preview="_exa_product_config preview"
alias product-config-prod="_exa_product_config prod"

# product-subscription api
alias product-subscription-dev="_exa_int_service dev product-subscription $PS_AUTH_DEV"
alias product-subscription-preview="_exa_int_service preview product-subscription $PS_AUTH_PREVIEW"
alias product-subscription-prod="_exa_int_service prord product-subscription $PS_AUTH_PROD"

# bwpgw
alias bwpgw-dev="_exa_int_service dev billwerk-partner-gateway $BWPGW_AUTH_DEV"
alias bwpgw-preview="_exa_int_service preview billwerk-partner-gateway $BWPGW_AUTH_PREVIEW"
alias bwpgw-prod="_exa_int_service prod billwerk-partner-gateway $BWPGW_AUTH_PROD"

# device-api
alias device-api-dev="_exa_device_api dev"
alias device-api-preview="_exa_device_api preview"
alias device-api-prod="_exa_device_api prod"

# audit
alias audit-dev="_exa_audit dev"
alias audit-preview="_exa_audit preview"
alias audit-prod="_exa_audit prod"

# sales-token
alias sales-tokens-dev="_exa_int_service dev sales-tokens $ST_AUTH"
alias sales-tokens-preview="_exa_int_service preview sales-tokens $ST_AUTH"
alias sales-tokens-prod="_exa_int_service prod sales-tokens $ST_AUTH"


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

function _exa_users_email() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env userHandle|email newEmail"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    local email="$3"
    https -a "$USERS_AUTH" PATCH users.int.${host}/api/users/$userHandle email=$email "Content-Type:application/vnd.waipu.users-email-without-password-v1+json"
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
    local method="${2:-GET}"
    shift 2
    https -v -a "$SM_AUTH" $method "subscription-management.int.${host}$@"
  fi
}

function _exa_booking_service() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env path"
  else
    local host=$(_exa_host "$1")
    local method="${2:-GET}"
    shift 2
    https -v $method "booking.${host}$@"
  fi
}

function _exa_auth_service() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env method path"
  else
    local host=$(_exa_host "$1")
    local method="${2:-GET}"
    shift 2
    https -v -a "$AUTH_AUTH" $method "auth.${host}$@"
  fi
}

function _exa_auth_service() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env user password"
  else
    local host=$(_exa_host "$1")
    local user=$2
    local password=$3
    https --form POST "auth.${host}/oauth/token" grant_type=password username=${user} password=${password} waipu_device_id="marc-local"
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
    local host=$(_bw_host $1)
    local credentials=$(_bw_credentials $1)
    export BILLWERK_TOKEN="$(https -a ${credentials} --form POST ${host}/oauth/token 'grant_type=client_credentials' | jq -r '.access_token')"
  else
  fi
}

function _exa_bw() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env method path"
  else
    local host=$(_bw_host $1)
    local method="${2:-GET}"
    _exa_bw_auth_token $1
    shift 2
    https -A bearer -a $BILLWERK_TOKEN $method "${host}${@}"
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


function _exa_active_device() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env user"
  else
    local host=$(_exa_host $1)
    local user=$2
    https -a $DM_AUTH device-management.int.$host/api/context/$user/active_devices
  fi
}

function _exa_device_api() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env token"
  else
    local host=$(_exa_host $1)
    local token=$2
    shift 2
    https -A bearer -a $token device-api.$host$@
  fi
}

function _exa_audit() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env method path"
  else
    local host=$(_exa_host $1)
    shift 2
    https -a $AUDIT_AUTH audit.int.$host$@
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

function _exa_int_service() {
  if [[ $# -lt 4 ]]; then
    echo "Usage: $0 env service-name auth method args..."
  else
    local host=$(_exa_host $1)
    local service=$2
    local auth=$3
    local method=$4
    shift 4
    https -a $auth $method $service.int.$host$@
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

function _bw_host() {
  case $1 in
    "dev")
      echo "exaring-dev.billwerk.com"
      ;;
    "preview")
      echo "exaring-dev.billwerk.com"
      ;;
    "prod")
      echo "exaring.billwerk.com"
      ;;
    *)
      echo "invalid environment: $1"
      return 1
      ;;
  esac
}

function _bw_credentials() {
  case $1 in
    "dev")
      echo $BILLWERK_AUTH
      ;;
    "prod")
      echo $BILLWERK_AUTH_PROD
      ;;
    *)
      echo "invalid environment: $1"
      return 1
      ;;
  esac
}
