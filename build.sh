#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh


CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
SLEEP_DURATION=5
logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION

cd "${CODEBASE_LOCATION}" || {
  logErrorMessage "Failed to change directory to ${CODEBASE_LOCATION}"
  exit 1
}

logInfoMessage "Running flutter pub get"
if ! flutter pub get; then
  logErrorMessage "flutter pub get failed!"
  exit 1
fi

logInfoMessage "I'll execute instruction: flutter $INSTRUCTION"
if ! flutter $INSTRUCTION; then
  logErrorMessage "flutter $INSTRUCTION failed!"
  exit 1
fi

TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}