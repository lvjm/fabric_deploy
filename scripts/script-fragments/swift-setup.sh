#!/bin/bash

##################################################################################################################################################

#Script Description: install the swift standalone environment

#$1  ${installationPkgSwiftStorageRoot}                  the root folder of the swift storage inside the tarball
#$2  ${SWIFT_STORAGE_SERVICE_PROXY_BIND_PORT}            the global port setting of the swift storage service proxy
#$3  ${SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT}           the global port setting of the swift identity service for admin
#$4  ${SWIFT_IDENTITY_SERVICE_USER_BIND_PORT}            the global port setting of the swift identity service for user
#$5  ${internalIp}                                       the internal ip address for eth0 network card


##################################################################################################################################################

mkdir -p $1/swift_data/1/node/sdb1 && mkdir -p  $1/swift_data/1/node/sdb5
#run swift docker image
docker run -d  -v "$1/swift_data":/srv -p $4:5000 -p $3:35357 -p $2:8080 --name swift_docker jeantil/openstack-keystone-swift:pike
#recover swift user privilege to srv directory
docker exec -it swift_docker chown -R swift:swift /srv/1/
sleep 30s
#binding access ip address
docker exec -it swift_docker /swift/bin/register-swift-endpoint.sh http://$5:$2/
docker exec -it swift_docker /swift/bin/register-swift-endpoint.sh http://$5:$3/
docker exec -it swift_docker /swift/bin/register-swift-endpoint.sh http://$5:$4/

