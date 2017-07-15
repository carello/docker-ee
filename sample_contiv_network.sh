#!/bin/bash

netctl global set --arp-mode flood --fwd-mode bridge --fabric-mode aci --vlan-range "1201-1400"
netctl global info


read -p "Press any key to continue... " -n1 -s

# Create our Tenant

netctl tenant create Skunkworks

netctl external-contracts create --tenant Skunkworks -p --contract "uni/tn-common/brc-default" vmHTTPprovide
netctl external-contracts create --tenant Skunkworks -p --contract "uni/tn-common/brc-default" vmHTTPconsume

netctl net create -t Skunkworks -e vlan -p 1201 -s 10.87.88.32/27 -g 10.87.88.33 --tag 292network1 292net1

netctl policy create -t Skunkworks app2db

netctl group create -t Skunkworks -e vmHTTPprovide -e vmHTTPconsume --tag 292app 292net1 app

netctl group create -t Skunkworks -p app2db --tag 292db 292net1 db

netctl app-profile create -t Skunkworks -g app,db Skunkworks-profile






