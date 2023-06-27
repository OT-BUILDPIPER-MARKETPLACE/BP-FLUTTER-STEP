FROM ghcr.io/cirruslabs/flutter:stable

COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY BP-BASE-SHELL-STEPS/log-functions.sh .

ENV ACTIVITY_SUB_TASK_CODE BP-TRIVY-TASK
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION WARNING

COPY build.sh .

RUN sudo apt-get update \
 && sudo apt-get install -y jq \
 && sudo rm -rf /var/lib/apt/lists/* 

ENTRYPOINT [ "./build.sh" ]