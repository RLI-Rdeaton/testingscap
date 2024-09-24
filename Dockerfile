<<<<<<< HEAD
################################################################################
# Build stage 0
# Extract ZK base files
################################################################################
ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=chainguard/wolfi-base
ARG BASE_TAG=latest
=======
# syntax=docker/dockerfile:1
#Testing!
FROM busybox:latest
COPY --chmod=755 <<EOF /app/run.sh
#!/bin/sh
while true; do
  echo -ne "The time is now $(date +%T)\\r"
  sleep 1
done
EOF
>>>>>>> 7af082cb12754b508f71f2c6bdd402bad83e995f

FROM radiantone/zookeeper:3.5.8 AS base

# RUN chmod -R g=u /opt/radiantone

################################################################################
# Build stage 1
# Copy prepared files from the previous stage and complete the image.
################################################################################
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

RUN apk update && apk add --no-cache --update-cache netcat-openbsd \
curl grep bash

# Copy file from FID image
COPY --from=base --chown=1000:1000 /opt/radiantone /opt/radiantone

RUN addgroup --gid 1000 radiant && adduser -H -D -u 1000 -G radiant radiant

RUN chmod -R g=u /opt/radiantone

USER radiant

RUN chmod -R g=u /opt/radiantone

WORKDIR /opt/radiantone

ENV PATH=/opt/radiantone/rli-zookeeper-external/zookeeper/bin:/opt/radiantone/rli-zookeeper-external/jdk/bin:${PATH}

EXPOSE 2181 2888 3888 8080

CMD ["/opt/radiantone/run.sh"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=1m --retries=5 CMD curl -I -f --max-time 5 http://localhost:8080/commands/ruok || exit 1
