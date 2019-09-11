#!/bin/bash

################################################################################################################################################

#Script Description : generate the crypto-config hierarchy based on the crypto-config.yaml

#$1 ${installationPkgFabricToolsRoot}           the root folder of the fabric tools inside the tarball
#$2 ${installationPkgFabricArtifactsRoot}       the root folder of the generated fabric artifacts inside the tarball

################################################################################################################################################

$1/bin/cryptogen generate --config=$2/crypto-config.yaml --output=$2/crypto-config
