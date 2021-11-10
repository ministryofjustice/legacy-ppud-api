#!/bin/bash
set -euo pipefail

# This checks on the progress of the DMS replication task...

function usage {
  echo "
./$(basename $0) [option]

Options:
    -h --> show usage
    -e --> environment (REQUIRED) - allowed values: 'dev', 'preprod' or 'prod'
  "
}

function check_dep {
  if ! command -v "${1}" &>/dev/null; then
    echo "You need '${1}' - '${2}'"
    exit 1
  fi
}

# Check dependencies
check_dep "aws" "brew install awscli"
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
if [[ -z "${ENV}" ]]; then
  usage
  exit 1
fi
set -u

K8S_NAMESPACE="ppud-replacement-${ENV}"
SECRET=dms-instance

SECRET_JSON=$(kubectl -n "${K8S_NAMESPACE}" get secret "${SECRET}" -o json)
REPLICATION_INSTANCE_ARN=$(echo "${SECRET_JSON}" | jq -r '.data.replication_instance_arn | @base64d')
REPLICATION_TASK_ARN=$(echo "${SECRET_JSON}" | jq -r '.data.replication_task_arn | @base64d')
REPLICATION_TASK_ID=$(echo "${SECRET_JSON}" | jq -r '.data.replication_task_id | @base64d')
AWS_ACCESS_KEY_ID=$(echo "${SECRET_JSON}" | jq -r '.data.access_key_id | @base64d')
AWS_SECRET_ACCESS_KEY=$(echo "${SECRET_JSON}" | jq -r '.data.secret_access_key | @base64d')
export REPLICATION_INSTANCE_ARN
export REPLICATION_TASK_ARN
export REPLICATION_TASK_ID
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=eu-west-2

aws dms describe-replication-tasks |
  jq -r ".ReplicationTasks[] | select(.ReplicationTaskIdentifier == \"${REPLICATION_TASK_ID}\")"
