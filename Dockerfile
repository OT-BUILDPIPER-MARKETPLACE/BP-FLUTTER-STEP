FROM ghcr.io/cirruslabs/flutter:stable

ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

ENV ACTIVITY_SUB_TASK_CODE BP-TRIVY-TASK
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION WARNING
ENV INSTRUCTION "apk build"

COPY build.sh .

RUN sudo apt-get update \
 && sudo apt-get install -y jq \
 && sudo rm -rf /var/lib/apt/lists/* 

ENTRYPOINT [ "./build.sh" ]