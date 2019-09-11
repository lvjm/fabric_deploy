#!/bin/bash

################################################################################################################################################
#$1 ${installationPkgShellRoot}
#$2  ${installationPkgApplicationArtifactsRoot} 
#$3 ${TFS_ADMIN_API_CONFIGFILE_NAME} 
#$4 ${APPLICATION_TARGET_ENV} 
#$5 ${TFS_APPLICATION_PREFIX} 
#$6 ${TFS_API_APPLICATION_SHORT_NAME}
#$7 ${TFS_API_SERVICE_PORT} 
#$8 ${externalIp}
#$9 ${MYSQL_BIND_ACCESS_PORT}
#$10 ${TFS_ADMIN_SERVICE_PORT} 
#$11 ${tfsAdminDbName}
#$12 ${tfsAdminDbUserName}
#$13 ${tfsAdminDbUserPassword}  
#$14 ${BUILD_DATE}
#$15 ${BUILD_VERSION} 

##################################################################################################################################################

touch ${2}/${3}

python ${1}/config-fragments/tfs-admin-configfile-generate.py \
      --installationPkgApplicationArtifactsRoot ${2} \
      --TFS_ADMIN_CONFIGFILE_NAME ${3} \
      --APPLICATION_TARGET_ENV ${4} \
      --TFS_APPLICATION_PREFIX ${5} \
      --TFS_API_APPLICATION_SHORT_NAME ${6} \
      --TFS_API_SERVICE_PORT ${7} \
      --externalIp ${8} \
      --MYSQL_BIND_ACCESS_PORT ${9} \
      --TFS_ADMIN_SERVICE_PORT ${10} \
      --tfsAdminDbName ${11} \
      --tfsAdminDbUserName ${12} \
      --tfsAdminDbUserPassword ${13} \
      --BUILD_DATE ${14} \
      --BUILD_VERSION ${15}

