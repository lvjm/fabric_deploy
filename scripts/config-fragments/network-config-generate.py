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

class blockStyleLiteral(str):
    pass

def repr_str(dumper, data):
    if '\n' in data:
        return dumper.represent_scalar(u'tag:yaml.org,2002:str', data, style='|')
    return dumper.org_represent_str(data)

yaml.add_representer(blockStyleLiteral, repr_str)

parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgFabricArtifactsRoot',required=True,type=str)
parser.add_argument('--orgCount', required=True, type=int)
parser.add_argument('--peerCountInOrg', required=True, type=int)
parser.add_argument('--domainName', required=True, type=str)
parser.add_argument('--registrarUserName', required=True, type=str)
parser.add_argument('--registrarUserPassword', required=True, type=str)
parser.add_argument('--channelName', required=True, type=str)

args=parser.parse_args()
installationPkgFabricArtifactsRoot = args.installationPkgFabricArtifactsRoot
orgCount = args.orgCount
peerCountInOrg = args.peerCountInOrg
domainName = args.domainName
registrarUserName = args.registrarUserName
registrarUserPassword = args.registrarUserPassword
channelName = args.channelName
cryptoconfig = args.installationPkgFabricArtifactsRoot+'/'+'crypto-config'


config = OrderedDict()
config['name'] = 'at2chain'
config['x-type'] = 'hlfv1'
config['x-loggingLevel'] = 'info'
config['description'] = 'the environment for {}'.format(config['name'] )
config['version'] = '1.0.0'

client = OrderedDict()
client['organization'] = 'Org1'
client['logging'] = OrderedDict({'level' : 'info'})
client['peer'] = OrderedDict({'timeout' : {'connection': '3s', 'queryResponse':'45s', 'executeTxResponse':'30s'}})
client['eventService'] = OrderedDict({'timeout':{'connection':'3s', 'registrationResponse':'3s'}})
client['orderer'] = OrderedDict({'timeout':{'connection':'3s', 'response':'5s'}})
client['cryptoconfig'] = {'path':cryptoconfig}
client['credentialStore'] = OrderedDict({'path' : '/tmp/hfc-kvs', 'cryptoStore':{'path':'/tmp/msp'}, 'wallet':'wallet-name'})
client['BCCSP'] = OrderedDict({'security' : {'enabled':True, 'default':{'provider': 'SW'}, 'hashAlgorithm':'SHA2', 'softVerify':True, 'ephemeral':False, 'level':'256'}})
client['tlsCerts'] = {'systemCertPool': False}
config['client'] = client

peersInChannel = OrderedDict()
for i in range(1, orgCount + 1):
  for j in range(0, peerCountInOrg):
  	peersInChannel['peer{}.org{}.{}'.format(j, i, domainName)] = OrderedDict({'endorsingPeer' : True, 'chaincodeQuery' : True, 'ledgerQuery': True, 'eventSource':True})

channels = OrderedDict({channelName: {'orderers': ['orderer.{}'.format(domainName)], 'peers': peersInChannel}})
config['channels'] = channels

organizations = OrderedDict()
for i in range(1, orgCount + 1):
	org = OrderedDict()
	org['mspid'] = 'Org{}MSP'.format(i)
	orgDomain = 'org{}.{}'.format(i, domainName)
	org['cryptoPath'] = '{}/peerOrganizations/{}/users/Admin@{}/msp'.format(cryptoconfig, orgDomain, orgDomain)
	org['peers'] = ['peer{}.org{}.{}'.format(j, i, domainName) for j in range(0, peerCountInOrg)]
	org['certificateAuthorities'] = ['ca.org{}'.format(i)]
	privateKeyDir = '{}/peerOrganizations/{}/users/Admin@{}/msp/keystore/'.format(cryptoconfig, orgDomain, orgDomain)
	signedCertFile = '{}/peerOrganizations/{}/users/Admin@{}/msp/signcerts/Admin@{}-cert.pem'.format(cryptoconfig,orgDomain, orgDomain, orgDomain)
	files = os.listdir(privateKeyDir)
	privateKey = open(privateKeyDir + files[0], 'r').read()
	signedCert = open(signedCertFile, 'r').read()
	org['adminPrivateKey'] = {'pem' : blockStyleLiteral(privateKey)}
	org['signedCert'] = {'pem' : blockStyleLiteral(signedCert)}
	organizations['Org{}'.format(i)] = org
