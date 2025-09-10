# Base image with Flutter 3.32.4
FROM ghcr.io/cirruslabs/flutter:3.32.4

# Install dependencies and JDK 17
USER root
RUN apt-get update -y && \
    apt-get install -y jq openjdk-17-jdk sudo && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "buildpiper"
RUN groupadd -g 65522 buildpiper && \
    useradd -m -u 65522 -g buildpiper -s /bin/bash buildpiper && \
    echo "buildpiper ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /opt/buildpiper/shell-functions && \
    chown -R buildpiper:buildpiper /opt/buildpiper /home/buildpiper && \
    chown -R buildpiper:buildpiper /sdks/flutter

# Mark flutter dir safe for Git
RUN git config --system --add safe.directory /sdks/flutter

# Add buildpiper shell functions
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

# Environment variables
ENV ACTIVITY_SUB_TASK_CODE="BP-FLUTTER-TASK" \
    SLEEP_DURATION="5s" \
    VALIDATION_FAILURE_ACTION="WARNING" \
    INSTRUCTION="build apk" \
    JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64" \
    PATH="$JAVA_HOME/bin:$PATH"

# Switch to non-root user
USER buildpiper
WORKDIR /home/buildpiper

# Copy build script
COPY --chown=buildpiper:buildpiper build.sh .

# Make script executable
RUN chmod +x /home/buildpiper/build.sh

# Entry point
ENTRYPOINT ["./build.sh"]