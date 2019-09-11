#!/bin/bash
##################################################################################################################################################

#Script Description: create genesis.block ,channel.tx ,ancherpeers etc


#$1 ${installationPkgFabricToolsRoot}        the root folder of the fabric tools including [configtxgen,cryptogen] inside the tarball
#$2 ${installationPkgFabricArtifactsRoot}    the root folder of the generated fabric artifacts includng xxx.yaml,crypto-config hierarchy,channel-artifacts
#$3 ${orgCount}                              the number of Organization
#$4 ${ordererGenesisProfileName}             the name of orderer genesis profile 
#$5 ${channelProfileName}                    the name of channel profile
#$6 ${channelName}                           the business channel name


###################################################################################################################################################

set -x


mkdir -p  $2/channel-artifacts

$1/bin/configtxgen -configPath $2  -profile $4 -outputBlock $2/channel-artifacts/genesis.block

$1/bin/configtxgen -configPath $2 -profile $5 -outputCreateChannelTx $2/channel-artifacts/channel.tx -channelID $6

for (( i = 1; i < $3  + 1; i++ )); do
	$1/bin/configtxgen -configPath $2 -profile $5 -outputAnchorPeersUpdate $2/channel-artifacts/Org${i}MSPanchors.tx -channelID $6  -asOrg Org${i}MSP
done

