#!/bin/sh
# Generate API key for admin

if [ -z '${ALERTA_API_KEY}' ]; then
    KEY='${ALERTA_API_KEY:-$(openssl rand -base64 32 | cut -c1-40)'}
    ADMIN_USER=$(echo $ADMIN_USERS | cut -d, -f1)
    EXPIRE_TIME='${EXPIRE_TIME:-$(date -u +"%Y-%m-%dT%H:%M:%S.000Z" -d +1year)}'
    MONGO_ADDR=$(echo $MONGO_URI | sed -e 's/mongodb:\/\///')
    /usr/bin/mongo --host ${MONGO_ADDR} --eval "db.keys.insert( \
        { \
            user:\"${ADMIN_USER:-internal}\", \
            key:\"${KEY}\", \
            type:\"read-write\", \
            text:\"cron jobs\", \
            expireTime: new Date(\"$EXPIRE_TIME\"), \
            count:0, \
            lastUsedTime: null \
        })"
fi
/usr/bin/alerta heartbeats --alert
sleep ${HEARTBEAT_TIMER:-60}
