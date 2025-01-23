name="kubevpro.kavdom.site"
zones="us-east-2a,us-east-2b"
count=2
instance_type="t2.micro"
dns_zone=$(terraform output dns_zone | tr -d '"')
volume_size=12
pkey="~/.ssh/aws_ec2.pub"
bucket="s3://$(terraform output s3_bucket_name | tr -d '"')"

######################
### Create cluster ###
######################

kops create cluster \
    --name "kubevpro.kavdom.site" \
    --state "s3://kopstate20250109200823918600000002" \
    --zones "us-east-2a,us-east-2b" \
    --node-count 2 \
    --node-size "t3.small" \
    --control-plane-size "t3.medium" \
    --dns-zone "kubevpro.kavdom.site" \
    --node-volume-size 12 \
    --control-plane-volume-size 12 \
    --ssh-public-key "~/.ssh/id_ed25519.pub" \
    --yes


#################################
### Create ingress controller ###
#################################

sed -i -e '/proxy-real-ip-cidr/s/\(X\{3\}\.\?\)\{3\}\/XX/<insert your kubernetes VPC CIDR>/' deploy.yaml
kubectl apply -f deploy.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/aws/deploy.yaml

########################
### Create resources ###
########################

kubectl create -f /home/ubuntu/kubevpro

#kops update cluster \
#    --name $name \
#    --state $bucket \
#    --yes \
#    --admin

kops validate cluster \
    --name "kubevpro.kavdom.site" \
    --state "s3://kopstate20250109200823918600000002"