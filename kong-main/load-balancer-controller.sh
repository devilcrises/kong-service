#!/bin/bash
eksctl utils associate-iam-oidc-provider \
    --region $AWS_REGION \
    --cluster $preprod_eks
    --approve

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

eksctl create iamserviceaccount \
    --cluster=$preprod_eks \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::579480199555:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region $AWS_REGION \
    --approve

helm repo add eks https://aws.github.io/eks-charts

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --namespace kube-system \
    --set clusterName=$preprod_eks \
    --set vpcId=$VPC_ID \
    --set region=$AWS_REGION \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

sleep 70
