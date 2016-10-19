FROM alpine:3.4
MAINTAINER Toon van Dooren <toon@weepee.io>

ADD scripts/backup.sh /scripts/backup.sh

RUN apk upgrade && \
 apk add --update bash postgresql-client mysql-client tzdata && \
 cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
 echo "Europe/Brussels" > /etc/timezone && \
 chmod -R a+rx /scripts && \
 rm -f /var/cache/apk/*

WORKDIR /scripts

ENTRYPOINT ["/scripts/backup.sh"]

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="DB Backup" \
      io.k8s.display-name="DB Backup" \
      io.openshift.expose-services="" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1" \
      io.openshift.non-scalable="false"