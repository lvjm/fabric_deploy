#!/usr/bin/python

##################################################################################################################################################

#Script Description: 

##################################################################################################################################################

import yaml
import os
from collections import OrderedDict
import argparse

class CustomDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(CustomDumper, self).increase_indent(flow, False)


def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')

yaml.add_representer(type(None), represent_none)

class quoted(str):
    pass

def quoted_presenter(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')
yaml.add_representer(quoted, quoted_presenter)

def setup_yaml():
  represent_dict_order = lambda self, data:  self.represent_mapping('tag:yaml.org,2002:map', data.items())
  yaml.add_representer(OrderedDict, represent_dict_order)    
setup_yaml()

#resolve input parameters
parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgFabricArtifactsRoot', required=True, type=str)
parser.add_argument('--installationPkgMountVolumeRoot', required=True, type=str)
parser.add_argument('--installationPkgShellRoot', required=True, type=str)
parser.add_argument('--installationPkgChaincodeRoot', required=True, type=str)
parser.add_argument('--installationPkgChaincodeName', required=True, type=str)
parser.add_argument('--installationPkgChaincodePath', required=True, type=str)
parser.add_argument('--installationPkgChaincodeVersion', required=True, type=str)
parser.add_argument('--orgCount', required=True, type=int)
parser.add_argument('--zkCount', required=True, type=int)
parser.add_argument('--kafkaCount', required=True, type=int)
parser.add_argument('--peerCountInOrg', required=True, type=int)
parser.add_argument('--fabricNetworkName', required=True, type=str)
parser.add_argument('--couchdbUserName', required=True, type=str)
parser.add_argument('--couchdbUserPassword', required=True, type=str)
parser.add_argument('--domainName', required=True, type=str)
parser.add_argument('--registrarUserName', required=True, type=str)
parser.add_argument('--registrarUserPassword', required=True, type=str)
parser.add_argument('--ordererOrgName', required=True, type=str)
parser.add_argument('--ordererHostName', required=True, type=str)
parser.add_argument('--channelName', required=True, type=str)
parser.add_argument('--endorsementPolicyPattern', required=True, type=str)
parser.add_argument('--majorityPatternMin', required=True, type=int)



args=parser.parse_args()
installationPkgFabricArtifactsRoot  =  args.installationPkgFabricArtifactsRoot
installationPkgMountVolumeRoot = args.installationPkgMountVolumeRoot
installationPkgShellRoot = args.installationPkgShellRoot
installationPkgChaincodeRoot = args.installationPkgChaincodeRoot
installationPkgChaincodeName = args.installationPkgChaincodeName
installationPkgChaincodePath = args.installationPkgChaincodePath
installationPkgChaincodeVersion = args.installationPkgChaincodeVersion
orgCount = args.orgCount
zkCount = args.zkCount
kafkaCount = args.kafkaCount
peerCountInOrg = args.peerCountInOrg
fabricNetworkName = args.fabricNetworkName
couchdbUserName = args.couchdbUserName
couchdbUserPassword = args.couchdbUserPassword
domainName = args.domainName
registrarUserName = args.registrarUserName
registrarUserPassword = args.registrarUserPassword
fabricNetworkName = args.fabricNetworkName
ordererOrgName = args.ordererOrgName
ordererHostName = args.ordererHostName
channelName = args.channelName
endorsementPolicyPattern  = args.endorsementPolicyPattern
majorityPatternMin = args.majorityPatternMin

config = OrderedDict()
#config version and network
config['version'] = '2'
config['networks'] = {fabricNetworkName: None}
services = OrderedDict()

#generate ca containers
for i in range(1, orgCount+1):
  caService = OrderedDict()
  caServiceName = 'ca.org{}'.format(i)
  files = os.listdir(installationPkgFabricArtifactsRoot+'/crypto-config/peerOrganizations/org{}.{}/ca'.format(i, domainName))
  keyFile = next(file for file in files if file.find(domainName) == -1)
  caService['image'] = 'registry.cn-hangzhou.aliyuncs.com/at2chain/fabric-ca:amd64-1.3.0'
  caService['restart']= 'always'
  caService['environment'] = ['FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server', 
                              'FABRIC_CA_SERVER_CA_NAME=ca-core', 
                              'FABRIC_CA_SERVER_TLS_ENABLED=true', 
                              'FABRIC_CA_SERVER_TLS_CERTFILE=/etc/hyperledger/fabric-ca-server-config/{}.{}-cert.pem'.format(caServiceName, domainName), 
                              'FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/{}'.format(keyFile)
                             ]
  port = 7054 + 1000 * (i - 1) 
  caService['ports'] = ['{}:7054'.format(port)]
  caService['command'] = 'sh -c \'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/{}.{}-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/{} -b {}:{} -d\''.format(caServiceName, domainName, keyFile, registrarUserName, registrarUserPassword)
  caService['volumes'] = [installationPkgMountVolumeRoot+'/{}:/var/hyperledger/production'.format(caServiceName), 
                          './crypto-config/peerOrganizations/org{}.{}/ca/:/etc/hyperledger/fabric-ca-server-config'.format(i, domainName)
                         ]
  caService['container_name'] = caServiceName
  caService['networks'] = [fabricNetworkName]
  services[caServiceName] = caService

#generate couchdb containers
for i in range(1, orgCount+1):
  couchdbService = OrderedDict()
  couchdbServiceName = 'couchdb.org{}'.format(i)
  couchdbService['image'] = 'registry.cn-hangzhou.aliyuncs.com/at2chain/fabric-couchdb:amd64-0.4.13'
  couchdbService['restart']= 'always'
  couchdbService['environment'] = ['COUCHDB_USER=' + couchdbUserName, 
                                   'COUCHDB_PASSWORD=' + couchdbUserPassword
                                   ]
  port = 5984 - 10 * (i - 1)                                  
  couchdbService['ports'] = ['{}:5984'.format(port)]
  couchdbService['volumes'] = [installationPkgMountVolumeRoot+'/{}:/opt/couchdb/data'.format(couchdbServiceName)]
  couchdbService['container_name'] = couchdbServiceName
  couchdbService['networks'] = [fabricNetworkName]
  services[couchdbServiceName] = couchdbService

#generate zk containers
for i in range(1, zkCount+1):
  zkService = OrderedDict()
  zkServiceName = 'zookeeper{}'.format(i)
  zkList = ['server.{}=zookeeper{}:2888:3888'.format(j, j) for j in range(1, zkCount+1)]
  envZkServersTemplate = 'ZOO_SERVERS={}'.format(' '.join(zkList))
  envZkServers = envZkServersTemplate.replace(zkServiceName, '0.0.0.0')
  zkService['image'] = 'hyperledger/fabric-zookeeper:amd64-0.4.13'
  zkService['restart']= 'always'
  zkService['environment'] = ['ZOO_DATA_DIR=/data', 
                              'ZOO_DATA_LOG_DIR=/data-log',
                              'ZOO_MY_ID={}'.format(i),
                              envZkServers
                             ]
  
  zkService['ports'] = ['2181','2888','3888']

  zkService['volumes'] = [installationPkgMountVolumeRoot+'/zk{}/data:/data'.format(i),
                          installationPkgMountVolumeRoot+'/zk{}/data-log:/data-log'.format(i)
                         ]
  zkService['container_name'] = zkServiceName
  zkService['networks'] = [fabricNetworkName]
  services[zkServiceName] = zkService

#generate kafka containers
for i in range(1, kafkaCount+1):
  kafkaService = OrderedDict()
  zkList = ['zookeeper1:2181','zookeeper2:2181','zookeeper3:2181']
  kafkaServiceName = 'kafka' + str(i)
  kafkaService['image'] = 'hyperledger/fabric-kafka:amd64-0.4.13'
  kafkaService['restart']= 'always'
  kafkaService['environment'] = ['LOG_DIR=/kafka-data', 
                              'KAFKA_MESSAGE_MAX_BYTES=103809024',
                              'KAFKA_REPLICA_FETCH_MAX_BYTES=103809024',
                              'KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false',
                              'KAFKA_DEFAULT_REPLICATION_FACTOR=3',
                              'KAFKA_MIN_INSYNC_REPLICAS=1',
                              'KAFKA_BROKER_ID={}'.format(i),
                              'KAFKA_ZOOKEEPER_CONNECT=' + ','.join(zkList)
                             ]
  kafkaService['ports'] = [9092]
  kafkaService['volumes'] = [installationPkgMountVolumeRoot+'/kafka{}-data:/kafka-data'.format(i)]
  kafkaService['container_name'] = kafkaServiceName
  kafkaService['networks'] = [fabricNetworkName]
  kafkaService['depends_on'] = ['zookeeper{}'.format(z) for z in range(1, zkCount+1)]
  services[kafkaServiceName] = kafkaService

#generate peer containers
for i in range(1, orgCount + 1):
  for j in range(0, peerCountInOrg ):
    peerService = OrderedDict()
    peerServiceName = 'peer{}.org{}.{}'.format(j, i, domainName)
    peerAddress = peerServiceName + ':7051'
    peerService['image'] = 'hyperledger/fabric-peer:1.3.0'
    peerService['restart']= 'always'
    peerService['environment'] = ['CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=fabric-artifacts_'+fabricNetworkName,
                                'CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock',
                                'CORE_LOGGING_LEVEL=INFO',
                                'CORE_PEER_TLS_ENABLED=true',
                                'CORE_PEER_GOSSIP_USELEADERELECTION=true',
                                'CORE_PEER_GOSSIP_ORGLEADER=false',
                                'CORE_PEER_PROFILE_ENABLED=true',
                                'CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt',
                                'CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key',
                                'CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt',
                                'GODEBUG=netdns=go',
                                'CORE_PEER_ID='+ peerServiceName,
                                'CORE_PEER_ADDRESS='+ peerAddress,
                                'CORE_PEER_GOSSIP_EXTERNALENDPOINT='+ peerAddress,
                                'CORE_PEER_GOSSIP_BOOTSTRAP='+ peerAddress,
                                'CORE_PEER_LOCALMSPID=Org{}MSP'.format(i),
                                'CORE_LEDGER_STATE_STATEDATABASE=CouchDB',
                                'CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb.org{}:5984'.format(i),
                                'CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=' + couchdbUserName, 
                                'CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=' + couchdbUserPassword
                               ]
    peerService['working_dir'] = '/opt/gopath/src/github.com/hyperledger/fabric/peer'
    peerService['command'] = 'peer node start'
    port1 = str(7051 + (i-1)*1000+(j-0)*100) + ':7051'
    port2 = str(7053 + (i-1)*1000+(j-0)*100) + ':7053'
    peerService['ports'] = [port1, port2]
    peerService['volumes'] = ['/var/run/:/host/var/run/',
                              installationPkgMountVolumeRoot+'/peer{}.org{}:/var/hyperledger/production'.format(j,i),
                              installationPkgFabricArtifactsRoot+'/crypto-config/peerOrganizations/org{}.{}/peers/peer{}.org{}.{}/msp:/etc/hyperledger/fabric/msp'.format(i, domainName, j, i, domainName),
                              installationPkgFabricArtifactsRoot+'/crypto-config/peerOrganizations/org{}.{}/peers/peer{}.org{}.{}/tls:/etc/hyperledger/fabric/tls'.format(i, domainName, j, i, domainName)
                             ]
    peerService['container_name'] = peerServiceName
    peerService['networks'] = [fabricNetworkName]
    peerService['depends_on'] = ['couchdb.org{}'.format(i)]
    services[peerServiceName] = peerService

ordererService = OrderedDict()
ordererServiceName = 'orderer.{}'.format(domainName)
ordererService['image'] = 'hyperledger/fabric-orderer:1.3.0'
ordererService['restart']= 'always'
ordererService['environment'] = ['ORDERER_GENERAL_LOGLEVEL=info', 
                                 'ORDERER_GENERAL_LISTENADDRESS=0.0.0.0',
                                 'ORDERER_GENERAL_GENESISMETHOD=file',
                                 'ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block',
                                 'ORDERER_GENERAL_LOCALMSPID='+ordererOrgName+'MSP',
                                 'ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp',
                                 'ORDERER_GENERAL_TLS_ENABLED=true',
                                 'ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key',
                                 'ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt',
                                 'ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]',
                                 'GODEBUG=netdns=go',
                                 'ORDERER_KAFKA_RETRY_SHORTINTERVAL=1s',
                                 'ORDERER_KAFKA_RETRY_SHORTTOTAL=30s',
                                 'ORDERER_KAFKA_VERBOSE=false'
                                 ]
ordererService['ports'] = ['7050:7050']
ordererService['volumes'] = [installationPkgMountVolumeRoot+'/orderer:/var/hyperledger/production',
                             installationPkgFabricArtifactsRoot+'/channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block',
                             installationPkgFabricArtifactsRoot+'/crypto-config/ordererOrganizations/{}/orderers/orderer.{}/msp:/var/hyperledger/orderer/msp'.format(domainName, domainName),
                             installationPkgFabricArtifactsRoot+'/crypto-config/ordererOrganizations/{}/orderers/orderer.{}/tls/:/var/hyperledger/orderer/tls'.format(domainName, domainName)
                            ]
ordererService['container_name'] = ordererServiceName
ordererService['working_dir'] = '/opt/gopath/src/github.com/hyperledger/fabric'
ordererService['command'] = 'orderer'
ordererService['networks'] = [fabricNetworkName]
ordererService['depends_on'] = ['zookeeper{}'.format(i) for i in range(1, zkCount+1)] + ['kafka' + str(j) for j in range(1, kafkaCount+1)]
services[ordererServiceName] = ordererService

cliService = OrderedDict()
cliServiceName = 'cli'
cliService['image'] = 'hyperledger/fabric-tools:1.3.0'
cliService['restart']= 'always'
cliService['environment'] = ['GOPATH=/opt/gopath', 
                             'CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock',
                             'CORE_LOGGING_LEVEL=DEBUG',
                             'CORE_PEER_ID=peer0.org1.{}'.format(domainName),
                             'CORE_PEER_ADDRESS=peer0.org1.{}:7051'.format(domainName),
                             'CORE_PEER_LOCALMSPID=Org1MSP',
                             'CORE_PEER_TLS_ENABLED=true',
                             'CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.{}/peers/peer0.org1.{}/tls/server.crt'.format(domainName, domainName),
                             'CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.{}/peers/peer0.org1.{}/tls/server.key'.format(domainName, domainName),
                             'CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.{}/peers/peer0.org1.{}/tls/ca.crt'.format(domainName, domainName),
                             'CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.{}/users/Admin@org1.{}/msp'.format(domainName, domainName),
                             'ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/{}/orderers/orderer.{}/msp/tlscacerts/tlsca.{}-cert.pem'.format(domainName, domainName, domainName),
                             'CORE_PEER_ADDRESSAUTODETECT=false',
                             'GODEBUG=netdns=go'
                             ]
cliService['tty'] = True
cliService['volumes'] = ['/var/run/:/host/var/run/',
                         installationPkgChaincodeRoot+'/chaincode-'+installationPkgChaincodeName+'/chaincode'+':/opt/gopath/src/'+installationPkgChaincodePath+'/',
                         installationPkgFabricArtifactsRoot+'/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/',
                         installationPkgShellRoot+':/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/',
                         installationPkgFabricArtifactsRoot+'/channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/'
                        ]
cliService['container_name'] = 'cli'
cliService['working_dir'] = '/opt/gopath/src/github.com/hyperledger/fabric/peer'
cliService['command'] = "/bin/bash -c '"+"./scripts/script-fragments/channel-setup.sh "+ ordererHostName+" "+domainName+" "+channelName+" ;"+"./scripts/script-fragments/peer-setup.sh "+str(orgCount)+" "+ str(peerCountInOrg)+" "+ domainName+" "+channelName+" "+ordererHostName+" ;"+"./scripts/script-fragments/chaincode-setup.sh "+str(orgCount)+" "+ str(peerCountInOrg)+" "+ domainName+" "+ installationPkgChaincodePath+" "+installationPkgChaincodeName+" "+ installationPkgChaincodeVersion+" "+ channelName+" "+endorsementPolicyPattern+" "+str(majorityPatternMin)+"'"
cliService['networks'] = [fabricNetworkName]
dependsOn = ['orderer.{}'.format(domainName)]
for i in range(1, orgCount + 1):
  for j in range(0, peerCountInOrg):
    dependsOn.append('peer{}.org{}.{}'.format(j, i, domainName))
for i in range(1, orgCount + 1):
  dependsOn.append('couchdb.org{}'.format(i))
cliService['depends_on'] = dependsOn
services[cliServiceName] = cliService

config['services'] = services;

y = yaml.dump(config, indent=4, default_flow_style=False)
print(y)


with open(installationPkgFabricArtifactsRoot+'/'+'docker-compose.yaml', 'w') as outfile:
  yaml.dump(config, outfile, Dumper=CustomDumper, width=1000, default_flow_style=False)
