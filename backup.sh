#!/bin/sh

finish() {
  curl -sf -XPOST http://127.0.0.1:15020/quitquitquit || true
}
trap finish EXIT

if [ -z "$ZOOKEEPER_URL" ]; then
  echo "Environment variable ZOOKEEPER_URL is required."
  exit 1
fi

if [ -z "$BACKUP_LOCATION" ]; then
  echo "Environment variable BACKUP_LOCATION is required."
  exit 1
fi

if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "Environment variable GOOGLE_APPLICATION_CREDENTIALS is required."
  exit 1
fi

BOTO_CONFIG_PATH=${BOTO_CONFIG_PATH:-/root/.boto}
cat <<EOF > $BOTO_CONFIG_PATH
[Credentials]
gs_service_key_file = $GOOGLE_APPLICATION_CREDENTIALS
[Boto]
https_validate_certificates = True
[GoogleCompute]
[GSUtil]
content_language = en
default_api_version = 2
[OAuth2]
EOF

sleep 15
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
month=$(date +%Y-%m)
mkdir -p "/data/zookeeper/zookeeper${timestamp}"
cd /data/zookeeper

java $JAVA_OPTIONS -jar /opt/guano/guano-0.1.0.jar -v -s "$ZOOKEEPER_URL" -o "/data/zookeeper/zookeeper${timestamp}" -d "/" || exit 2
tar cfz "zookeeper${timestamp}.tar.gz" "zookeeper${timestamp}" || exit 2
gsutil cp "/data/zookeeper/zookeeper${timestamp}.tar.gz" "$BACKUP_LOCATION/$month/zookeeper${timestamp}.tar.gz" || exit 2

rm -rf  "/data/zookeeper/zookeeper${timestamp}" "/data/zookeeper/zookeeper${timestamp}.tar.gz" || exit 0
