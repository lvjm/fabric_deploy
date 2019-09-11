#!/bin/bash 
set -x

##################################################################################################################################################

#Script Description: 

##################################################################################################################################################

#global settings for minimum configuration
CPU_MIN=1
MEMORY_MIN=8
DISK_SIZE_MIN=1952550
OPEN_FILES_MIN=65000

echo "============================================================================================================================================"
echo "Step1: Environment Check"
echo "============================================================================================================================================"
./script-fragments/env-check.sh \
 ${CPU_MIN} \
 ${MEMORY_MIN} \
 ${DISK_SIZE_MIN} \
 ${OPEN_FILES_MIN}


echo "============================================================================================================================================"
echo "Step2: Setting Necessary  Params For Installation Location"
echo "============================================================================================================================================"

#global settings for target env
echo "setting current environment to dev will openup swagger UI"
#target environment name can be "dev|qa|pprod|prod"
APPLICATION_TARGET_ENV=dev

#global file name definition
HOST_FILE=/etc/hosts
PROFILE=/etc/profile

#global definition of common tools
CURL_INSTALLER_NAME=curl-7.55.1.tar.gz
CURL_FOLDER_NAME=curl-7.55.1
DOCKER_INSTALLER_NAME=docker-ce_18.09.0_3-0_ubuntu-xenial_amd64.deb
LIBLTDL7_INSTALLER_NAME=libltdl7_2.4.6-0.1_amd64.deb
CONTANINERD_INSTALLER_NAME=containerd.io_1.2.0-1_amd64.deb
DOCKER_CE_CLI_INSTALLER_NAME=docker-ce-cli_18.09.0_3-0_ubuntu-xenial_amd64.deb
#DOCKER_INSTALLER_NAME=docker-18.06.1-ce.tgz
DOCKER_FOLDER_NAME=docker
JDK_INSTALLER_NAME=jdk-8u201-linux-x64.tar.gz
JDK_FOLDER_NAME=jdk1.8.0_201
NODE_INSTALLER_NAME=node-v10.15.3-linux-x64.tar.xz
NODE_FOLDER_NAME=node-v10.15.3-linux-x64

#global application name settings
TFS_APPLICATION_PREFIX=tfs
TFS_API_APPLICATION_SHORT_NAME=api
TFS_ADMIN_APPLICATION_SHORT_NAME=admin
TFS_EXPLORER_APPLICATION_SHORTNAME=explorer
TFS_API_APPLICATION_FULL_NAME=tfs-api
TFS_ADMIN_APPLICATION_FULL_NAME=tfs-admin
TFS_EXPLORER_APPLICATION_FULL_NAME=tfs-explorer


#golobal application configuration file settings
TFS_API_CONFIGFILE_NAME=tfs-api-config.properties
TFS_ADMIN_CONFIGFILE_NAME=tfs-admin-config.properties

#global setting of the fabric docker images
FABRIC_DOCKER_IMAGE_VERSION=1.3.0
FABRIC_DOCKER_IMAGE_OS_NAME=amd64
FABRIC_DOCKER_IMAGE_3P_VERSION=0.4.13

#global constants definition
SWIFT_STORAGE_SERVICE_PROXY_BIND_PORT=18080
SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT=35357
SWIFT_IDENTITY_SERVICE_USER_BIND_PORT=5000
MYSQL_BIND_ACCESS_PORT=3306

#global ports definition for applications
TFS_API_SERVICE_PORT=20080
TFS_ADMIN_SERVICE_PORT=20180
TFS_EXPLORER_SERVICE_PORT=20280

#global setting of the mail service
MAIL_HOST=smtp.mxhichina.com
MAIL_USERNAME=admin@at2plus.com
MAIL_PASSWORD=N0password
MAIL_SENDER=admin@at2plus.com
MAIL_RECEIVER=admin@at2plus.com

