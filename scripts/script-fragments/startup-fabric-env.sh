##################################################################################################################################################


#Script Description:  startup the fabric environment based on the docker-compose.yaml

#$1 ${installationPkgFabricArtifactsRoot}  the root folder of the generated fabric artifacts inside the tarball

##################################################################################################################################################

docker-compose  -f  $1/docker-compose.yaml up -d

