#!/bin/bash
for i in "$@"
do
mysql -uroot -pmygreatsecret << EOF
use glance;
DELETE FROM glance.image_locations where image_id='$i';
DELETE FROM glance.image_members where image_id='$i';
DELETE FROM glance.image_properties where image_id='$i';
DELETE FROM glance.image_tags where image_id='$i';
DELETE FROM glance.images where id='$i';
EOF
done
echo "ok!,$# image was deleted successfully!!"
