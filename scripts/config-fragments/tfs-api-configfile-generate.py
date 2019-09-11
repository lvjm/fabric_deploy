#!/usr/bin/python


import property
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgApplicationArtifactsRoot', required=True, type=str)
parser.add_argument('--installationPkgFabricArtifactsRoot', required=True, type=str)
parser.add_argument('--TFS_API_SERVICE_PORT', required=True, type=str)
parser.add_argument('--externalIp', required=True, type=str)
parser.add_argument('--MYSQL_BIND_ACCESS_PORT', required=True, type=str)
parser.add_argument('--tfsApiDbName', required=True, type=str)
parser.add_argument('--tfsApiDbUserName', required=True, type=str)
parser.add_argument('--tfsApiDbUserPassword', required=True, type=str)
parser.add_argument('--MAIL_HOST', required=True, type=str)
parser.add_argument('--MAIL_USERNAME', required=True, type=str)
parser.add_argument('--MAIL_PASSWORD', required=True, type=str)
parser.add_argument('--MAIL_SENDER', required=True, type=str)
parser.add_argument('--MAIL_RECEIVER', required=True, type=str)
parser.add_argument('--BUILD_DATE', required=True, type=str)
parser.add_argument('--BUILD_VERSION', required=True, type=str)
parser.add_argument('--installationPkgChaincodeName', required=True, type=str)
parser.add_argument('--installationPkgChaincodeVersion', required=True, type=str)
parser.add_argument('--SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT', required=True, type=str)
parser.add_argument('--OPENSTACK_SWIFT_USERNAME', required=True, type=str)
parser.add_argument('--OPENSTACK_SWIFT_PASSWORD', required=True, type=str)
parser.add_argument('--OPENSTACK_SWIFT_PROJECTNAME', required=True, type=str)
parser.add_argument('--OPENSTACK_SWIFT_PROJECTDOMAIN', required=True, type=str)
parser.add_argument('--OPENSTACK_SWIFT_CONTAINERNAME', required=True, type=str)
parser.add_argument('--TFS_API_CONFIGFILE_NAME', required=True, type=str)  
parser.add_argument('--APPLICATION_TARGET_ENV', required=True, type=str)

                                        
args = parser.parse_args()
installationPkgApplicationArtifactsRoot      = args.installationPkgApplicationArtifactsRoot
installationPkgFabricArtifactsRoot           = args.installationPkgFabricArtifactsRoot
TFS_API_SERVICE_PORT                         = args.TFS_API_SERVICE_PORT
externalIp                                   = args.externalIp
MYSQL_BIND_ACCESS_PORT                       = args.MYSQL_BIND_ACCESS_PORT
tfsApiDbName                                 = args.tfsApiDbName
tfsApiDbUserName                             = args.tfsApiDbUserName
tfsApiDbUserPassword                         = args.tfsApiDbUserPassword
MAIL_HOST                                    = args.MAIL_HOST
MAIL_USERNAME                                = args.MAIL_USERNAME
MAIL_PASSWORD                                = args.MAIL_PASSWORD
MAIL_SENDER                                  = args.MAIL_SENDER
MAIL_RECEIVER                                = args.MAIL_RECEIVER
BUILD_DATE                                   = args.BUILD_DATE
BUILD_VERSION                                = args.BUILD_VERSION
installationPkgChaincodeName                 = args.installationPkgChaincodeName
installationPkgChaincodeVersion              = args.installationPkgChaincodeVersion
SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT       = args.SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT
OPENSTACK_SWIFT_USERNAME                     = args.OPENSTACK_SWIFT_USERNAME
OPENSTACK_SWIFT_PASSWORD                     = args.OPENSTACK_SWIFT_PASSWORD
OPENSTACK_SWIFT_PROJECTNAME                  = args.OPENSTACK_SWIFT_PROJECTNAME
OPENSTACK_SWIFT_PROJECTDOMAIN                = args.OPENSTACK_SWIFT_PROJECTDOMAIN
OPENSTACK_SWIFT_CONTAINERNAME                = args.OPENSTACK_SWIFT_USERNAME
TFS_API_CONFIGFILE_NAME                      = args.TFS_API_CONFIGFILE_NAME
APPLICATION_TARGET_ENV                       = args.APPLICATION_TARGET_ENV


file_path = installationPkgApplicationArtifactsRoot+'/'+TFS_API_CONFIGFILE_NAME 
print("file_path:"+file_path)
props = property.parse(file_path)  
props.put('spring.profiles.active', APPLICATION_TARGET_ENV)
props.put('server.port', TFS_API_SERVICE_PORT) 
props.put('spring.datasource.url', 'jdbc:mysql://' + externalIp + ':' + MYSQL_BIND_ACCESS_PORT + '/'+ tfsApiDbName + '?useUnicode=true&characterEncoding=utf-8&useSSL=false')
props.put('spring.datasource.username', tfsApiDbUserName)
props.put('spring.datasource.password', tfsApiDbUserPassword)
props.put('spring.mail.host', MAIL_HOST)
props.put('spring.mail.username', MAIL_USERNAME)
props.put('spring.mail.password', MAIL_PASSWORD)
props.put('mail.sender', MAIL_SENDER)
props.put('mail.receiver', MAIL_RECEIVER)
props.put('build.date', BUILD_DATE)
props.put('build.version', BUILD_VERSION)
props.put('fabric.network.config-path', installationPkgFabricArtifactsRoot+'/'+'network-config.yaml')
props.put('fabric.chain-code.name', installationPkgChaincodeName)
props.put('fabric.chain-code.version', installationPkgChaincodeVersion)
props.put('openstack.swift.host', 'http://'+externalIp+':'+SWIFT_IDENTITY_SERVICE_ADMIN_BIND_PORT+'/v3')
props.put('openstack.swift.userName', OPENSTACK_SWIFT_USERNAME)
props.put('openstack.swift.password', OPENSTACK_SWIFT_PASSWORD)
props.put('openstack.swift.projectName', OPENSTACK_SWIFT_PROJECTNAME)
props.put('openstack.swift.projectDomain', OPENSTACK_SWIFT_PROJECTDOMAIN)
props.put('openstack.swift.containerName', OPENSTACK_SWIFT_CONTAINERNAME)
