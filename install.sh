#!/bin/bash
# Usage install.sh [instanceName] [password] [namespace]

die () {
    echo >&3 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "Usage install.sh [instanceName] [password] [Namespace]"

DIR=$(dirname $0)
if [ "$DIR" = "." ]; then
DIR=$(pwd)
fi

instanceName=$1
password=$2
NameSpace=$3

# Installer source (Installer.*.cls)
ClassImportDir=$DIR/misc
# Source dir install by source installer
DirSrc=$DIR/src



irissession $instanceName -U USER <<EOF 
zn "USER"
do \$system.OBJ.ImportDir("$ClassImportDir","Installer.cls","cubk",.errors,1)
write "Compilation de l'installer done"
Set pVars("NAMESPACE")="MYCLIENT"
Do ##class(OAuth2.Installer).setup(.pVars)
Do ##class(OAuth2.Installer).CreateSSLConfig()
Do ##class(OAuth2.Installer).CreateOauth2Server()
Do ##class(OAuth2.Installer).CreateServerDefinitionForClient()
Do ##class(OAuth2.Installer).CreateClient()
write "creation du namespace done"

zn "$NameSpace"
Set source="$DirSrc"
set sc = \$system.OBJ.ImportDir(source,"*.cls;*.inc;*.mac","cubk",.errors,1)
zw errors
do:(sc'=1) \$system.Process.Terminate(,1),h
write "Compilation des sources done"

zn "%SYS"
do \$system.OBJ.ImportDir(source,"ZAUTHENTICATE.mac","cubk",.errors,1)
w ##class(Security.Applications).Import("$ClassImportDir"_"/Applications.xml")
w "Import of previously exported configurations via terminal done"

halt
EOF
