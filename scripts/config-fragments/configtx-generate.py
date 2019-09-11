#!/usr/bin/python

##################################################################################################################################################

#Script Description: 

##################################################################################################################################################

import yaml
import os
import argparse
from collections import OrderedDict

class CustomDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(CustomDumper, self).increase_indent(flow, False)

def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')

yaml.add_representer(type(None), represent_none)

def setup_yaml():
  represent_dict_order = lambda self, data:  self.represent_mapping('tag:yaml.org,2002:map', data.items())
  yaml.add_representer(OrderedDict, represent_dict_order)
setup_yaml()

configtx = OrderedDict()

parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgFabricArtifactsRoot', required=True, type=str)
parser.add_argument('--orgCount', required=True, type=int)
parser.add_argument('--kafkaCount', required=True, type=int)
parser.add_argument('--ordererOrgName', required=True, type=str)
parser.add_argument('--domainName', required=True, type=str)
parser.add_argument('--profilePrefixName', required=True, type=str)
parser.add_argument('--consortiumName', required=True, type=str)
args=parser.parse_args()

installationPkgFabricArtifactsRoot  =  args.installationPkgFabricArtifactsRoot
orgCount           = args.orgCount
kafkaCount         = args.kafkaCount
ordererOrgName     = args.ordererOrgName
domainName         = args.domainName
profilePrefixName  = args.profilePrefixName
consortiumName     = args.consortiumName


OrdererOrg =OrderedDict({
								  	'Name': ordererOrgName + 'Org',
								  	'ID': ordererOrgName + 'MSP',
								  	'MSPDir': 'crypto-config/ordererOrganizations/'+ domainName+'/msp'})

organizations = [OrdererOrg]
orgs = []
for i in range (1, orgCount+1):
   org = {
                      'Name': 'Org{}MSP'.format(i), 
                      'ID': 'Org{}MSP'.format(i), 
                      'MSPDir': 'crypto-config/peerOrganizations/org{}.{}/msp'.format(i, domainName),
                      'AnchorPeers': [OrderedDict({'Host': 'peer0.org{}.{}'.format(i,domainName),'port': 7051})]}
   orgs.append(org)

configtx['Organizations'] = organizations + orgs


#Orderer
orderer = OrderedDict()
kafkas = {}
kafkas['Brokers'] = ['kafka{}:9092'.format(i) for i in range(1 , kafkaCount + 1)]
orderer = {
	'OrdererType': 'kafka',
	'Addresses': 'orderer.' + domainName + ':7050',
    'BatchTimeout': '2s',
    'BatchSize': {
 	                    'MaxMessageCount': 10,
                        'AbsoluteMaxBytes': '99 MB',
                        'PreferredMaxBytes': '512 KB'
                 },
    'Kafka': kafkas,

    'Organizations': None
}

configtx['Orderer'] = orderer

#Application
application = OrderedDict()
application['Organizations']= None

configtx['Application'] = application

#profiles
profiles = OrderedDict()
OrdererGenesis = OrderedDict()
profileKafkas = {}
profileKafkas = {}
profileKafkas['Brokers'] = ['kafka{}:9092'.format(i) for i in range(1 , kafkaCount + 1)]


OrdererOrg =[{
                                                                        'Name': ordererOrgName + 'Org',
                                                                        'ID': ordererOrgName + 'MSP',
                                                                        'MSPDir': 'crypto-config/ordererOrganizations/'+ domainName+'/msp'}]
OrdererGenesis['Orderer'] = {
	'OrdererType': 'kafka',
	'Addresses': 'orderer.'+ domainName +':7050',
    'BatchTimeout': '2s',
    'BatchSize': {
 	                    'MaxMessageCount': 10,
                        'AbsoluteMaxBytes': '99 MB',
                        'PreferredMaxBytes': '512 KB',
                 }, 
    'Kafka': profileKafkas,
    'Organizations': OrdererOrg
}
    

organizationsGenesis = []
for i in range(1,orgCount + 1):
    org = {
                'Name': 'Org'+str(i)+'MSP',
                                'ID': 'Org'+str(i)+'MSP',
                    'MSPDir': 'crypto-config/peerOrganizations/org'+str(i)+'.'+domainName +'/msp',
                    'AnchorPeers': [OrderedDict({'Host': 'peer0.org{}.{}'.format(i,domainName),'port': 7051})]
       }
    organizationsGenesis.append(org)


Consortiums = OrderedDict()
SaservicesmpleConsortium = OrderedDict()
SaservicesmpleConsortium['Organizations'] = organizationsGenesis
OrdererGenesis['Consortiums'] =  Consortiums
Consortiums[profilePrefixName+'Consortium'] = SaservicesmpleConsortium
profiles[profilePrefixName+'OrdererGenesis'] = OrdererGenesis


organizationsChannel = []
for i in range(1,orgCount + 1):
	org ={
                'Name': 'Org'+str(i)+'MSP',
                                'ID': 'Org'+str(i)+'MSP',
                    'MSPDir': 'crypto-config/peerOrganizations/org'+str(i)+'.'+domainName +'/msp',
                    'AnchorPeers': [OrderedDict({'Host': 'peer0.org{}.{}'.format(i,domainName),'port': 7051})]
        }
	organizationsChannel.append(org)


Channel = OrderedDict()
Channel['Consortium'] = profilePrefixName+'Consortium'
Channel['Application'] = {'Organizations': organizationsChannel}
profiles[profilePrefixName+'Channel'] = Channel
configtx['Profiles'] = profiles

y = yaml.dump(configtx, indent=4, default_flow_style=False)
print(y)

with open(installationPkgFabricArtifactsRoot+'/'+'configtx.yaml', 'w') as outfile:
  yaml.dump(configtx, outfile, Dumper=CustomDumper, width=1000, default_flow_style=False)