#global setting of the openstack swift(NOT PRODUCTION ENV)
OPENSTACK_SWIFT_USERNAME=demo
OPENSTACK_SWIFT_PASSWORD=demo
OPENSTACK_SWIFT_PROJECTNAME=test
OPENSTACK_SWIFT_PROJECTDOMAIN=default
OPENSTACK_SWIFT_CONTAINERNAME=test

#global build setting definiton of the project
BUILD_DATE=`date '+%Y-%m-%d'`
BUILD_VERSION=3.2.1

#the internal ip address 
internalIp=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

#the external ip address 
externalIp=`curl ifconfig.me`

# the root folder of this installation package
installationPkgRoot=$(dirname "$PWD")

# the root folder of the logs
installationPkgLogRoot=${installationPkgRoot}/logs

# the root folder of the shell sub-directory inside the installation package
installationPkgShellRoot=${installationPkgRoot}/scripts

# the root folder of the applications
installationPkgApplicationRoot=${installationPkgRoot}/applications

# the root folder of the application artifacts
installationPkgApplicationArtifactsRoot=${installationPkgRoot}/application-artifacts

# the root folder of the installer sub-directory inside the installation package
installationPkgInstallerRoot=${installationPkgRoot}/tools-installer

# the root folder of the fabric artifacts 
installationPkgFabricArtifactsRoot=${installationPkgRoot}/fabric-artifacts

# the root folder of the fabric tools
installationPkgFabricToolsRoot=${installationPkgRoot}/fabric-tools

# the root folder of the disk mount volume entry point for the docker images
installationPkgMountVolumeRoot=${installationPkgRoot}/mount-volume

#the root folder of storage
installationPkgStorageRoot=${installationPkgRoot}/storage

#the root folder of swift storage
installationPkgSwiftStorageRoot=${installationPkgStorageRoot}/swift

#the root folder of mysql storage
installationPkgMySqlStorageRoot=${installationPkgStorageRoot}/mysql

#the root folder of mysql scripts
installationPkgMySqlDbShellRoot=${installationPkgRoot}/sql-scripts

#the root folder of mysql generated scripts by replacing the placeholders
installationPkgMySqlDbShellArtifactRoot=${installationPkgRoot}/sql-script-artifacts

# the root folder of the chaincode
installationPkgChaincodeRoot=${installationPkgRoot}/chaincode-deploy

#the chaincode name
installationPkgChaincodeName=courttrust

#the chaincode path
installationPkgChaincodePath=bitbucket.org/at2chain/chaincode-${installationPkgChaincodeName}

#the chaincode version
installationPkgChaincodeVersion=1.0.0



#installation target path for fundamental tools
read -p 'please input curl installation root location, default ${INSTALLATION_ROOT}/curl'  curlRoot
curlRoot=${curlRoot:-${installationPkgRoot}/tools/curl}

read -p 'please input docker installation root location, default ${INSTALLATION_ROOT}/docker'  dockerRoot
dockerRoot=${dockerRoot:-${installationPkgRoot}/tools/docker}

read -p 'please input docker-compose installation root location, default ${INSTALLATION_ROOT}/docker-compose'  dockerComposeRoot
dockerComposeRoot=${dockerComposeRoot:-${installationPkgRoot}/tools/docker-compose}

read -p 'please input jdk installation root location, default ${INSTALLATION_ROOT}/jdk'  jdkRoot
jdkRoot=${openJdkRoot:-${installationPkgRoot}/tools/jdk}

read -p 'please input node installation root location, default ${INSTALLATION_ROOT}/node'  nodeRoot
nodeRoot=${nodeRoot:-${installationPkgRoot}/tools/node}

read -p 'please input npm  installation root location, default ${INSTALLATION_ROOT}/npm'  npmRoot
npmRoot=${npmRoot:-${installationPkgRoot}/tools/npm}


