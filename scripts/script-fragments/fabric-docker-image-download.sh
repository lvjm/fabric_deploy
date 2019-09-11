#!/bin/bash

################################################################################################################################################################################

#Script Description : pull latest docker fabric images

#$1 ${FABRIC_DOCKER_IMAGE_VERSION}           the fabric docker image version
#$2 ${FABRIC_DOCKER_IMAGE_OS_NAME}           the os name of the fabric docker images
#$3 ${FABRIC_DOCKER_IMAGE_3P_VERSION}       the fabric docker image 3rd party version    

###############################################################################################################################################################################


set -x

# pull latest images
fabricDockerImageVesion=$1
fabricDockerImageOsName=$2
fabricDockerImage3pVersion=$3
TAG=$fabricDockerImageOsName-$fabricDockerImageVesion
THIRDPARTY_TAG=$fabricDockerImageOsName-$fabricDockerImage3pVersion

for IMAGES in peer orderer ccenv javaenv tools ca; do
    echo "PULLING FABRIC IMAGE: $IMAGES"
    echo
    docker pull hyperledger/fabric-$IMAGES:$TAG
done

for IMAGES in couchdb kafka zookeeper; do
    echo "PULLING FABRIC IMAGE: $IMAGES"
    echo
    docker pull hyperledger/fabric-$IMAGES:$THIRDPARTY_TAG
done
