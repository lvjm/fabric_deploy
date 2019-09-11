#!/bin/bash

##################################################################################################################################################

#Script Description: modify the host config in the target machine

#$1 ${orgCount}               the number of organizations 
#$2 ${peerCountInOrg}         the number of peers in each organization
#$3 ${ordererHostName}        the host name of the orderre
#$4 ${internalIp}             the internal ip
#$5 ${domainName}             the domain name of the fabric env
#$6 ${HOST_FILE}              the host file name (/etc/hosts)

##################################################################################################################################################

# orderer
sed -i '$a\'"$4"'  '"$3.$5"'  '"$3"'' $6

# ca
for i in $(seq 1 $1)
do
     sed -i '$a\'"$4"'  '"ca.org${i}.$5"'  '"ca.org${i}"'' $6
done

# peer 
for i in $(seq 1 $1)
do
      for j in $(seq 0 `expr $2 - 1`)
      do
                sed -i '$a\'"$4"'  '"peer${j}.org${i}.$5"'  '"peer${j}.org${i}"''  $6
      done
done
