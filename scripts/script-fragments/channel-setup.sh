#!/bin/bash

##################################################################################################################################################

#Script Description: create channel

#$1 ${ordererHostName}   the host name of the orderer
#$2 ${domainName}        the domain name of the fabric environment
#$3 ${channelName}       the business channel name

##################################################################################################################################################

sleep 20s
peer channel create -o $1.$2:7050 -c $3 -f ./channel-artifacts/channel.tx --tls true --cafile $ORDERER_CA
