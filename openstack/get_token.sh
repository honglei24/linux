IPv4="192.168.0.1"
PORT=35357
USER="admin"
PASSWARD="admin"
cat >get_unscope_token <<EOF
curl -s -i   -H "Content-Type: application/json"   -d '
{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "domain": {"id":"default"},
                    "name": "${USER}",
                    "password": "${PASSWARD}"
                }
            }
        }
    }
}' http://${IPv4}:${PORT}/v3/auth/tokens | grep X-Subject-Token
EOF

TOKEN1="$(sh get_unscope_token | cut -d" " -f 2)"

cat >get_scope_token <<EOF
curl -s -i \
  -H "Content-Type: application/json" \
  -d '
{
  "auth": {
    "identity": {
      "methods": [
        "token"
      ],
      "token": {
        "id": "${TOKEN1}"
      }
    },
    "scope": {
      "project": {
        "name": "admin",
        "domain": {
          "name": "default"
        }
      }
    }
  }
}' \
  http://${IPv4}:${PORT}/v3/auth/tokens | grep X-Subject-Token
EOF
sed -i 's///g' get_scope_token
 TOKEN2=$(sh get_scope_token | awk '{print $2}')
rm -rf get_scope_token get_unscope_token
 echo ${TOKEN2}
