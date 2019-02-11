#!/bin/bash
# run gcloud-snapshot.sh once and execute the notify
# Alternative if $DAEMON is set, run it in a loop with a configurable delay
# ($SLEEP environment variable) and a notification command
# ($NOTIFY_COMMAND environment variable), for example a curl webhook
# notification (e.g. to Slack).

service_account_auth() {
  if [ -n "${KEY_FILE}" ]; then
    gcloud auth activate-service-account --key-file="$KEY_FILE"
  fi
}

set_project() {
    if [ -n "${PROJECT}" ]; then
        gcloud config set project "$PROJECT"
    fi
}

run() {
	if [ -n "${FILTER}" ]; then
		/opt/gcloud-snapshot.sh -r -f "$FILTER"
	else
		/opt/gcloud-snapshot.sh -r
	fi
	if [ -n "${NOTIFY_COMMAND}" ]; then
		echo "Running notify command: $NOTIFY_COMMAND"
		bash -c "$NOTIFY_COMMAND"
	fi
}

service_account_auth
set_project

if [ -n "${DAEMON}" ]; then
	if [ -z "${SLEEP}" ]; then
		# Default to every 6 hours
		SLEEP=21600
	fi
	while true; do
		run
		echo "Sleeping for $SLEEP seconds"
		sleep $SLEEP
	done
else
	run
fi
