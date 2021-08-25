FROM adoptopenjdk/openjdk11:alpine-jre

RUN apk add --update curl python3 py3-pip py-cffi && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade wheel && \
    apk add --virtual build-deps gcc libffi-dev python3-dev linux-headers musl-dev openssl-dev && \
    pip3 install awscli && \
    pip3 install gsutil && \
    apk del build-deps && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /opt/guano
COPY backup.sh /opt/guano/backup.sh
COPY target/guano-0.1.0.jar /opt/guano/guano-0.1.0.jar
RUN chmod 755 /opt/guano/backup.sh

ENTRYPOINT ["/opt/guano/backup.sh"]
