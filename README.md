# Docker EE Lab Setup

This is a working document being refined daily.

1. Clone this repository
2. Use vm_deploy.ps1 to deploy at least 4 VMs to your virtual environment
	Dependancies (docker-custom) oscustomization template
	Centos 7.3 docker based virtual template

3. Login to docker01 using the credentials provided
4. modify the /etc/hosts file to include the other docker guests
5. Run the following commands
	
	ssh-keygen
	
	ssh-copy-id root@<docker node name> (repeat this for each node)
	
	yum install -y wget
	
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	
#Change for the IP values in your Pod
	
	for i in <last octet>;do echo X.X.X.$i;scp epel-release-latest-7.noarch.rpm X.X.X.$i:/root;done
	
	rpm -i epel-release-latest-7.noarch.rpm
	
	yum info ansible
	
	yum install -y ansible
	
# Modify you ansible hosts file 
	
	vi /etc/ansible/hosts
		
		[Docker]
		docker02
		docker03
		docker04
		docker01
		
		[Worker]
		docker03
		docker04

		[Manager]
		docker01

		[DTR]
		docker02

	#Verify connectivity to other hosts and that ansible is working
	
	ansible Docker -m "ping"

6.  Run the playbook (ansible-playbook ansible_deploy.yml)

#Provide the required parameters

7.  Deploy UCP
	
	docker run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp install -i --host-address <IP Address of First Node "Manager">

You will then be able to login to the UCP portal with the username and password that you provided.
Additional nodes can be added through the configuration in the Management Portal.


