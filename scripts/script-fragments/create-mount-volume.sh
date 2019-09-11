#!/bin/bash

##################################################################################################################################################

#Script Description: create the mount volume which will be used for mapping to docker containers

#$1 ${installationPkgMountVolumeRoot}    the root folder of the mount volume inside the tarball
#$2 ${zkCount}                           the number of the zookeepers
#$3 ${kafkaCount}                        the number of the kafka count
#$4 ${orgCount}                          the number of Organizations
#$5 ${peerCountInOrg}                    the number of peers inside each organization

##################################################################################################################################################

# mkdir zk
for i in $(seq 1 $2)
do
    mkdir $1/zk$i
done

# mkdir kafka
for i in $(seq 1 $3)
do
    mkdir $1/kafka${i}-data
done

# mkdir orderer
mkdir $1/orderer

# mkdir couchdb
for i in $(seq 1 $4)
do
    mkdir $1/couchdb.org$i
done

# mkdir ca
for i in $(seq 1 $4)
do
    mkdir  $1/ca.org$i
done

# mkdir peer
for i in $(seq 1 $4)
do
    for j in $(seq 1 $5)
        do
           mkdir $1/peer$(($j-1)).org$i
        done
done
#
chmod -R 777 $1

