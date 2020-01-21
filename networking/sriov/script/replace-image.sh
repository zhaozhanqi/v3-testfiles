oc get csv -o yaml > old-csv.yaml
oc get is 4.3-art-latest -o yaml --config=/root/cikubeconfig | grep sriov | grep name: > new-image.yaml
grep -i sriov new-image.yaml
result=$?
if [ $result -ne 0 ]; then
  echo " CANNOT get the sriov image"
  exit 1
fi
for i in ose-sriov-cni ose-sriov-dp-admission-controller ose-sriov-network-config-daemon ose-sriov-network-device-plugin ose-sriov-network-operator ose-sriov-network-webhook
do
  dest=`cat new-image.yaml | grep -o "name: .*${i}" | sed 's/name: \(.*\)/\1/' | head -1`
  if [ ${i} != "ose-sriov-network-operator" ]; then
     origin=`cat old-csv.yaml | grep -o "value:.*${i}.*" | sed 's/value: \(.*\)/\1/' | head -1`
  else
     origin=`cat old-csv.yaml | grep -o "image:.*${i}.*" | sed 's/image: \(.*\)/\1/' | head -1`
  fi
  sed -i "s#$origin#$dest#g" old-csv.yaml
done

oc create -f old-csv.yaml
