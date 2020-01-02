#!/bin/bash

[ $# -eq 1 ] || { echo "Missing parameters, need one payload. Exiting..."; exit 1 ;}
OPENSHIFT_PAYLOAD_IMAGE=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
oc adm release extract --command openshift-install --from ${OPENSHIFT_PAYLOAD_IMAGE}
if [ -d ${DIR}/ocp4 ] 
then 
  rm -fr ocp4;
fi
mkdir ${DIR}/ocp4;
cd ocp4;
export OPENSHIFT_PAYLOAD_IMAGE=${OPENSHIFT_PAYLOAD_IMAGE}
cp ${DIR}/config/install-config.yaml .
../openshift-install create ignition-configs && cp bootstrap.ign worker.ign master.ign /var/www/html/rhcos/ignitions/ && cp bootstrap.ign worker.ign master.ign /var/lib/tftpboot/rhcos/ignitions/

#make the server as bootstrap server firstly
/usr/bin/cp /var/lib/tftpboot/pxelinux.cfg/bootstrap /var/lib/tftpboot/pxelinux.cfg/01-e4-43-4b-5b-6c-29
# reboot all server with pxeboot
${DIR}/script/reboot.sh all

../openshift-install wait-for bootstrap-complete
if [ $? -ne 0 ] ; then
        echo "ERROR: Bootstrap not completed" && exit 1
fi

# After the bootstrap is finished. Bring the server as worker
/usr/bin/cp /var/lib/tftpboot/pxelinux.cfg/rhel /var/lib/tftpboot/pxelinux.cfg/01-e4-43-4b-5b-6c-29

# After the bootstrap is finished. Bring the server as worker
${DIR}/script/reboot.sh 14
