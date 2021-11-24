#!/usr/bin/env bash
jkopt1="--sessionTimeout=1440"
jkopt2="--sessionEviction=86400"
jvopt1="-Duser.timezone=Asia/Seoul"

helm install jenkins jenkins/jenkins \
--set persistence.existingClaim=false \
--set controller.adminPassword=admin \
--set controller.runAsUser=1000 \
--set controller.runAsGroup=1000 \
--set controller.serviceType=NodePort \
--set controller.servicePort=80 \
--set controller.jenkinsOpts="$jkopt1 $jkopt2" \
--set controller.javaOpts="$jvopt1" \
-f jenkins-values.yaml

# Create a ServiceAccount named `jenkins-robot` in a given namespace.
kubectl -n 'sock-shop' create serviceaccount jenkins-robot
# The next line gives `jenkins-robot` administator permissions for this namespace.
# * You can make it an admin over all namespaces by creating a `ClusterRoleBinding` instead of a `RoleBinding`.
# * You can also give it different permissions by binding it to a different `(Cluster)Role`.
kubectl -n 'sock-shop' create rolebinding jenkins-robot-binding --clusterrole=cluster-admin --serviceaccount='sock-shop':jenkins-robot

kubectl port-forward --address 0.0.0.0 svc/jenkins 8080:80 &