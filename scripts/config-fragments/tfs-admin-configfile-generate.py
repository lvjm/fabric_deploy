#!/usr/bin/python

import property
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgApplicationArtifactsRoot', required=True, type=str)
parser.add_argument('--TFS_ADMIN_CONFIGFILE_NAME', required=True, type=str)
parser.add_argument('--APPLICATION_TARGET_ENV', required=True, type=str)
parser.add_argument('--TFS_APPLICATION_PREFIX', required=True, type=str)
parser.add_argument('--TFS_API_APPLICATION_SHORT_NAME', required=True, type=str)
parser.add_argument('--TFS_API_SERVICE_PORT',required=True, type=str)
parser.add_argument('--externalIp', required=True, type=str)
parser.add_argument('--MYSQL_BIND_ACCESS_PORT', required=True, type=str)
parser.add_argument('--TFS_ADMIN_SERVICE_PORT', required=True, type=str)
parser.add_argument('--tfsAdminDbName', required=True, type=str)
parser.add_argument('--tfsAdminDbUserName', required=True, type=str)
parser.add_argument('--tfsAdminDbUserPassword', required=True, type=str)
parser.add_argument('--BUILD_DATE', required=True, type=str)
parser.add_argument('--BUILD_VERSION', required=True, type=str)
args=parser.parse_args()



installationPkgApplicationArtifactsRoot  = args.installationPkgApplicationArtifactsRoot
TFS_ADMIN_CONFIGFILE_NAME                = args.TFS_ADMIN_CONFIGFILE_NAME
APPLICATION_TARGET_ENV                   = args.APPLICATION_TARGET_ENV
TFS_APPLICATION_PREFIX                   = args.TFS_APPLICATION_PREFIX
TFS_API_APPLICATION_SHORT_NAME           = args.TFS_API_APPLICATION_SHORT_NAME 
TFS_API_SERVICE_PORT                     = args.TFS_API_SERVICE_PORT
externalIp                               = args.externalIp
MYSQL_BIND_ACCESS_PORT                   = args.MYSQL_BIND_ACCESS_PORT
TFS_ADMIN_SERVICE_PORT                   = args.TFS_ADMIN_SERVICE_PORT
tfsAdminDbName                           = args.tfsAdminDbName
tfsAdminDbUserName                       = args.tfsAdminDbUserName
tfsAdminDbUserPassword                   = args.tfsAdminDbUserPassword
BUILD_DATE                               = args.BUILD_DATE
BUILD_VERSION                            = args.BUILD_VERSION



file_path = installationPkgApplicationArtifactsRoot+'/'+TFS_ADMIN_CONFIGFILE_NAME
print("file_path:"+file_path)
props = property.parse(file_path)
props.put('spring.profiles.active', APPLICATION_TARGET_ENV)
props.put('server.port', TFS_ADMIN_SERVICE_PORT)
props.put('spring.datasource.url', 'jdbc:mysql://' + externalIp + ':' + MYSQL_BIND_ACCESS_PORT + '/'+ tfsAdminDbName + '?useUnicode=true&characterEncoding=utf-8&useSSL=false')
props.put('spring.datasource.username',tfsAdminDbUserName )
props.put('spring.datasource.password', tfsAdminDbUserPassword)
props.put('feign.tfs-api-url', 'http://' + externalIp + ':' + TFS_API_SERVICE_PORT + '/' + TFS_APPLICATION_PREFIX + '/' + TFS_API_APPLICATION_SHORT_NAME)
props.put('build.date', BUILD_DATE)
props.put('build.version', BUILD_VERSION)
props.put('job.greatThanFileNumbersToArchive','10')
