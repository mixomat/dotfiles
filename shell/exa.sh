#!/usr/bin/env zsh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        VARIABLES          #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
export EXA_USER="marc.weinberger"
export EXA_PROJECTS="/Users/marc/projects/exaring"
export EXA_OPEN="open"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#        ALIASES            #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
alias awsume=". awsume"
alias kdev="awsume dev && kx arn:aws:eks:eu-central-1:873929438979:cluster/bs-k-dev-v1 && export TF_BUCKET=dev.terraform.exaring && export TF_KEY=aws-development"
alias kprev="awsume prev && kx arn:aws:eks:eu-central-1:157635668512:cluster/bs-k-preview-v1 && export TF_BUCKET=preview.terraform.exaring && export TF_KEY=aws-preview"
alias kprod="awsume prod && kx arn:aws:eks:eu-central-1:802129380100:cluster/bs-k-prod-v1 && export TF_BUCKET=prod.terraform.exaring && export TF_KEY=aws-production"
alias unsetAWS="awsume -u"
alias prodb="_exa_prod_db_tunnel"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#       FUNCTIONS           #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function _exa_prod_db_tunnel() {
  ssh -L15010:exaring-dev-recording-aurora-cluster.cluster-cqegwlhlos6b.eu-central-1.rds.amazonaws.com:5432 10.21.31.50
}
