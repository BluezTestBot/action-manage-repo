FROM ubuntu:18.04

RUN apt-get update && apt-get install -y git

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
