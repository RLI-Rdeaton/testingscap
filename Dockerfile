################################################################################
# Build stage 0
# Extract FID base files
################################################################################
ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=chainguard/wolfi-base
ARG BASE_TAG=latest

ARG FID_REGISTRY=docker.io
ARG FID_IMAGE=radiantone/fid
ARG FID_TAG=7.4.12

FROM ${FID_REGISTRY}/${FID_IMAGE}:${FID_TAG} AS base

RUN chmod -R g=u /opt/radiantone

################################################################################
# Build stage 1
# Copy prepared files from the previous stage and complete the image.
################################################################################
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
ARG FID_TAG

# Hostname is on the machine
# nc is apk add netcat-openbsd
# gzip is on the machine
# unzip is on the machine
# vi comes standard - do w e want to add vim or nano?
#

RUN apk update && apk add --no-cache --update-cache netcat-openbsd \
curl grep bash

# Copy file from FID image
COPY --from=base --chown=1000:1000 /opt/radiantone /opt/radiantone

RUN addgroup --gid 1000 radiant && adduser -H -D -u 1000 -G radiant radiant

RUN chmod -R g=u /opt/radiantone

RUN rm -f /opt/radiantone/migration-tool.zip

USER radiant


WORKDIR /opt/radiantone

ENV FID_VERSION=${FID_TAG}
ENV PATH=/opt/radiantone/vds/bin:/opt/radiantone/vds/bin/advanced:$PATH
ENV RLI_HOME=/opt/radiantone/vds
ENV LIVENESS_CHECK="curl -m 1 -sf localhost:9100/ping"

EXPOSE 2389 2636 7070 7171 8089 8090 9100 9101

ENTRYPOINT ["/opt/radiantone/run.sh"]
CMD ["fg"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=1m --retries=5 CMD curl -I -f --max-time 5 http://localhost:9100 || exit 1
