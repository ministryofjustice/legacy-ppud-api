#!/bin/bash
set -euo pipefail

# This creates a port-forward to the HMPPS Cloud hosted SQL Server PPUD replica

function usage {
  echo "
./$(basename $0) [option]

Options:
    -h --> show usage
    -e --> environment (REQUIRED) - allowed values: 'dev' or 'preprod'
  "
}

function check_dep {
  if ! command -v "${1}" &>/dev/null; then
    echo "You need '${1}' - '${2}'"
    exit 1
  fi
}

# Check dependencies
check_dep "jq" "brew install jq"
check_dep "kubectl" "asdf install kubectl 1.19.16"

# get cli options
while getopts :e:h opt; do
  case ${opt} in
  e) ENV=${OPTARG} ;;
  h)
    usage
    exit
    ;;
  \?)
    echo "Unknown option: -${OPTARG}" >&2
    exit 1
    ;;
  :)
    echo "Missing option argument for -${OPTARG}" >&2
    exit 1
    ;;
  *)
    echo "Unimplemented option: -${OPTARG}" >&2
    exit 1
    ;;
  esac
done

# check for the ENV variable
set +u
if [[ ! "${ENV}" =~ ^(dev|preprod)$ ]]; then
  usage
  exit 1
fi
set -u

K8S_NAMESPACE="ppud-replacement-${ENV}"
PFP_NAME="legacy-ppud-api-db-proxy-$(whoami | tr ._ -)"
SECRET=ppud-replica-database

SECRET_JSON=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json)
DB_HOST=$(echo "${SECRET_JSON}" | jq -r '.data.host | @base64d')
DB_USER=$(echo "${SECRET_JSON}" | jq -r '.data.username | @base64d')
DB_PASS=$(echo "${SECRET_JSON}" | jq -r '.data.password | @base64d')
DB_PORT=1433

echo "Connecting to ${K8S_NAMESPACE}"

set +e
PFP_COUNT=$(kubectl -n "${K8S_NAMESPACE}" get pods | grep -c "${PFP_NAME}")
set -e

if [ "${PFP_COUNT}" -eq "0" ]; then
  echo "Starting up port forward pod..."

  kubectl -n "${K8S_NAMESPACE}" run \
    "${PFP_NAME}" \
    --image=ministryofjustice/port-forward \
    --port="${DB_PORT}" \
    --env="REMOTE_HOST=${DB_HOST}" \
    --env="LOCAL_PORT=${DB_PORT}" \
    --env="REMOTE_PORT=${DB_PORT}"

  sleep 5
fi

set +e
cmd="kubectl -n ${K8S_NAMESPACE} port-forward ${PFP_NAME} ${DB_PORT}:${DB_PORT}"
pid=$(pgrep -f "${cmd}")
set -e

echo "You can now connect to the database on 127.0.0.1:${DB_PORT} - username: ${DB_USER} - password: ${DB_PASS}"

# if the port-forward isn't already running, start it...
if [[ -z "${pid}" ]]; then
  ${cmd}
fi