echo "============================================================================================================================================"
echo "Step3: Verify Installation Location Settings"
echo "============================================================================================================================================"
echo "internalIp: ${internalIp}"
echo "installationPkgRoot: ${installationPkgRoot}"
echo "installationPkgLogRoot: ${installationPkgLogRoot}"
echo "installationPkgShellRoot: ${installationPkgShellRoot}"
echo "installationPkgApplicationRoot: ${installationPkgApplicationRoot}"
echo "installationPkgApplicationArtifactsRoot: ${installationPkgApplicationArtifactsRoot}"
echo "installationPkgInstallerRoot: ${installationPkgInstallerRoot}"
echo "installationPkgFabricArtifactsRoot: ${installationPkgFabricArtifactsRoot}"
echo "installationPkgFabricToolsRoot: ${installationPkgFabricToolsRoot}"
echo "installationPkgMountVolumeRoot: ${installationPkgMountVolumeRoot}"
echo "installationPkgStorageRoot: ${installationPkgStorageRoot}"
echo "installationPkgSwiftStorageRoot: ${installationPkgSwiftStorageRoot}"
echo "installationPkgMySqlStorageRoot: ${installationPkgMySqlStorageRoot}"
echo "installationPkgMySqlDbShellRoot: ${installationPkgMySqlDbShellRoot}"
echo "installationPkgMySqlDbShellArtifactRoot: ${installationPkgMySqlDbShellArtifactRoot}"
echo "installationPkgChaincodeRoot: ${installationPkgChaincodeRoot}"
echo "installationPkgChaincodeName: ${installationPkgChaincodeName}"
echo "installationPkgChaincodePath: ${installationPkgChaincodePath}"
echo "installationPkgChaincodeVersion: ${installationPkgChaincodeVersion}"
echo "curlRoot: ${curlRoot}"
echo "dockerRoot: ${dockerRoot}"
echo "dockerComposeRoot: ${dockerComposeRoot}"
echo "jdkRoot: ${jdkRoot}"
echo "nodeRoot: ${nodeRoot}"
echo "npmRoot: ${npmRoot}"

echo "============================================================================================================================================"
echo "Step4: Setting Necessary  Params For Fabric"
echo "============================================================================================================================================"
read -p "please input organization count,default:2  " orgCount
orgCount=${orgCount:-2}

read -p "please input peer count in a organization default:2  " peerCountInOrg
peerCountInOrg=${peerCountInOrg:-2}

read -p "please input zookeeper count,default:3  " zkCount
zkCount=${zkCount:-3}

read -p "please input kafka count,default:4  " kafkaCount
kafkaCount=${kafkaCount:-4}

read -p "please input default normal user count in each organization,default:1  " defaultNormalUserCountInOrg
defaultNormalUserCountInOrg=${defaultNormalUserCountInOrg:-1}

read -p "please input the organization name that orderer belongs to,default:Orderer  " ordererOrgName
ordererOrgName=${ordererOrgName:-"Orderer"}

read -p "please input the host name of the orderer,default:orderer  " ordererHostName
ordererHostName=${ordererHostName:-"orderer"}

read -p "please input fabric domain name,default:at2chain.com  " domainName
domainName=${domainName:-"at2chain.com"}

read -p "please input the profile prefix name,default:At2chain  " profilePrefixName
profilePrefixName=${profilePrefixName:-"At2chain"}

read -p "please input the consortium name,default:At2chainConsortium  " consortiumName
consortiumName=${consortiumName:-"At2chainConsortium"}

read -p "please input fabric network name,default:at2chainnetwork " fabricNetworkName
fabricNetworkName=${fabricNetworkName:-"at2chainnetwork"}

read -p "please input ca registrar username in Organization, default:admin  " registrarUserName
registrarUserName=${registrarUserName:-"admin"}

read -p "please input ca registrar password in Organization, default:adminpw  " registrarUserPassword
registrarUserPassword=${registrarUserPassword:-"adminpw"}