organizations['ordererorg'] = OrderedDict({'mspID':'OrdererMSP', 'cryptoPath':'{}/ordererOrganizations/{}/users/Admin@{}/msp'.format(cryptoconfig, domainName, domainName)})
config['organizations'] = organizations

orderers = OrderedDict();
ordererDomain = 'orderer.{}'.format(domainName)
caCertFile = '{}/ordererOrganizations/{}/tlsca/tlsca.{}-cert.pem'.format(cryptoconfig, domainName, domainName)
caCert = open(caCertFile, 'r').read()
orderers[ordererDomain] = OrderedDict({'url': 'grpcs://{}:7050'.format(ordererDomain), 'grpcOptions':{'sslProvider':'openSSL', 'negotiationType':'TLS', 'hostnameOverride':ordererDomain, 'grpc-max-send-message-length':15}, 'tlsCACerts':{'pem': blockStyleLiteral(caCert)}});
config['orderers'] = orderers

peers = OrderedDict();
for i in range(1, orgCount + 1):
  for j in range(0, peerCountInOrg):
        port=str(7051 + (i-1)*1000+(j-0)*100)
  	peerDomain = 'peer{}.org{}.{}'.format(j, i, domainName)
  	tlsCACertFile = '{}/peerOrganizations/org{}.{}/tlsca/tlsca.org{}.{}-cert.pem'.format(cryptoconfig,i,domainName, i, domainName)
  	tlsCACert = open(tlsCACertFile, 'r').read()
  	peers[peerDomain] = OrderedDict({'url' : 'grpcs://{}:{}'.format(peerDomain,port), 'grpcOptions':{'grpc.http2.keepalive_time':15, 'negotiationType':'TLS', 'hostnameOverride':peerDomain, 'sslProvider':'openSSL'}, 'tlsCACerts':{'pem': blockStyleLiteral(tlsCACert)}})
config['peers'] = peers

certificateAuthorities = OrderedDict();
for i in range(1, orgCount + 1):
  for j in range(0, peerCountInOrg):
        port= 7054 + 1000 * (i - 1)
	#caName = 'ca-org{}'.format(i)
	caName = 'ca.org{}'.format(i)
        ca = OrderedDict();
	ca['url'] = 'https://{}.{}:{}'.format(caName, domainName, port)
	ca['httpOptions'] = {'verify': True}
	tlsCACertFile = '{}/peerOrganizations/org{}.{}/ca/{}.{}-cert.pem'.format(cryptoconfig,i, domainName, caName, domainName)
	tlsCACert = open(tlsCACertFile, 'r').read()
        certFile = '{}/peerOrganizations/org{}.{}/peers/peer{}.org{}.{}/msp/cacerts/ca.org{}.{}-cert.pem'.format(cryptoconfig,i, domainName,j,i,domainName,i,domainName)
        keyFileDir = '{}/peerOrganizations/org{}.{}/peers/peer{}.org{}.{}/msp/keystore/'.format(cryptoconfig,i, domainName,j,i,domainName)
	files = os.listdir(privateKeyDir)
        keyFile = keyFileDir + files[0]
        ca['tlsCACerts'] = OrderedDict({'pem': blockStyleLiteral(tlsCACert),'client':{'keyfile':keyFile,'certfile':certFile}})
	ca['registrar'] = OrderedDict({'enrollId': registrarUserName, 'enrollSecret': registrarUserPassword})
	ca['caName'] = 'ca-core'
	certificateAuthorities[caName] = ca
config['certificateAuthorities'] = certificateAuthorities	


with open(installationPkgFabricArtifactsRoot+'/'+'network-config.yaml', 'w') as outfile:
	yaml.dump(config, outfile, Dumper=CustomDumper, width=1000, default_flow_style=False)
