name="kubevpro.kavdom.site"
zones="us-east-2a,us-east-2b"
count=2
instance_type="t2.micro"
volume_size=12
pkey="~/.ssh/aws_ec2.pub"
bucket="s3://$(terraform output s3_bucket_name | tr -d '"')"

##################################
### Destroy ingress controller ###
##################################

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/aws/deploy.yaml

#########################
### Destroy resources ###
#########################

kubectl delete -f /home/ubuntu/kubevpro

#######################
### Destroy cluster ###
#######################

kops delete cluster \
    --name "kubevpro.kavdom.site" \
    --state "s3://kopstate20250109200823918600000002" \
    --yes