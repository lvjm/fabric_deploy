#!/bin/bash
 echo "${installationPkgApplicationRoot}:"$1
 echo "${TFS_EXPLORER_FULL_NAME}:"$2
 echo "${TFS_EXPLORER_PROXY_IP}:"$3
 echo "${TFS_EXPLORER_PORT}:"$4
 echo "${TFS_ADMIN_SERVICE_PORT}:"$5
 echo "${installationPkgApplicationArtifactsRoot}:" $6
 unzip ${1}/${2}.zip -d ${6}
 cd ${6}/${2}
 # replace ip address in default.conf
 sed -i "s/tfs-admin-front-stage.at2plus.com/${3}:${5}/" default.conf
 docker build -t docker_tfs_explorer .
 docker run -p ${4}:80 -d docker_tfs_explorer
