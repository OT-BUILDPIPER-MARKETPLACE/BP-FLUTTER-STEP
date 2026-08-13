#!/bin/bash

source /home/buildpiper/shell-functions/functions.sh
source /home/buildpiper/shell-functions/log-functions.sh

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
SLEEP_DURATION=5
TASK_STATUS=0

# SDK paths
export FLUTTER_HOME=/opt/flutter
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=/opt/jdk-17.0.17+10
export PATH="${JAVA_HOME}/bin:${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${PATH}"

export FLUTTER_SUPPRESS_ANALYTICS=true
export CI=true

logInfoMessage "Flutter Version: $(flutter --version | head -1)"
logInfoMessage "Java Version: $(java -version 2>&1 | head -1)"

logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep "${SLEEP_DURATION}"



# Step 1: Change directory
if ! cd "${CODEBASE_LOCATION}"; then
    logErrorMessage "Failed to change directory to ${CODEBASE_LOCATION}"
    TASK_STATUS=1
    saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
fi

logInfoMessage "Coping key files in android/ dir"
cp "/src/${COMPONENT_NAME}/"* "android/" || exit 1

# Step 2: Fetch dependencies
if [[ ${TASK_STATUS} -eq 0 ]]; then
    logInfoMessage "Running flutter pub get"

    if ! flutter pub get; then
        logErrorMessage "flutter pub get failed!"
        TASK_STATUS=1
        saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
    fi
fi


export GRADLE_OPTS="-Dorg.gradle.daemon=false"
export GRADLE_USER_HOME="${CODEBASE_LOCATION}/.gradle"
logInfoMessage "GRADLE_USER_HOME=${GRADLE_USER_HOME}"
mkdir -p "${GRADLE_USER_HOME}"

# Step 3: Execute Flutter command
if [[ ${TASK_STATUS} -eq 0 ]]; then
    logInfoMessage "Executing: flutter ${INSTRUCTION}"

    if ! flutter ${INSTRUCTION}; then
        logErrorMessage "flutter ${INSTRUCTION} failed!"
        TASK_STATUS=1
    fi
fi

# Cleanup
logInfoMessage "Cleaning up GRADLE_USER_HOME..."
rm -rf "${GRADLE_USER_HOME}"

saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"