read -p "please input username of couchdb,default:couchdbUserName  " couchdbUserName
couchdbUserName=${couchdbUserName:-"couchdbUserName"}

read -p "please input password of couchdb,default:couchdbUserPassword  " couchdbUserPassword
couchdbUserPassword=${couchdbUserPassword:-"couchdbUserPassword"}

read -p "please input business channel name,default:at2chainchannel  " channelName
channelName=${channelName:-"at2chainchannel"}


#generate the endorsement policy
Orgs=[]
read -p "please input endorsement policy pattern(ALL,ANY,MAJORITY),default:ANY  " endorsementPolicyPattern
endorsementPolicyPattern=${endorsementPolicyPattern:-"ANY"}

majorityPatternMin=1
if [ ${endorsementPolicyPattern} = "MAJORITY" ];then
  read -p "please input the minimum endorsement count for MAJORITY policy reach condition,default:1  " majorityPatternMin
  majorityPatternMin=${majorityPatternMin:-"1"}
fi

endorsementPolicy=$(python ./config-fragments/endorsement-policy-generate.py --endorsementPolicyPattern ${endorsementPolicyPattern} --orgCount ${orgCount} --majorityPatternMin ${majorityPatternMin})

echo "============================================================================================================================================"
echo "Step5: Verify Fabric Parameters"
echo "============================================================================================================================================"
echo "orgCount:${orgCount}"
echo "peerCountInOrg:${peerCountInOrg}"
echo "zkCount:${zkCount}"
echo "kafkaCount:${kafkaCount}"
echo "defaultNormalUserCountInOrg:${defaultNormalUserCountInOrg}"
echo "ordererOrgName:${ordererOrgName}"
echo "ordererHostName:${ordererHostName}"
echo "domainName:${domainName}"
echo "profilePrefixName:${profilePrefixName}"
echo "consortiumName:${consortiumName}"
echo "fabricNetworkName:${fabricNetworkName}"
echo "registrarUserName:${registrarUserName}"
echo "registrarUserPassword:${registrarUserPassword}"
echo "couchdbUserName:${couchdbUserName}"
echo "couchdbUserPassword:${couchdbUserPassword}"
echo "channelName:${channelName}"
echo "endorsementPolicyPattern:${endorsementPolicyPattern}"
echo "majorityPatternMin:${majorityPatternMin}"
echo "endorsementPolicy:${endorsementPolicy}"


echo "============================================================================================================================================"
echo "Step6: Setting Necessary  Params For Mysql"
echo "============================================================================================================================================"
read -p "please input root password for mysql ,default:N0password  " mysqlRootPassword
mysqlRootPassword=${mysqlRootPassword:-"N0password"}

read -p "please input database name for tfs-admin ,default:tfs_admin_db  " tfsAdminDbName
tfsAdminDbName=${tfsAdminDbName:-"tfs_admin_db"}

read -p "please input database username for tfs-admin ,default:tfs_admin  " tfsAdminDbUserName
tfsAdminDbUserName=${tfsAdminDbUserName:-"tfs_admin"}

read -p "please input database password for tfs-admin ,default:tfs_admin@123  " tfsAdminDbUserPassword
tfsAdminDbUserPassword=${tfsAdminDbUserPassword:-"tfs_admin@123"}

read -p "please input database name for tfs-api ,default:tfs_api_db  " tfsApiDbName
tfsApiDbName=${tfsApiDbName:-"tfs_api_db"}

read -p "please input database username for tfs-api ,default:tfs_api  " tfsApiDbUserName
tfsApiDbUserName=${tfsApiDbUserName:-"tfs_api"}

read -p "please input database password for tfs-api ,default:tfs_api@123  " tfsApiDbUserPassword
tfsApiDbUserPassword=${tfsApiDbUserPassword:-"tfs_api@123"}



