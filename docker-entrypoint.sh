#!/bin/sh

set -ex


# Generate web console config, if not supplied
if [ ! -f "$ALERTA_WEB_CONF_FILE" ]; then
  cat >$ALERTA_WEB_CONF_FILE << EOF
'use strict';

angular.module('config', [])
  .constant('config', {
    'endpoint'    : "${BASE_URL:-/api}",
    'provider'    : "${PROVIDER}",
    'client_id'   : "${CLIENT_ID}",
    'colors'      : {}
  });
EOF
fi

# Generate server config, if not supplied
if [ ! -f "$ALERTA_SVR_CONF_FILE" ]; then
  cat >$ALERTA_SVR_CONF_FILE << EOF
DEBUG = ${DEBUG:-False}
BASE_URL = '${BASE_URL:-/api}'
SECRET_KEY = "${SECRET_KEY:-$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)}"
OAUTH2_CLIENT_ID = '${CLIENT_ID}'
OAUTH2_CLIENT_SECRET = '${CLIENT_SECRET}'
API_KEY_EXPIRE_DAYS = ${API_KEY_EXPIRE_DAYS:-365}
ADMIN_USERS=[${ADMIN_USERS}]
EOF
fi

# Install plugins
echo -n "${PLUGINS:-reject}" | sed "s/,/\n/g;s/\[//g;s/\]//g;s/\'//g" | grep -v reject | while read plugin
do
  pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/$plugin
done

exec "$@"
