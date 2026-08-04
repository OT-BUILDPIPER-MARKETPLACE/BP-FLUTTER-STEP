FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/opt/jdk-17.0.17+10
ENV PATH=${JAVA_HOME}/bin:${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${PATH}

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    unzip \
    zip \
    xz-utils \
    libglu1-mesa \
    ca-certificates \
    jq \
 && rm -rf /var/lib/apt/lists/*

# Create BuildPiper user
RUN groupadd -g 65522 buildpiper && \
    useradd -u 65522 -g 65522 -m -d /home/buildpiper -s /bin/bash buildpiper && \
    mkdir -p \
        /workspace \
        /bp/data \
        /bp/execution_dir \
        /opt/buildpiper \
        /bp/workspace && \
    chown -R 65522:65522 \
        /workspace \
        /bp \
        /opt/buildpiper \
        /home/buildpiper

# Copy BuildPiper shell functions
COPY --chown=65522:65522 BP-BASE-SHELL-STEPS/ /home/buildpiper/shell-functions/
# Copy build script
WORKDIR /workspace
COPY --chown=buildpiper:buildpiper build.sh /build.sh
RUN chmod +x /build.sh

USER 65522:65522

ENTRYPOINT ["/build.sh"]