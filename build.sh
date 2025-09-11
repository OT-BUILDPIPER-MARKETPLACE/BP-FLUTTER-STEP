#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh


CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
SLEEP_DURATION=5
logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION
TASK_STATUS=0

cd "${CODEBASE_LOCATION}" || {
  logErrorMessage "Failed to change directory to ${CODEBASE_LOCATION}"
  TASK_STATUS=1
}

logInfoMessage "Running flutter pub get"
if ! flutter pub get; then
  logErrorMessage "flutter pub get failed!"
  TASK_STATUS=1
fi

logInfoMessage "I'll execute instruction: flutter $INSTRUCTION"
if ! flutter $INSTRUCTION; then
  logErrorMessage "flutter $INSTRUCTION failed!"
  TASK_STATUS=1
fi

TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}