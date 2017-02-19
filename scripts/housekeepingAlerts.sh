#!/bin/sh
/usr/bin/mongo --host db --quiet monitoring /scripts/housekeepingAlerts.js
sleep ${HOUSEKEEPINGALERTS_TIMER:-60}
