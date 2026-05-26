#!/bin/bash

# ---------------------------------------------------------------
# NOTE: ACTIVITY_SUB_TASK_CODE is managed by the BuildPiper
#       environment. Do NOT override it here to ensure events
#       appear correctly in the UI.
# ---------------------------------------------------------------

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

if [ "$DEBUG" = true ]; then
    set -x
fi

# ---------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------
WORKSPACE="${WORKSPACE:-/bp/workspace}"
CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
TASK_STATUS=0

# ---------------------------------------------------------------
# 1. Initialization
# ---------------------------------------------------------------
logInfoMessage "> Starting step: flutter_build"
logInfoMessage "> Codebase location: ${CODEBASE_LOCATION}"
logInfoMessage "> Instruction type: ${INSTRUCTION_TYPE}"

add_event "INITIALIZATION" "Successful" \
    "Flutter build step initialized" \
    "Instruction type: ${INSTRUCTION_TYPE} | Codebase: ${CODEBASE_DIR}"

if [ -n "$SLEEP_DURATION" ] && [ "$SLEEP_DURATION" -gt 0 ] 2>/dev/null; then
    logInfoMessage "> Sleeping for ${SLEEP_DURATION} second(s)..."
    sleep "$SLEEP_DURATION"
fi

# ---------------------------------------------------------------
# 2. Input Validation
# ---------------------------------------------------------------
logInfoMessage "> Validating inputs..."

if [ -z "$WORKSPACE" ] || [ -z "$CODEBASE_DIR" ]; then
    logErrorMessage "> WORKSPACE or CODEBASE_DIR is not set — cannot proceed"
    add_event "INPUT_VALIDATION" "Failed" \
        "Required environment variables are missing" \
        "WORKSPACE: ${WORKSPACE:-<unset>} | CODEBASE_DIR: ${CODEBASE_DIR:-<unset>}"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
fi

if [ -z "$INSTRUCTION" ]; then
    logErrorMessage "> INSTRUCTION is not set — no build command to execute"
    add_event "INPUT_VALIDATION" "Failed" \
        "INSTRUCTION is not set" \
        "Set INSTRUCTION to the Flutter build command (e.g. flutter build apk)"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
fi

add_event "INPUT_VALIDATION" "Successful" \
    "All required inputs validated" \
    "Instruction type: ${INSTRUCTION_TYPE} | Codebase: ${CODEBASE_DIR}"

# ---------------------------------------------------------------
# 3. Execution Summary
# ---------------------------------------------------------------
echo ""
echo "> Flutter Build Execution Summary"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Parameter" "Value"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Codebase" "${CODEBASE_DIR}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Instruction Type" "${INSTRUCTION_TYPE}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Instruction" "${INSTRUCTION}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
echo ""

# ---------------------------------------------------------------
# 4. Workspace Navigation
# ---------------------------------------------------------------
logInfoMessage "> Navigating to codebase directory..."

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "> Failed to navigate to codebase directory: ${CODEBASE_LOCATION}"
    add_event "WORKSPACE_NAVIGATION" "Failed" \
        "Cannot change to codebase directory" \
        "Path: ${CODEBASE_LOCATION} | Verify WORKSPACE and CODEBASE_DIR"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
}

logInfoMessage "> Successfully navigated to: ${CODEBASE_LOCATION}"
add_event "WORKSPACE_NAVIGATION" "Successful" \
    "Navigated to codebase directory" \
    "Path: ${CODEBASE_LOCATION}"

# ---------------------------------------------------------------
# 5. Build Execution
# ---------------------------------------------------------------
logInfoMessage "> Executing Flutter instruction: ${INSTRUCTION}"
add_event "BUILD_START" "Successful" \
    "Starting Flutter build instruction" \
    "Command: ${INSTRUCTION} | Type: ${INSTRUCTION_TYPE}"

eval "$INSTRUCTION"
TASK_STATUS=$?

if [ "$TASK_STATUS" -eq 0 ]; then
    logInfoMessage "> Flutter instruction completed successfully"
    add_event "BUILD_RESULT" "Successful" \
        "Flutter build instruction executed successfully" \
        "Command: ${INSTRUCTION} | Type: ${INSTRUCTION_TYPE}"
else
    logErrorMessage "> Flutter instruction failed (exit: ${TASK_STATUS})"
    add_event "BUILD_RESULT" "Failed" \
        "Flutter build instruction failed" \
        "Command: ${INSTRUCTION} | Exit code: ${TASK_STATUS}"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
fi

# ---------------------------------------------------------------
# 6. Final Status
# ---------------------------------------------------------------
logInfoMessage "> Flutter build step completed successfully"
saveTaskStatus 0 "${ACTIVITY_SUB_TASK_CODE}"
exit 0
