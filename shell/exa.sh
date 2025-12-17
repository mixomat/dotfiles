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
alias users-rm-dev='_exa_users_rm dev'

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
alias auth-token-preview='_exa_auth_token preview'
alias auth-token-prod='_exa_auth_token prod'

# booking
alias booking-dev='_exa_booking_service dev'
alias booking-preview='_exa_booking_service preview'
alias booking-prod='_exa_booking_service prod'

# billwerk api
alias bw-dev="_exa_bw dev"
alias bw-preview="_exa_bw preview"
alias bw-prod="_exa_bw prod"

# product-subscription api
alias product-subscription-dev="_exa_int_service dev product-subscription $PS_AUTH_DEV"
alias product-subscription-preview="_exa_int_service preview product-subscription $PS_AUTH_PREVIEW"
alias product-subscription-prod="_exa_int_service prod product-subscription $PS_AUTH_PROD"
alias ps-dev="_exa_ps dev $PS_AUTH_DEV"
alias ps-preview="_exa_ps preview $PS_AUTH_PREVIEW"
alias ps-prod="_exa_ps prod $PS_AUTH_PROD"

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

# activation
alias activation-dev="_exa_service dev activation $ACTIVATION_AUTH"
alias activation-preview="_exa_service preview activation $ACTIVATION_AUTH"
alias activation-prod="_exa_service prod activation $ACTIVATION_AUTH"

# order-management
alias order-management-dev="_exa_int_service dev order-management $OM_AUTH"
alias order-management-preview="_exa_int_service preview order-management $OM_AUTH"
alias order-management-prod="_exa_int_service prod order-management $OM_AUTH"

# netflix
alias netflix-dev="_exa_int_service dev netflix $NETFLIX_AUTH"
alias netflix-preview="_exa_int_service preview netflix $NETFLIX_AUTH"
alias netflix-prod="_exa_int_service prod netflix $NETFLIX_AUTH"

# disney
alias disney-dev="_exa_int_service dev disney-partner-gateway $DISNEY_AUTH_DEV"
alias disney-preview="_exa_int_service preview disney-partner-gateway $DISNEY_AUTH_PREVIEW"
alias disney-prod="_exa_int_service prod disney-partner-gateway $DISNEY_AUTH_PROD"

# wow
alias wow-dev="_exa_int_service dev wow-partner-gateway $WOW_AUTH_DEV"
alias wow-preview="_exa_int_service preview wow-partner-gateway $WOW_AUTH_PREVIEW"
alias wow-prod="_exa_int_service prod wow-partner-gateway $WOW_AUTH_PROD"


# device-management
alias device-management-dev="_exa_int_service dev device-management $DM_AUTH"
alias device-management-preview="_exa_int_service preview device-management $DM_AUTH"
alias device-management-prod="_exa_int_service prod device-management $DM_AUTH"

# event-query
alias event-query="_exa_event_query"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       FUNCTIONS           #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function jwt-decode() {
  jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' <<< $1
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

function _exa_users_rm() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env userHandle"
  else
    local host=$(_exa_host "$1")
    local userHandle="$2"
    https -a "$USERS_AUTH" DELETE users.int.${host}/api/users/$userHandle
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
    https -a "$SM_AUTH" $method "subscription-management.int.${host}$@"
  fi
}

function _exa_booking_service() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 env path"
  else
    local host=$(_exa_host "$1")
    local method="${2:-GET}"
    shift 2
    https $method "booking.${host}$@"
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

function _exa_auth_token() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env user password"
  else
    local host=$(_exa_host "$1")
    local user=$2
    local password=$3
    https --form POST "auth.${host}/oauth/token" grant_type=password username=${user} password=${password} waipu_device_id="marc-local"
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


function _exa_ps() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: $0 env auth user"
  else
    local host=$(_exa_host $1)
    local auth=$2
    local user=$3
    shift 3
    https -a $auth GET product-subscription.int.$host/api/subscriptions/$user
  fi
}

function _exa_event_query() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 userHandle"
  else
    https -a $EQ_AUTH event-query.waipu-dev.net/api/event-query userHandle==$1
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

function _exa_service() {
  if [[ $# -lt 4 ]]; then
    echo "Usage: $0 env service-name auth method args..."
  else
    local host=$(_exa_host $1)
    local service=$2
    local auth=$3
    local method=$4
    shift 4
    https -a $auth $method $service.$host$@
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
    "preview")
      echo $BILLWERK_AUTH_PREVIEW
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
