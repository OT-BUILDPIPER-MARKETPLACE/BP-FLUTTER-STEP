FROM ghcr.io/cirruslabs/flutter:3.7.7

ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

RUN sudo apt-get update \
 && sudo apt-get install -y jq \
 && sudo rm -rf /var/lib/apt/lists/* 
 
ENV ACTIVITY_SUB_TASK_CODE BP-FLUTTER-TASK
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION WARNING
ENV INSTRUCTION "build apk"

COPY build.sh .

ENTRYPOINT [ "./build.sh" ]