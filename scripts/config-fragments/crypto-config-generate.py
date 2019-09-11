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

def setup_yaml():
  represent_dict_order = lambda self, data:  self.represent_mapping('tag:yaml.org,2002:map', data.items())
  yaml.add_representer(OrderedDict, represent_dict_order)
setup_yaml()

crypto = OrderedDict()

parser = argparse.ArgumentParser()
parser.add_argument('--installationPkgFabricArtifactsRoot', required=True, type=str)
parser.add_argument('--orgCount', required=True, type=int)
parser.add_argument('--peerCountInOrg', required=True, type=int)
parser.add_argument('--defaultNormalUserCountInOrg',required=True, type=int)
parser.add_argument('--ordererOrgName', required=True, type=str)
parser.add_argument('--ordererHostName', required=True, type=str)
parser.add_argument('--domainName', required=True, type=str)
args=parser.parse_args()

installationPkgFabricArtifactsRoot = args.installationPkgFabricArtifactsRoot
orgCount = args.orgCount
peerCountInOrg = args.peerCountInOrg
defaultNormalUserCountInOrg = args.defaultNormalUserCountInOrg
ordererOrgName = args.ordererOrgName
ordererHostName = args.ordererHostName
domainName = args.domainName

#orderer
OrdererOrgs=OrderedDict()
Specs=OrderedDict()
OrdererOrgs['Name'] = ordererOrgName
OrdererOrgs['Domain'] = domainName
Specs['Hostname'] =   ordererHostName + '.' + domainName
Specs['CommonName'] = ordererHostName + '.' + domainName
OrdererOrgs['Specs'] = [Specs]
crypto['OrdererOrgs'] = [OrdererOrgs]

#peer
PeerOrgs = OrderedDict()
orgs = []
for i in range(1,orgCount + 1):
	Org = {
		'Name': 'Org'+str(i),
		'Domain': 'org' + str(i) + '.'+ domainName,
		'Template': {'Count': peerCountInOrg},
		'Users':{'Count' : defaultNormalUserCountInOrg }
	}
	orgs.append(Org)
crypto['PeerOrgs'] = orgs

y = yaml.dump(crypto, indent=4, default_flow_style=False)
print(y)

with open(installationPkgFabricArtifactsRoot+'/'+'crypto-config.yaml', 'w') as outfile:
  yaml.dump(crypto, outfile, Dumper=CustomDumper, width=1000, default_flow_style=False)
