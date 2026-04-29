#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
SLEEP_DURATION=5
TASK_STATUS=0

logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll $INSTRUCTION_TYPE the code available at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "Failed to change directory to $CODEBASE_LOCATION"
    add_event "WORKSPACE NAVIGATION" "Failed" \
          "Failed to navigate to workspace" \
          "Path: $CODEBASE_LOCATION"
    exit 1
}

add_event "WORKSPACE NAVIGATION" "Successful" \
      "Successfully navigated to workspace" \
      "Path: $CODEBASE_LOCATION"

add_event "INITIALIZATION" "Successful" \
      "Task initialization completed" \
      "Build mode: $INSTRUCTION_TYPE"

if [ -z "$INSTRUCTION" ]; then
    logErrorMessage "INSTRUCTION is not set. Exiting..."
    add_event "INITIALIZATION" "Failed" \
          "Instruction missing" \
          "No build instructions provided"
    exit 1
    TASK_STATUS=$?
fi

logInfoMessage "Executing $INSTRUCTION"

eval "$INSTRUCTION"

TASK_STATUS=$?

if [ "$TASK_STATUS" -eq 0 ]; then
    add_event "INSTRUCTION EXECUTION" "Successful" \
          "Build instruction executed successfully" \
          "Command: $INSTRUCTION"
else
    add_event "INSTRUCTION EXECUTION" "Failed" \
          "Build instruction execution failed" \
          "Command: $INSTRUCTION"
fi

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
add_event "TASK EXECUTION" "Successful" \
      "Flutter task completed" \
      "Status: $( [ $TASK_STATUS -eq 0 ] && echo "Success" || echo "Failure" )"
