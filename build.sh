#!/bin/bash

source /home/buildpiper/shell-functions/functions.sh
source /home/buildpiper/shell-functions/log-functions.sh
source /home/buildpiper/shell-functions/getDataFile.sh

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

logInfoMessage "Copying key files in android/ dir"
cp "/src/${COMPONENT_NAME}/playstore/"* "android/" || exit 1

# Gradle configuration
export GRADLE_OPTS="-Dorg.gradle.daemon=false"
export GRADLE_USER_HOME="${CODEBASE_LOCATION}/.gradle"
logInfoMessage "GRADLE_USER_HOME=${GRADLE_USER_HOME}"
mkdir -p "${GRADLE_USER_HOME}"



# Step 2: flutter clean
if [[ ${TASK_STATUS} -eq 0 ]]; then
    logInfoMessage "Running flutter clean"

    if ! flutter clean; then
        logErrorMessage "flutter clean failed!"
        TASK_STATUS=1
        saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
    fi
fi


# Step 2: Fetch dependencies
if [[ ${TASK_STATUS} -eq 0 ]]; then
    logInfoMessage "Running flutter pub get"

    if ! flutter pub get; then
        logErrorMessage "flutter pub get failed!"
        TASK_STATUS=1
        saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
    fi
fi

# Step 3: Generate Flutter launcher icons

ICON_GENERATE="${ICON_GENERATE:-FALSE}"

if [[ "${TASK_STATUS}" -eq 0 && "${ICON_GENERATE^^}" == "TRUE" ]]; then
    logInfoMessage "ICON_GENERATE is TRUE. Generating Flutter launcher icons."

    if ! flutter pub run flutter_launcher_icons:main; then
        logErrorMessage "Flutter launcher icon generation failed!"
        TASK_STATUS=1
        saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
    fi
else
    logInfoMessage "Skipping Flutter launcher icon generation. ICON_GENERATE=${ICON_GENERATE}"
fi

# Step 4: Execute Flutter commands

if [[ ${TASK_STATUS} -eq 0 ]]; then

    logInfoMessage "Executing Flutter instructions: ${INSTRUCTION}"

    IFS=',' read -ra FLUTTER_COMMANDS <<< "${INSTRUCTION}"

    for FLUTTER_CMD in "${FLUTTER_COMMANDS[@]}"; do

        # Remove leading and trailing whitespace
        FLUTTER_CMD="$(echo "${FLUTTER_CMD}" | xargs)"

        [[ -z "${FLUTTER_CMD}" ]] && continue

        logInfoMessage "Executing: flutter ${FLUTTER_CMD}"

        if ! flutter ${FLUTTER_CMD}; then
            logErrorMessage "Flutter command failed: flutter ${FLUTTER_CMD}"
            TASK_STATUS=1
            saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"
            break
        fi

    done
fi

saveTaskStatus "${TASK_STATUS}" "${ACTIVITY_SUB_TASK_CODE}"