# Purpose

This is the project in order to learn Kubernetes using kops.

# What is creating

The project is creats an EC2 instance in order to run kops command. The kubernetes files is downloads from [here](https://github.com/kavgh/kubevpro)
The kops creates 1 master node and 2 worker nodes, Route53 DNS entries, Application LoadBalancer, and EBS.

# Issues

Unfortunately the Route53 service creates with wrong IP address and we need to change the entries manually. When I find time I will make it done automatically.
