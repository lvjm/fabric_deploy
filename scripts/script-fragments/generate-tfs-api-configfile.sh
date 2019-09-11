#################################################################################################################################################

#Script Description:  generate tfs-api-config.properties based on configuration parameters

#$1  ${installationPkgShellRoot}                    the root folder of the shell scripts inside the tarball
#$2  ${installationPkgApplicationArtifactsRoot}     the root folder of the application artifacts(store the config files for each application) inside the tarball
#$3  ${installationPkgFabricArtifactsRoot}          the root folder of the fabric artifacts inside the tarball
#$4  ${TFS_API_SERVICE_PORT}                        the global port definiton of the tfs-api
#$5  ${externalIp}                                  the external ip of the target machine
#$6  ${MYSQL_BIND_ACCESS_PORT}                      the binding port of mysql
#$7  ${tfsApiDbName}                                the database name of the tfs-api application
#$8  ${tfsApiDbUserName}                            the db user name of the tfs-api application
#$9  ${tfsApiDbUserPassword}                        the db user password of the tfs-api application
#$10 ${MAIL_HOST}                                   the host of the mail
#$11 ${MAIL_USERNAME}                               the username of the mail server
#$12 ${MAIL_PASSWORD}                               the password of the mail server
#$13 ${MAIL_SENDER}                                 the default sender of mail
#$14 ${MAIL_RECEIVER}                               the default receiver of the mail
#$15 ${BUILD_DATE}                                  the build date of the application 
#$16 ${BUILD_VERSION}                               the build version of the application
#$17 ${installationPkgChaincodeName}                the chaincode name inside the tarball
#$18 ${installationPkgChaincodeVersion}             the chaincodde version inside the tarball
#$19 ${SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT}      the binding port of swift identity service
#$20 ${OPENSTACK_SWIFT_USERNAME}                    the user name of openstack swift
#$21 ${OPENSTACK_SWIFT_PASSWORD}                    the user password of openstack swift
#$22 ${OPENSTACK_SWIFT_PROJECTNAME}                 the project name of openstack swift
#$23 ${OPENSTACK_SWIFT_PROJECTDOMAIN}               the project domain of the openstack swift
#$24 ${OPENSTACK_SWIFT_CONTAINERNAME}               the project container name of the openstack swift
#$25 ${TFS_API_CONFIGFILE_NAME}                     the configuration file tfs-api application
#$26 ${APPLICATION_TARGET_ENV}                      the target profile of tfs-api application

##################################################################################################################################################


#create the properties file first ,so that the file can write to it
touch ${2}/${25}


python ${1}/config-fragments/tfs-api-configfile-generate.py  \
      --installationPkgApplicationArtifactsRoot ${2} \
      --installationPkgFabricArtifactsRoot  ${3} \
      --TFS_API_SERVICE_PORT ${4} \
      --externalIp ${5} \
      --MYSQL_BIND_ACCESS_PORT ${6} \
      --tfsApiDbName ${7} \
      --tfsApiDbUserName ${8} \
      --tfsApiDbUserPassword ${9} \
      --MAIL_HOST ${10} \
      --MAIL_USERNAME ${11} \
      --MAIL_PASSWORD ${12} \
      --MAIL_SENDER ${13} \
      --MAIL_RECEIVER ${14} \
      --BUILD_DATE ${15} \
      --BUILD_VERSION ${16} \
      --installationPkgChaincodeName ${17} \
      --installationPkgChaincodeVersion ${18} \
      --SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT ${19} \
      --OPENSTACK_SWIFT_USERNAME ${20} \
      --OPENSTACK_SWIFT_PASSWORD ${21} \
      --OPENSTACK_SWIFT_PROJECTNAME ${22} \
      --OPENSTACK_SWIFT_PROJECTDOMAIN ${23} \
      --OPENSTACK_SWIFT_CONTAINERNAME ${24} \
      --TFS_API_CONFIGFILE_NAME ${25} \
      --APPLICATION_TARGET_ENV ${26}
   

