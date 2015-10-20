#!/bin/bash
# This program takes 6 arguments in the following order
# $1 - ami image-id
# $2 - count
# $3 - instance-type
# $4 - security-group-ids
# $5 - subnet-id
# $6 - key-name
# $7 - iam-profile


./cleanup.sh

declare -a EC2INSTANCELIST
EC2INSTANCELIST=(`aws ec2 run-instances --image-id $1 --count $2 --instance-type $3 --key-name $6 --security-group-ids $4 --subnet-id $5 --associate-public-ip-address --user-data file://../itmo544-fall2015-environmentRep/install-webserver.sh --iam-instance-profile Name=$7 --debug`)
echo ${EC2INSTANCELIST[@]}

aws ec2 wait instance-running --instance-ids ${EC2INSTANCELIST[@]}
echo "Instances are running"
echo "\n"

#ElasticLoadBalancer
ELBURL=(`aws elb create-load-balancer --load-balancer-name itmo544Elb --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets $5 --security-groups $4`)
echo "Finished launching elastic load balancer : $ELBURL and sleeping for 25 seconds"
for i in {0..25}; do
	echo -ne '.';
	sleep 1;
done
echo "\n"

aws elb register-instances-with-load-balancer --load-balancer-name itmo544Elb --instances ${EC2INSTANCELIST[@]}

aws elb configure-health-check --load-balancer-name itmo544Elb --health-check Target=HTTP:80/png,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

echo "Waiting for 3 minutes(180 seconds) before opening ELB in web browser"
for i in {0..25}; do
	echo -ne '.';
	sleep 1;
done
echo "\n"
