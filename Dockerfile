FROM blueztestbot/bluez-build:latest 

RUN apt-get update && apt-get install -y git

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
