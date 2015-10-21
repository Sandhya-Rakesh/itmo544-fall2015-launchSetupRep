#!/bin/bash
# This program takes 6 arguments in the following order
# $1 - ami image-id
# $2 - count
# $3 - instance-type
# $4 - security-group-ids
# $5 - subnet-id
# $6 - key-name

aws ec2 run-instances --image-id $1 --count $2 --instance-type $3 --key-name $6 --security-group-ids $4 --subnet-id $5 --associate-public-ip-address --user-data file://../itmo544-fall2015-environmentRep/install-env.sh --debug
