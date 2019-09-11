#!/bin/bash
#################################################################################################################################################


#Script Description : generate docker-compose.yaml based on configuration parameters

#$1  ${installationPkgShellRoot}               the root folder of shell scripts inside the tarball
#$2  ${installationPkgFabricArtifactsRoot}     the root folder of generated fabric artifacts inside the tarball
#$3  ${installationPkgMountVolumeRoot}         the root folder of the mount volume inside the tarball which will be used to mapping to docker containers 
#$4  ${installationPkgChaincodeRoot}           the root folder of the chaincode and chaincode index
#$5  ${installationPkgChaincodeName}           the chaincode name
#$6  ${installationPkgChaincodePath}           the chaincode path
#$7  ${installationPkgChaincodeVersion}        the chaincode version
#$8  ${orgCount}                               the number of the Organizations
#$9  ${zkCount}                                the numer of the zookeepers
#$10 ${kafkaCount}                             the number of kafka brokers
#$11 ${peerCountInOrg}                         the number of peers in each organization
#$12 ${fabricNetworkName}                      the fabric network name
#$13 ${couchdbUserName}                        the couchdb user name 
#$14 ${couchdbUserPassword}                    the couchdb user password
#$15 ${domainName}                             the domain name of the fabric network
#$16 ${registrarUserName}                      the registrar user name for each CA in each organization
#$17 ${registrarUserPassword}                  the registrar user password for each CA in each organization
#$18 ${ordererOrgName}                         the name of the orderer organization
#$19 ${ordererHostName}                        the host name of the orderer
#$20 ${channelName}                            the channel name 
#$21 ${endorsementPolicyPattern}               the pattern of the endorsement policy (ANY | MAJORITY |ALL)
#$22 ${majorityPatternMin}                     if endorsement policy = MAJORITY ,the minimum endorsement signature should match

##################################################################################################################################################


python $1/config-fragments/docker-compose-generate.py \
             --installationPkgFabricArtifactsRoot $2  \
             --installationPkgMountVolumeRoot $3  \
             --installationPkgShellRoot $1  \
             --installationPkgChaincodeRoot  $4  \
             --installationPkgChaincodeName  $5  \
             --installationPkgChaincodePath  $6  \
             --installationPkgChaincodeVersion $7  \
             --orgCount $8 \
             --zkCount $9  \
             --kafkaCount ${10}  \
             --peerCountInOrg ${11}  \
             --fabricNetworkName ${12}  \
             --couchdbUserName ${13}  \
             --couchdbUserPassword ${14}  \
             --domainName ${15}  \
             --registrarUserName ${16} \
             --registrarUserPassword ${17}  \
             --ordererOrgName ${18}  \
             --ordererHostName ${19}  \
             --channelName  ${20}  \
             --endorsementPolicyPattern ${21} \
             --majorityPatternMin ${22}

