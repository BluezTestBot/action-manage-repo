FROM blueztestbot/bluez-build:latest 

COPY *.sh /

ENTRYPOINT ["/entrypoint.sh"]
