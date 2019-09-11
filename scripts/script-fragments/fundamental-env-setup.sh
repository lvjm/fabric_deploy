#!/bin/bash
set -x

###################################################################################################################################################

#Script Description: install necessary tools including curl、docker、docker-compose、python、pip、jdk、node etc

#$1 ${installationPkgShellRoot}          the root folder of script scripts inside the tarball
#$2 ${installationPkgInstallerRoot}      the installer for each tools 
#$3 ${curlRoot}                          the target installing destination of the curl tools 
#$4 ${dockerRoot}                        the target installing destination of  the docker
#$5 ${jdkRoot}                           the target installing destination of jdk
#$6 ${nodeRoot}                          the target installing destination of node
#$7 ${CURL_INSTALLER_NAME}               the installer of curl
#$8 ${CURL_FOLDER_NAME}                  the name of curl folder
#$9 ${DOCKER_INSTALLER_NAME}             the installer of  docker
#$10 ${DOCKER_FOLDER_NAME}               the name of docker folder 
#$11 ${JDK_INSTALLER_NAME}                the installer of jdk
#$12 ${JDK_FOLDER_NAME}                  the name of jdk folder
#$13 ${NODE_INSTALLER_NAME}              the installer of node
#$14 ${NODE_FOLDER_NAME}                 the name of node folder
###################################################################################################################################################


echo "============================================================================================================================================"
echo "Fundamental Tools Setup======> Installing curl"
echo "============================================================================================================================================"
tar -xzvf  ${2}/curl/${7}  -C  ${2}/curl
cd ${2}/curl/${8}
./configure  --prefix=${3}
make
make install


echo "============================================================================================================================================"
echo "Fundamental Tools Setup=====> Installing docker"
echo "============================================================================================================================================"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

echo "============================================================================================================================================"
echo "Fundamental Tools Setup=====> Installing pip"
echo "============================================================================================================================================"
python ${2}/pip/get-pip.py


echo "============================================================================================================================================"
echo "Fundamental Tools Setup=====> Installing docker-compose"
echo "============================================================================================================================================"
pip uninstall docker-compose
pip install docker-compose

 
echo "============================================================================================================================================"
echo "Fundamental Tools Setup=====> Installing jdk"
echo "============================================================================================================================================"
tar -xzvf  ${2}/jdk/${11} -C  ${5}
export JAVA_HOME=${5}/${12}
export PATH=$PATH:$JAVA_HOME/bin
#sed -i '$a\JAVA_HOME='${5}/${12}''  /etc/profile
#sed -i '$a\PATH='${PATH}:${JAVA_HOME}/bin''  /etc/profile

#export JAVA_HOME=${5}/${12}
#export PATH=$PATH:$JAVA_HOME/bin 
java -version


echo "============================================================================================================================================"
echo "Fundamental Tools Setup=====> Installing node"
echo "============================================================================================================================================"
tar -Jxvf ${2}/node/${13} -C ${6}
export NODE_HOME=${6}/${14}
export PATH=$PATH:$NODE_HOME/bin
#sed -i '$a\NODE_HOME='${6}/${14}''  /etc/profile
#sed -i '$a\PATH='${PATH}:${NODE_HOME}/bin'' /etc/profile
