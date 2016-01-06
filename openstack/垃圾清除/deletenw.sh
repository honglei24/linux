#!/bin/bash
for i in "$@"
do
mysql -uroot -pmygreatsecret << EOF
use neutron;
DELETE FROM neutron.networkdhcpagentbindings where network_id='$i';
DELETE FROM neutron.ports where network_id='$i';
DELETE FROM neutron.subnets where network_id='$i';
DELETE FROM neutron.networks where id='$i';
EOF
done
echo "ok!,$# network was deleted successfully!!"
