#!/bin/bash

################################################################################################################################################################################

#Script Description : setup each peer ,let each peer join business channel ,and set anchor peers 

#$1 ${orgCount}                  the number of organizations
#$2 ${peerCountInOrg}            the number of peers in each organization
#$3 ${domainName}                the fabric domain name 
#$4 ${channelName}              the business channel name of the network
#$5 ${ordererHostName}           the host name of the orderer

###############################################################################################################################################################################

for i in $(seq 1 $1)
do
      for j in $(seq 0 `expr $2 - 1`)
      do
                #set peer env
                export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.$3/users/Admin@org${i}.$3/msp
                export CORE_PEER_ADDRESS=peer${j}.org${i}.$3:7051
                export CORE_PEER_LOCALMSPID="Org${i}MSP"
                export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.$3/peers/peer${j}.org${i}.$3/tls/ca.crt

                #peer join channel
                peer channel join -b $4.block
      
      done
      
      #set anchor peer
      peer channel update -o $5.$3:7050 -c $4 -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls true --cafile ${ORDERER_CA}
done
