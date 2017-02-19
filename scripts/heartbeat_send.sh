#!/bin/sh
# Generate API key for admin

if [ -z '${ALERTA_API_KEY}' ]; then
    exit 1
fi
/usr/bin/alerta heartbeats --tag $TAG --timeout $((HEARTBEAT_TIMER*2))
sleep ${HEARTBEAT_TIMER:-60}
