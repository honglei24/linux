#!/bin/bash
for i in "$@"
do
mysql -uroot -pmygreatsecret << EOF
use cinder;
DELETE FROM cinder.iscsi_targets where volume_id='$i';
DELETE FROM cinder.volume_admin_metadata where volume_id='$i';
DELETE FROM cinder.volume_glance_metadata where volume_id='$i';
DELETE FROM cinder.volume_metadata where volume_id='$i';
DELETE FROM cinder.snapshots where volume_id='$i';
DELETE FROM cinder.volumes where id='$i';
EOF
done
echo "ok!,$# volume was deleted successfully!!"
