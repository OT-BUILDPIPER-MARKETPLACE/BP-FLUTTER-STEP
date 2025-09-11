#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
SLEEP_DURATION=5
TASK_STATUS=0

logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep $SLEEP_DURATION

# Step 1: change directory
if ! cd "${CODEBASE_LOCATION}"; then
  logErrorMessage "Failed to change directory to ${CODEBASE_LOCATION}"
  TASK_STATUS=1
  saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
fi

# Step 2: flutter pub get
if [[ $TASK_STATUS -eq 0 ]]; then
  logInfoMessage "Running flutter pub get"
  if ! flutter pub get; then
    logErrorMessage "flutter pub get failed!"
    TASK_STATUS=1
    saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
  fi
fi

# Step 3: flutter instruction
if [[ $TASK_STATUS -eq 0 ]]; then
  logInfoMessage "I'll execute instruction: flutter $INSTRUCTION"
  if ! flutter $INSTRUCTION; then
    logErrorMessage "flutter $INSTRUCTION failed!"
    TASK_STATUS=1
  fi
fi

# Final save — will decide exit or not based on VALIDATION_FAILURE_ACTION
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}