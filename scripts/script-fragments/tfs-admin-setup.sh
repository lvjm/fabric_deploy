
#$1  ${installationPkgApplicationRoot}
#$2  ${TFS_ADMIN_APPLICATION_FULL_NAME}
#$3  ${installationPkgApplicationArtifactsRoot}
#$4  ${TFS_ADMIN_CONFIGFILE_NAME}
#$5  ${installationPkgLogRoot}



echo "${installationPkgApplicationRoot}:"$1
echo "${TFS_ADMIN_APPLICATION_FULL_NAME}:"$2
echo "${installationPkgApplicationArtifactsRoot}:"$3
echo "${TFS_ADMIN_CONFIGFILE_NAME}:"$4
echo "${installationPkgLogRoot}:"$5

java -DLOG_HOME=${5} \
     -jar ${1}/${2}.jar  \
     --spring.config.additional-location=${3}/${4} &
