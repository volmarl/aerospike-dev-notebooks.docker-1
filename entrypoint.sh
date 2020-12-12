#!/bin/bash
set -m

export CORES=$(grep -c ^processor /proc/cpuinfo)
export SERVICE_THREADS=${SERVICE_THREADS:-$CORES}
export TRANSACTION_QUEUES=${TRANSACTION_QUEUES:-$CORES}
export TRANSACTION_THREADS_PER_QUEUE=${TRANSACTION_THREADS_PER_QUEUE:-4}
export LOGFILE=${LOGFILE:-/dev/null}
export SERVICE_ADDRESS=${SERVICE_ADDRESS:-any}
export SERVICE_PORT=${SERVICE_PORT:-3000}
export HB_ADDRESS=${HB_ADDRESS:-any}
export HB_PORT=${HB_PORT:-3002}
export FABRIC_ADDRESS=${FABRIC_ADDRESS:-any}
export FABRIC_PORT=${FABRIC_PORT:-3001}
export INFO_ADDRESS=${INFO_ADDRESS:-any}
export INFO_PORT=${INFO_PORT:-3003}
export NAMESPACE=${NAMESPACE:-test}
export REPL_FACTOR=${REPL_FACTOR:-2}
export MEM_GB=${MEM_GB:-1}
export DEFAULT_TTL=${DEFAULT_TTL:-30d}
export STORAGE_GB=${STORAGE_GB:-4}
export NSUP_PERIOD=${NSUP_PERIOD:-120}
export USER=${USER:-jovyan}
export MEMORY_SIZE=${MEMORY_SIZE:-128}
export INDEX_STAGE_SIZE=${INDEX_STAGE_SIZE:-128}

# Fill out conffile with above values
if [ -f /etc/aerospike/aerospike.template.conf ]; then
        envsubst < /etc/aerospike/aerospike.template.conf > /etc/aerospike/aerospike.conf
fi

echo "starting aerospike"
#service aerospike restart
/etc/init.d/aerospike restart 2>&1 >> /var/log/aerospike/start-up.log
echo $?

#####
# Jupiter stuff
#####

wrapper=""
if [[ "${RESTARTABLE}" == "yes" ]]; then
  wrapper="run-one-constantly"
fi

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  exec /usr/local/bin/start-singleuser.sh "$@"
elif [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
  . /usr/local/bin/start.sh $wrapper jupyter lab "$@"
else
  . /usr/local/bin/start.sh $wrapper jupyter notebook "$@"
fi
