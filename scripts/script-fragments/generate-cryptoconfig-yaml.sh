#!/bin/bash

####################################################################################################################################################################

#Script Description: generate the crypto-config.yaml based on input parameters

#$1 ${installationPkgShellRoot}                   the root folder of shell scripts inside the tarball
#$2 ${installationPkgFabricArtifactsRoot}         the root folder of generated fabric artifacts inside the tarball
#$3 ${orgCount}                                   the number of Organizations
#$4 ${peerCountInOrg}                             the nubmer of the peer in each organization
#$5 ${defaultNormalUserCountInOrg}                the default normal user that need to be created when initializing (will create the MSP certificates for these users
#$6 ${ordererOrgName}                             the orderer organization name
#$7 ${ordererHostName}                            the host name of orderer
#$8 ${domainName}                                 the domain name for fabric network


###################################################################################################################################################################


python $1/config-fragments/crypto-config-generate.py \
       --installationPkgFabricArtifactsRoot  $2 \
       --orgCount $3   \
       --peerCountInOrg $4 \
       --defaultNormalUserCountInOrg $5  \
       --ordererOrgName $6 \
       --ordererHostName $7  \
       --domainName $8
