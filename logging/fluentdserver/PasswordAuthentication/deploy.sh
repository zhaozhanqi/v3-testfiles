curl -O https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/logging/fluentdserver/PasswordAuthentication/fluentdserver_configmap.yaml
curl -O https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/logging/fluentdserver/PasswordAuthentication/fluentdserver_deployment.yaml
curl -O https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/logging/fluentdserver/PasswordAuthentication/fluentdserver_configmap.yaml
oc create sa fluentdserver
oc adm policy add-scc-to-user  privileged system:serviceaccount:openshift-logging:fluentdserver
oc create -f fluentdserver_configmap.yaml
oc create -f fluentdserver_deployment.yaml
oc expose deployment/fluentdserver2
serviceip1=$(oc get service fluentdserver2 -o jsonpath={.spec.clusterIP})
#Add secret and update the configmap
sed -i "s/192.168.1.2/${serviceip1}/" fluentd_configmap_patch.yaml
oc patch configmap/fluentd  --patch "$(cat fluentd_configmap_patch.yaml)"
oc delete pods -l logging-infra=fluentd
