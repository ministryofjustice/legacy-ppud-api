#!/bin/bash
set -euo pipefail

task_json=$(aws dms describe-replication-tasks | jq -r ".ReplicationTasks[] | select(.ReplicationTaskIdentifier == \"${REPLICATION_TASK_ID}\")")

status="0"
if [ "$(echo "${task_json}" | jq -r '.Status')" == "running" ]; then
  status="1"
fi

cat <<EOF | curl --data-binary @- http://ppud-replacement-${ENVIRONMENT}-pushgateway-prometheus-pushgateway:9091/metrics/job/legacy-ppud-api-database-sync
# HELP dms_task_status health of a DMS migration task - 1=healthy, 0=unhealthy
# TYPE dms_task_status gauge
dms_task_status ${status}
EOF
