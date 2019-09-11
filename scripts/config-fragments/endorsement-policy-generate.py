#!/usr/bin/python

##################################################################################################################################################

#Script Description: 

##################################################################################################################################################

import argparse


parser = argparse.ArgumentParser()
parser.add_argument('--endorsementPolicyPattern', required=True, type=str)
parser.add_argument('--orgCount', required=True, type=int)
parser.add_argument('--majorityPatternMin', required=True, type=int)
args=parser.parse_args()


endorsementPolicyPattern  =  args.endorsementPolicyPattern
orgCount           = args.orgCount
majorityPatternMin  = args.majorityPatternMin

Orgs=[]

# ALL
if endorsementPolicyPattern == 'ALL':
   for i in range(1,orgCount + 1):
       org = 'Org'+str(i)+'MSP.member'
       Orgs.append("'"+org+"'")
   OrgsStr = ",".join(Orgs)
   endorsementPolicyPatternStr = 'AND('+OrgsStr+')'


# ANY
if endorsementPolicyPattern == 'ANY':
   for i in range(1,orgCount + 1):
       org = 'Org' +str(i)+'MSP.member'
       Orgs.append("'"+org+"'")
   OrgsStr = ",".join(Orgs)
   endorsementPolicyPatternStr = 'OR('+OrgsStr+')'

# MAJORITY
if endorsementPolicyPattern == 'MAJORITY':
   for i in range(1,orgCount + 1):
       org = 'Org'+str(i)+'MSP.member'
       Orgs.append("'"+org+"'")
   OrgsStr = ",".join(Orgs)
   endorsementPolicyPatternStr = 'OutOf('+ str(majorityPatternMin) + ',' + OrgsStr +')'

print endorsementPolicyPatternStr
