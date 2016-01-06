#!/bin/bash
for i in "$@"
do
mysql -uroot -pmygreatsecret << EOF
use nova;
DELETE FROM nova.virtual_interfaces where instance_uuid='$i';
DELETE FROM nova.fixed_ips where instance_uuid='$i';
DELETE FROM nova.block_device_mapping where instance_uuid='$i';
DELETE FROM nova.instance_system_metadata where instance_uuid='$i';
DELETE FROM nova.security_group_instance_association where instance_uuid='$i';
DELETE FROM nova.instance_info_caches WHERE instance_uuid='$i';
DELETE FROM nova.instance_faults WHERE instance_uuid='$i';
DELETE FROM nova.migrations WHERE instance_uuid='$i';
DELETE FROM nova.instance_metadata WHERE instance_uuid='$i';
DELETE a FROM nova.instance_actions_events AS a INNER JOIN nova.instance_actions AS b  ON a.action_id=b.id where b.instance_uuid='$1';
DELETE FROM nova.instance_actions where instance_uuid='$i';
DELETE FROM nova.instances WHERE uuid='$i';
EOF
done
echo "ok!,$# vm was deleted successfully!!"