echo "============================================================================================================================================"
echo "Step7: Verify Mysql Parameters"
echo "============================================================================================================================================"
echo "mysqlRootPassword:${mysqlRootPassword}"
echo "tfsAdminDbName: ${tfsAdminDbName}"
echo "tfsAdminDbUserName: ${tfsAdminDbUserName}"
echo "tfsAdminDbUserPassword: ${tfsAdminDbUserPassword}"
echo "tfsApiDbName: ${tfsApiDbName}"
echo "tfsApiDbUserName: ${tfsApiDbUserName}"
echo "tfsApiDbUserPassword: ${tfsApiDbUserPassword}"

echo "============================================================================================================================================"
echo "Step8: Cleanup environments"
echo "============================================================================================================================================"
./script-fragments/cleanup-env.sh  \
      ${installationPkgMountVolumeRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${installationPkgSwiftStorageRoot} \
      ${installationPkgMySqlStorageRoot}  \
      ${installationPkgMySqlDbShellArtifactRoot} \
      ${installationPkgLogRoot} \
      ${installationPkgApplicationArtifactsRoot} \
      ${TFS_APPLICATION_PREFIX} \
      ${TFS_API_APPLICATION_SHORT_NAME} \
      ${domainName} \
      ${HOST_FILE} \
      ${TFS_ADMIN_APPLICATION_SHORT_NAME} \
      ${PROFILE}


echo "============================================================================================================================================"
echo "Step9: Setup Fundamental Tools"
echo "============================================================================================================================================"
. ./script-fragments/fundamental-env-setup.sh \
      ${installationPkgShellRoot} \
      ${installationPkgInstallerRoot} \
      ${curlRoot} \
      ${dockerRoot} \
      ${jdkRoot} \
      ${nodeRoot} \
      ${CURL_INSTALLER_NAME} \
      ${CURL_FOLDER_NAME} \
      ${DOCKER_INSTALLER_NAME} \
      ${DOCKER_FOLDER_NAME} \
      ${JDK_INSTALLER_NAME} \
      ${JDK_FOLDER_NAME} \
      ${NODE_INSTALLER_NAME} \
      ${NODE_FOLDER_NAME} 
#source /etc/profile
export JAVA_HOME=${jdkRoot}/${JDK_FOLDER_NAME}
export PATH=$PATH:$JAVA_HOME/bin
echo "============================================================================================================================================"
echo "Step10: Download Fabric Docker Images"
echo "============================================================================================================================================"
./script-fragments/fabric-docker-image-download.sh \
      ${FABRIC_DOCKER_IMAGE_VERSION} \
      ${FABRIC_DOCKER_IMAGE_OS_NAME} \
      ${FABRIC_DOCKER_IMAGE_3P_VERSION}

echo "============================================================================================================================================"
echo "Step11: Generate crypto-config.yaml"
echo "============================================================================================================================================"
./script-fragments/generate-cryptoconfig-yaml.sh  \
      ${installationPkgShellRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${orgCount} \
      ${peerCountInOrg} \
      ${defaultNormalUserCountInOrg} \
      ${ordererOrgName} \
      ${ordererHostName} \
      ${domainName}


echo "============================================================================================================================================"
echo "Step12: Generate crypto-config Folder Hierarchy based on crypto-config.yaml"
echo "============================================================================================================================================"
./script-fragments/generate-cryptoconfig-hierarchy.sh  \
      ${installationPkgFabricToolsRoot} \
      ${installationPkgFabricArtifactsRoot}


echo "============================================================================================================================================"
echo "Step13: Generate configtx.yaml"
echo "============================================================================================================================================"
./script-fragments/generate-configtx-yaml.sh  \
      ${installationPkgShellRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${orgCount} \
      ${kafkaCount}  \
      ${ordererOrgName} \
      ${domainName} \
      ${profilePrefixName} \
      ${consortiumName}


echo "============================================================================================================================================"
echo "Step14: Generate genesis.block, anchor peer etc"
echo "============================================================================================================================================"
ordererGenesisProfileName=${profilePrefixName}OrdererGenesis
channelProfileName=${profilePrefixName}Channel
./script-fragments/config-tx.sh  \
      ${installationPkgFabricToolsRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${orgCount} \
      ${ordererGenesisProfileName} \
      ${channelProfileName} \
      ${channelName}


echo "============================================================================================================================================"
echo "Step15: Generate docker-compose.yaml"
echo "============================================================================================================================================"
./script-fragments/generate-dockercompose-yaml.sh  \
      ${installationPkgShellRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${installationPkgMountVolumeRoot} \
      ${installationPkgChaincodeRoot} \
      ${installationPkgChaincodeName} \
      ${installationPkgChaincodePath} \
      ${installationPkgChaincodeVersion} \
      ${orgCount} \
      ${zkCount} \
      ${kafkaCount} \
      ${peerCountInOrg} \
      ${fabricNetworkName} \
      ${couchdbUserName} \
      ${couchdbUserPassword} \
      ${domainName}  \
      ${registrarUserName} \
      ${registrarUserPassword} \
      ${ordererOrgName} \
      ${ordererHostName} \
      ${channelName} \
      ${endorsementPolicyPattern} \
      ${majorityPatternMin}

echo "============================================================================================================================================"
echo "Step16: create mount volume points based on the configuration"
echo "============================================================================================================================================"
./script-fragments/create-mount-volume.sh \
      ${installationPkgMountVolumeRoot} \
      ${zkCount} \
      ${kafkaCount} \
      ${orgCount} \
      ${peerCountInOrg}


echo "============================================================================================================================================"
echo "Step17: Startup the fabric environment based on docker-compose.yaml"
echo "============================================================================================================================================"
./script-fragments/startup-fabric-env.sh \
      ${installationPkgFabricArtifactsRoot}

#sleep 30s to wait for the chaincode instantiate successfully
sleep 30s

echo "============================================================================================================================================"
echo "Step18: Setup swift environment"
echo "============================================================================================================================================"
./script-fragments/swift-setup.sh  \
      ${installationPkgSwiftStorageRoot} \
      ${SWIFT_STORAGE_SERVICE_PROXY_BIND_PORT} \
      ${SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT} \
      ${SWIFT_IDENTITY_SERVICE_USER_BIND_PORT} \
      ${internalIp}


echo "============================================================================================================================================"
echo "Step19: Setup Mysql environment"
echo "============================================================================================================================================"
./script-fragments/mysql-setup.sh  \
      ${installationPkgMySqlDbShellRoot} \
      ${installationPkgMySqlDbShellArtifactRoot} \
      ${installationPkgMySqlStorageRoot} \
      ${tfsAdminDbName}	\
      ${tfsAdminDbUserName} \
      ${tfsAdminDbUserPassword} \
      ${tfsApiDbName} \
      ${tfsApiDbUserName}  \
      ${tfsApiDbUserPassword} \
      ${mysqlRootPassword} \
      ${MYSQL_BIND_ACCESS_PORT}
sleep 30s

echo "============================================================================================================================================"
echo "Step20: Generate network-config.yaml"
echo "============================================================================================================================================"
./script-fragments/generate-networkconfig-yaml.sh  \
      ${installationPkgShellRoot}  \
      ${installationPkgFabricArtifactsRoot} \
      ${orgCount} \
      ${peerCountInOrg} \
      ${domainName} \
      ${registrarUserName} \
      ${registrarUserPassword} \
      ${channelName}


echo "============================================================================================================================================"
echo "Step21: Generate the tfs-api application configuration file"
echo "============================================================================================================================================"
./script-fragments/generate-tfs-api-configfile.sh  \
      ${installationPkgShellRoot}  \
      ${installationPkgApplicationArtifactsRoot} \
      ${installationPkgFabricArtifactsRoot} \
      ${TFS_API_SERVICE_PORT} \
      ${externalIp} \
      ${MYSQL_BIND_ACCESS_PORT} \
      ${tfsApiDbName} \
      ${tfsApiDbUserName} \
      ${tfsApiDbUserPassword} \
      ${MAIL_HOST} \
      ${MAIL_USERNAME} \
      ${MAIL_PASSWORD} \
      ${MAIL_SENDER} \
      ${MAIL_RECEIVER} \
      ${BUILD_DATE} \
      ${BUILD_VERSION} \
      ${installationPkgChaincodeName} \
      ${installationPkgChaincodeVersion} \
      ${SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT} \
      ${OPENSTACK_SWIFT_USERNAME}  \
      ${OPENSTACK_SWIFT_PASSWORD}  \
      ${OPENSTACK_SWIFT_PROJECTNAME} \
      ${OPENSTACK_SWIFT_PROJECTDOMAIN} \
      ${OPENSTACK_SWIFT_CONTAINERNAME} \
      ${TFS_API_CONFIGFILE_NAME} \
      ${APPLICATION_TARGET_ENV}
  

echo "============================================================================================================================================"
echo "Step22: Modify host configuration based on the fabric network to make fabric client communicate with fabric network  working "
echo "============================================================================================================================================"
./script-fragments/config-hosts.sh \
     ${orgCount} \
     ${peerCountInOrg} \
     ${ordererHostName} \
     ${internalIp} \
     ${domainName} \
     ${HOST_FILE}


echo "============================================================================================================================================"
echo "Step23: Install And Run tfs-api application"
echo "============================================================================================================================================"
./script-fragments/tfs-api-setup.sh  \
      ${installationPkgApplicationRoot}  \
      ${TFS_API_APPLICATION_FULL_NAME}  \
      ${installationPkgApplicationArtifactsRoot}  \
      ${TFS_API_CONFIGFILE_NAME} \
      ${installationPkgLogRoot}


echo "============================================================================================================================================"
echo "Step24: Generate the tfs-admin application configuration file"
echo "============================================================================================================================================"
./script-fragments/generate-tfs-admin-configfile.sh \
      ${installationPkgShellRoot} \
      ${installationPkgApplicationArtifactsRoot} \
      ${TFS_ADMIN_CONFIGFILE_NAME} \
      ${APPLICATION_TARGET_ENV} \
      ${TFS_APPLICATION_PREFIX} \
      ${TFS_API_APPLICATION_SHORT_NAME} \
      ${TFS_API_SERVICE_PORT} \
      ${externalIp} \
      ${MYSQL_BIND_ACCESS_PORT} \
      ${TFS_ADMIN_SERVICE_PORT} \
      ${tfsAdminDbName} \
      ${tfsAdminDbUserName} \
      ${tfsAdminDbUserPassword} \
      ${BUILD_DATE} \
      ${BUILD_VERSION} 



echo "============================================================================================================================================"
echo "Step25: Install And Run tfs-admin application"
echo "============================================================================================================================================"
./script-fragments/tfs-admin-setup.sh \
      ${installationPkgApplicationRoot} \
      ${TFS_ADMIN_APPLICATION_FULL_NAME} \
      ${installationPkgApplicationArtifactsRoot} \
      ${TFS_ADMIN_CONFIGFILE_NAME} \
      ${installationPkgLogRoot} 


echo "============================================================================================================================================"
echo "Step26: Install And Run tfs-explorer application"
echo "============================================================================================================================================"
./script-fragments/tfs-explorer-setup.sh \
      ${installationPkgApplicationRoot} \
      ${TFS_EXPLORER_APPLICATION_FULL_NAME} \
      ${externalIp} \
      ${TFS_EXPLORER_SERVICE_PORT} \
      ${TFS_ADMIN_SERVICE_PORT} \
      ${installationPkgApplicationArtifactsRoot} 
