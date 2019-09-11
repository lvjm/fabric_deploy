#!/bin/bash

##############################################################################################################################################################

#Script Description: install the mysql ,setting the normal user name, password ,database name ,and execute the DDL

#$1 ${installationPkgMySqlDbShellRoot}               the root folder of the mysql sql shell scripts (with placeholders)
#$2 ${installationPkgMySqlDbShellArtifactRoot}       the root folder of the mysql sql shell script artifacts (replace the placeholders with input parameters
#$3 ${installationPkgMySqlStorageRoot}               the root folder of the mysql storage
#$4 ${tfsAdminDbName}                                the database name for tfs-admin
#$5 ${tfsAdminDbUserName}                            the database user name for tfs-admin
#$6 ${tfsAdminDbUserPassword}                        the database user password for tfs-admin
#$7 ${tfsApiDbName}                                  the database name for tfs-api
#$8 ${tfsApiDbUserName}                              the database user name for tfs-api
#$9 ${tfsApiDbUserPassword}                          the database user password for tfs-api
#$10 ${mysqlRootPassword}                            the root password for mysql
#$11 ${MYSQL_BIND_ACCESS_PORT}                       the global setting of the mysql binding port

###############################################################################################################################################################

docker pull mysql:5.7
#copy from the shell root to the db shell artifacts folder
cp -r $1/*  $2/
#replace the db sql scripts in artifacts folder using the placeholder
sed -i 's/db_place_holder/'$4'/g'                   $2/1_tfs_admin_create_table.sql
sed -i 's/user_place_holder/'$5'/g'                 $2/1_tfs_admin_create_table.sql
sed -i 's/password_place_holder/'$6'/g'             $2/1_tfs_admin_create_table.sql
sed -i 's/db_place_holder/'$7'/g'                   $2/2_tfs_api_create_table.sql
sed -i 's/user_place_holder/'$8'/g'                 $2/2_tfs_api_create_table.sql
sed -i 's/password_place_holder/'$9'/g'             $2/2_tfs_api_create_table.sql

docker run  -e MYSQL_ROOT_PASSWORD=${10}  -v "$3":/var/lib/mysql  --mount type=bind,source="$2",target=/docker-entrypoint-initdb.d  -p ${11}:3306 -d mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

