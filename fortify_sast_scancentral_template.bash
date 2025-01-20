#!/bin/bash
# Integrate Fortify ScanCentral Static AppSec Testing (SAST) into your AWS Codestar pipeline

# *** Configuration ***
# The following variables must be defined in buildspect.yml
export FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN=$FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN
export FCLI_DEFAULT_SSC_USER=$FCLI_DEFAULT_SSC_USER
export FCLI_DEFAULT_SSC_PASSWORD=$FCLI_DEFAULT_SSC_PASSWORD
export FCLI_DEFAULT_SSC_CI_TOKEN=$FCLI_DEFAULT_SSC_CI_TOKEN
export FCLI_DEFAULT_SSC_URL=$FCLI_DEFAULT_SSC_URL
ssc_app_version_id=$SSC_APP_VERSION_ID

# Local variables (modify as needed)
# FCLI_VERSION=v2.12.0
SCANCENTRAL_VERSION=24.4.0
FCLI_URL=http://13.209.176.153:8080/ssc/downloads/fcli-linux.tgz
SCANCENTRAL_URL=http://13.209.176.153:8080/ssc/downloads/Fortify_ScanCentral_Client_24.4.0_x64.zip
FORTIFY_TOOLS_DIR="/opt/fortify/tools"	
FCLI_HOME=$FORTIFY_TOOLS_DIR/fcli
SCANCENTRAL_HOME=$FORTIFY_TOOLS_DIR/ScanCentral	

installFcli() {
  local src tgt tmpRoot tmpFile tmpDir
  src="$1"; tgt="$2"; 
  tmpRoot=$(mktemp -d); tmpFile="$tmpRoot/archive.tmp"; tmpDir="$tmpRoot/extracted"
  echo "Downloading file"
  wget -O $tmpFile $src
  echo "Unzipping: tar -zxf " + $tmpFile + " -C " + $tmpDir
  mkdir $tmpDir
  mkdir -p $tgt
  
  tar -zxf $tmpFile -C $tmpDir
  mv $tmpDir/* $tgt
  rm -rf $tmpRoot
  find $tgt -type f
}

installscancentral() {
  local src tgt tmpRoot tmpFile tmpDir
  src="$1"; tgt="$2"; 
  tmpRoot=$(mktemp -d); tmpFile="$tmpRoot/archive.tmp"; tmpDir="$tmpRoot/extracted"
  echo "Downloading file"
  wget -O $tmpFile $src
  echo "Unzipping: tar -zxf " + $tmpFile + " - d " + $tmpDir
  mkdir $tmpDir
  mkdir -p $tgt
  
  unzip $tmpFile -C $tmpDir
  mv $tmpDir/* $tgt
  chmod +x /$tgt/*
  rm -rf $tmpRoot
  find $tgt -type f
}

# *** Execution ***
# Install FCLI
installFcli ${FCLI_URL} ${FCLI_HOME}/bin
installscancentral ${SCANCENTRAL_URL} ${SCANCENTRAL_HOME}

export PATH=$FCLI_HOME/bin:$SCANCENTRAL_HOME/bin:${PATH}

# fcli tool definitions update
# fcli tool sc-client install -v ${SCANCENTRAL_VERSION} -d ${SCANCENTRAL_HOME}

echo Setting connection with Fortify Platform
#Use --insecure switch if the SSL certificate is self generated.
fcli ssc session login
fcli sc-sast session login

scancentral package -bt none -o package.zip

fcli sc-sast scan start --publish-to=$SSC_APP_VERSION_ID --sensor-version=$SCANCENTRAL_VERSION --package-file=package.zip --store=Id

fcli sc-sast scan wait-for ::Id:: --interval=30s
fcli ssc issue count --appversion=$SSC_APP_VERSION_ID

echo Terminating connection with Fortify Platform
fcli sc-sast session logout
fcli ssc session logout  
# *** Execution Completes ***

# *** EoF ***
