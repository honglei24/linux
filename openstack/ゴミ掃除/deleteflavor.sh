#!/bin/bash
for i in "$@"
do
mysql -uroot -pmygreatsecret << EOF
use nova;
DELETE FROM nova.instance_types where flavorid='$i';
EOF
done
echo "ok!,$# flavor was deleted successfully!!"
