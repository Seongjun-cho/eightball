##!/bin/bash
## Integrate Fortify ScanCentral Static AppSec Testing (SAST) into your AWS Codestar pipeline
#
## *** Configuration ***
## The following variables must be defined in buildspect.yml
export FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN=$FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN
export FCLI_DEFAULT_SSC_USER=$FCLI_DEFAULT_SSC_USER
export FCLI_DEFAULT_SSC_PASSWORD=$FCLI_DEFAULT_SSC_PASSWORD
export FCLI_DEFAULT_SSC_CI_TOKEN=$FCLI_DEFAULT_SSC_CI_TOKEN
export FCLI_DEFAULT_SSC_URL=$FCLI_DEFAULT_SSC_URL
ssc_app_version_id=$SSC_APP_VERSION_ID
#
## Local variables (modify as needed)
FCLI_VERSION=v2.12.0
SCANCENTRAL_VERSION=24.4.0
#FCLI_HOME=/tmp/fcli
#
## *** Execution ***
## Install FCLI
#
#export PATH=$FCLI_HOME/bin:${PATH}
#
#
#echo Setting connection with Fortify Platform
##Use --insecure switch if the SSL certificate is self generated.

/tmp/fcli ssc session login
/tmp/fcli sc-sast session login
#
/tmp/scancentral/bin/scancentral package -bt none -o package.zip
#
echo zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
ls -al
pwd
/tmp/fcli sc-sast scan start --publish-to=$SSC_APP_VERSION_ID --sensor-version=$SCANCENTRAL_VERSION --package-file=package.zip
#
#/tmp/fcli sc-sast scan wait-for ::Id:: --interval=30s
#fcli ssc issue count --appversion=$SSC_APP_VERSION_ID
#
#echo Terminating connection with Fortify Platform
/tmp/fcli sc-sast session logout
/tmp/fcli ssc session logout  
## *** Execution Completes ***
#
## *** EoF ***
cat /root/.fortify/scancentral-24.4.0/log/scancentral.log
echo seongjuncho