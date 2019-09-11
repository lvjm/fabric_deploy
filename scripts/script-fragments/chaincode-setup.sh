#!/bin/bash
set -x
##################################################################################################################################################

#Script Description: install and instantiate chaincode


#$1 ${orgCount}                           the count of Organization
#$2 ${peerCountInOrg}                     the peer number in each Organization
#$3 ${domainName}                         the domain name for fabric environment
#$4 ${installationPkgChaincodePath}       the chaincode path of chaincode inside the tarball
#$5 ${installationPkgChaincodeName}       the chaincode name of chaincode inside the tarball
#$6 ${installationPkgChaincodeVersion}    the chaincode version of chaincode inside the tarball
#$7 ${channelName}                        the business channel name
#$8 ${endorsementPolicyPattern}           the Pattern of the endorsement policy (ALL | MAJORITY | ANY)
#$9 ${majorityPatternMin}                 when the endorsement policy is set to MAJORITY ,the minimum endorsement signature which should be provided


###################################################################################################################################################


echo "Begin installing the chaincode " $5
for i in $(seq 1 $1)
do
      for j in $(seq 0 `expr $2 - 1`)
      do
                #set peer env
                export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.$3/users/Admin@org${i}.$3/msp
                export CORE_PEER_ADDRESS=peer${j}.org${i}.$3:7051
                export CORE_PEER_LOCALMSPID="Org${i}MSP"
                export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.$3/peers/peer${j}.org${i}.$3/tls/ca.crt
                #install chaincode
                peer chaincode install -p $4 -n $5 -v $6
      done
done


echo "End installing the chaincode"

echo "Begin instantiating the chaincode " $5

#invoke endorsement-policy-generate.py to generate the endorsement policy based on parameters 
endorsementPolicy=$(python ./scripts/config-fragments/endorsement-policy-generate.py  --endorsementPolicyPattern $8  --orgCount $1  --majorityPatternMin $9)
echo "endorsementPolicy:"  ${endorsementPolicy}

peer chaincode instantiate -n $5 --tls true --cafile ${ORDERER_CA} -c '{"Args":["init"]}' -v $6 -C $7 -P ${endorsementPolicy}
#peer chaincode instantiate -n $5 --tls true --cafile ${ORDERER_CA} -c '{"Args":["init"]}' -v $6 -C $7
echo "End instantiating the chaincode "
