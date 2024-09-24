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
