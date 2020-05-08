#!/bin/bash

# Generate a new wallet if the one specified in docker-compose.yml doesn't exist.
if [[ ! -f ${PRIVATE_KEY_FULLPATH} ]];
then
    tbears keystore -p ${PRIVATE_PASSWORD} ${PRIVATE_KEY_FULLPATH}
fi

# Generate configs for tbears, if they don't exist
if [[ ! -f ${CONF_PATH}/tbears_cli_config.json ]] || [[ ! -f ${CONF_PATH}/tbears_server_config.json ]];
then
    (cd ${CONF_PATH} && tbears genconf)
fi

# Check if there's blockchain and stuff
if [[ ! -d ${DEFAULT_PATH}/.score_data ]] && [[ ! -d ${DEFAULT_PATH}/.storage ]];
then
    echo "No blockchain was found. Executing order 69: downloading blockchain snapshot"
    bash ./restore-snapshot.sh
fi

exec supervisord -n